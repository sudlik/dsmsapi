module dsmsapi.mms;

import std.conv: text;

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
        ulong   date;
        Subject subject;
    }

    public:
        pure this(Subject subject, Receiver[] receivers, Content content, ulong date = ulong.init)
        {
            this.subject     = subject;
            messageReceivers = receivers;
            messageContent   = content;
            this.date        = date;
        }

        pure this(Subject subject, Receiver receiver, Content content, ulong date = ulong.init)
        {
            this(subject, [receiver], content, date);
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
            string[] receivers;

            RequestBuilder requestBuilder = new RequestBuilder;

            requestBuilder.path = path;

            foreach (Receiver receiver; mms.receivers) {
                receivers ~= text(receiver);
            }

            requestBuilder
                .setParameter(new Parameter(ParamName.to, receivers))
                .setParameter(new Parameter(ParamName.subject, text(mms.subject)))
                .setParameter(new Parameter(ParamName.smil, text(mms.content)));

            if (mms.date != ulong.init) {
                requestBuilder.setParameter(new Parameter(ParamName.date, text(mms.date)));
            }

            return requestBuilder;
        }
}
