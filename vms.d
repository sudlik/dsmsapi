module dsmsapi.vms;

import std.conv: text, to;

import dsmsapi.core:
    Content,
    Message,
    Method,
    Parameter,
    ParamName,
    Path,
    Receiver,
    RequestBuilder;

immutable class Vms : Message
{
    ulong date;

    pure this(Receiver receiver, Content content, ulong date = ulong.init)
    {
        this([receiver], content, date);
    }

    pure this(Receiver[] receivers, Content content, ulong date = ulong.init)
    {
        messageReceivers = receivers;
        messageContent   = content;
        this.date        = date;
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
            string[] receivers;

            RequestBuilder requestBuilder = new RequestBuilder;

            requestBuilder.path = path;

            foreach (Receiver receiver; vms.receivers) {
                receivers ~= text(receiver);
            }

            requestBuilder
                .setParameter(new Parameter(ParamName.to, receivers))
                .setParameter(new Parameter(ParamName.tts, text(vms.content)));

            if (vms.date != ulong.init) {
                requestBuilder.setParameter(new Parameter(ParamName.date, text(vms.date)));
            }

            return requestBuilder;
        }
}
