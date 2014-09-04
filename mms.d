module dsmsapi.mms;

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

struct Subject
{
    private string content;

    pure this(string content)
    {
        this.content = content;
    }

    pure string toString()
    {
        return content;
    }

    pure string getContent()
    {
        return content;
    }
}

class Mms : Message
{
    private
        ulong   date;
        Subject subject;

    public:
        pure this(Subject subject, Receiver[] receivers, Content content, ulong date = ulong.init)
        {
            this.subject   = subject;
            this.receivers = receivers;
            this.content   = content;
            this.date      = date;
        }

        pure this(Subject subject, Receiver receiver, Content content, ulong date = ulong.init)
        {
            this(subject, [receiver], content, date);
        }

        pure Subject getSubject()
        {
            return subject;
        }

        pure ulong getDate()
        {
            return date;
        }
}

class Send : Method
{
    static const PATH path = PATH.MMS;

    private Mms mms;

    this(Mms mms)
    {
        this.mms = mms;
    }

    RequestBuilder getRequestBuilder()
    {
        string[] receivers;

        RequestBuilder requestBuilder = new RequestBuilder().setPath(path);

        foreach (Receiver receiver; mms.getReceivers()) {
            receivers ~= text(receiver);
        }

        requestBuilder
            .setParameter(new Parameter(PARAMETER.TO, receivers))
            .setParameter(new Parameter(PARAMETER.SUBJECT, text(mms.getSubject())))
            .setParameter(new Parameter(PARAMETER.SMIL, text(mms.getContent())));

        if (mms.getDate() != ulong.init) {
            requestBuilder.setParameter(new Parameter(PARAMETER.DATE, text(mms.getDate())));
        }

        return requestBuilder;
    }
}
