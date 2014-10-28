module dsmsapi.mms;

import std.conv     : text;
import std.datetime : DateTime, DateTimeException, SysTime;

import dsmsapi.core:
    Content,
    InvalidDateStringException,
    InvalidTimestampException,
    Message,
    Method,
    Parameter,
    ParamName,
    Receiver,
    RequestBuilder,
    Resource;

immutable struct Subject
{
    string content;

    pure string toString()
    {
        return content;
    }
}

class Mms : Message
{
    immutable {
        DateTime date;
        Subject  subject;
    }

    pure this(Subject subject, Receiver receiver, Content content, ulong timestamp = ulong.init)
    {
        this(subject, [receiver], content, timestamp);
    }

    pure this(Subject subject, Receiver[] receivers, Content content, ulong timestamp = ulong.init)
    {
        DateTime dateTime = DateTime(1970, 1, 1);

        dateTime.roll!"seconds"(timestamp);

        this(subject, receivers, content, dateTime);
    }

    pure this(Subject subject, Receiver receiver, Content content, string dateString)
    {
        this(subject, [receiver], content, dateString);
    }

    pure this(Subject subject, Receiver[] receivers, Content content, string dateString)
    {
        DateTime dateTime;

        try {
            dateTime = DateTime.fromISOString(dateString);
        } catch (DateTimeException exception) {
            try {
                dateTime = DateTime.fromISOExtString(dateString);
            } catch (DateTimeException exception) {
                try {
                    dateTime = DateTime.fromSimpleString(dateString);
                } catch (DateTimeException exception) {
                    throw new InvalidDateStringException(dateString);
                }
            }
        }

        this(subject, receivers, content, dateTime);
    }

    pure this(Subject subject, Receiver receiver, Content content, DateTime dateTime)
    {
        this(subject, [receiver], content, dateTime);
    }

    pure this(Subject subject, Receiver[] receivers, Content content, DateTime dateTime)
    {
        this.subject     = subject;
        messageReceivers = receivers;
        messageContent   = content;
        date             = dateTime;
    }
}

class Send : Method
{
    private:
        static const Resource resource = Resource.mms;

        Mms mms;

    public:
        pure this(Mms mms)
        {
            this.mms = mms;
        }

        RequestBuilder createRequestBuilder()
        {
            RequestBuilder requestBuilder = new RequestBuilder;
            ulong          timestamp      = SysTime(mms.date).toUnixTime();

            string[] receivers;

            requestBuilder.resource = resource;

            foreach (Receiver receiver; mms.receivers) {
                receivers ~= text(receiver);
            }

            requestBuilder
                .setParameter(new Parameter(ParamName.to, receivers))
                .setParameter(new Parameter(ParamName.subject, text(mms.subject)))
                .setParameter(new Parameter(ParamName.smil, text(mms.content)));

            if (timestamp > SysTime().toUnixTime()) {
                requestBuilder.setParameter(new Parameter(ParamName.date, text(timestamp)));
            }

            return requestBuilder;
        }
}
