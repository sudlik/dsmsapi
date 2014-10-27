module dsmsapi.mms;

import std.conv     : text;
import std.datetime : DateTime, SysTime;

import dsmsapi.core:
    Content,
    Message,
    Method,
    Parameter,
    ParamName,
    Path,
    Receiver,
    RequestBuilder;

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
        static const Path path = Path.mms;

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

            requestBuilder.path = path;

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
