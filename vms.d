module dsmsapi.vms;

import std.conv : text;

import dsmsapi.core :
    Content,
    Message,
    Method,
    Parameter,
    PARAMETER,
    PATH,
    Receiver,
    RequestBuilder;

class Vms : Message
{
    private ulong date;

    public:
        pure this(Receiver[] receivers, Content content, ulong date = ulong.init)
        {
            this.receivers = receivers;
            this.content   = content;
            this.date      = date;
        }
        pure ulong getDate()
        {
            return date;
        }
}

class Send : Method
{
    static const PATH path = PATH.VMS;

    private Vms vms;

    this(Vms vms)
    {
        this.vms = vms;
    }

    RequestBuilder getRequestBuilder()
    {
        string[] receivers;

        RequestBuilder requestBuilder = new RequestBuilder().setPath(path);

        foreach (Receiver receiver; vms.getReceivers()) {
            receivers ~= text(receiver);
        }

        requestBuilder
            .setParameter(new Parameter(PARAMETER.TO, receivers))
            .setParameter(new Parameter(PARAMETER.TTS, text(vms.getContent())));

        if (vms.getDate() != ulong.init) {
            requestBuilder.setParameter(new Parameter(PARAMETER.DATE, text(vms.getDate())));
        }

        return requestBuilder;
    }
}
