module dsmsapi.vms;

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
    Path,
    Receiver,
    RequestBuilder;

class Vms : Message
{
    immutable DateTime date;

    pure this(Receiver receiver, Content content, ulong timestamp = ulong.init)
    {
        this([receiver], content, timestamp);
    }

    pure this(Receiver[] receivers, Content content, ulong timestamp = ulong.init)
    {
        DateTime dateTime = DateTime(1970, 1, 1);

        if (timestamp > ulong.init) {
            if (timestamp <= SysTime().toUnixTime()) {
                dateTime.roll!"seconds"(timestamp);
            } else {
                throw new InvalidTimestampException(timestamp);
            }
        }

        this(receivers, content, dateTime);
    }

    pure this(Receiver receiver, Content content, string dateString)
    {
        this([receiver], content, dateString);
    }

    pure this(Receiver[] receivers, Content content, string dateString)
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

        this(receivers, content, dateTime);
    }

    pure this(Receiver receiver, Content content, DateTime dateTime)
    {
        this([receiver], content, dateTime);
    }

    pure this(Receiver[] receivers, Content content, DateTime dateTime)
    {
        messageReceivers = receivers;
        messageContent   = content;
        date             = dateTime;
    }
}

class Send : Method
{
    private:
        static const Path path = Path.vms;

        Vms vms;

    public:
        pure this(Vms vms)
        {
            this.vms = vms;
        }

        RequestBuilder createRequestBuilder()
        {
            RequestBuilder requestBuilder = new RequestBuilder;
            ulong          timestamp      = SysTime(vms.date).toUnixTime();

            string[] receivers;

            requestBuilder.path = path;

            foreach (Receiver receiver; vms.receivers) {
                receivers ~= text(receiver);
            }

            requestBuilder
                .setParameter(new Parameter(ParamName.to, receivers))
                .setParameter(new Parameter(ParamName.tts, text(vms.content)));

            if (timestamp > SysTime().toUnixTime()) {
                requestBuilder.setParameter(new Parameter(ParamName.date, text(timestamp)));
            }

            return requestBuilder;
        }
}
