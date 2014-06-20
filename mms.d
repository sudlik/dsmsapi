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
    private Subject subject;

    public:
        pure this(Subject subject, Receiver[] receivers, Content content)
        {
            this.subject = subject;
            this.receivers = receivers;
            this.content = content;
        }

        pure this(Subject subject, Receiver receiver, Content content)
        {
            this.subject = subject;
            this.receivers = [receiver];
            this.content = content;
        }

        pure Subject getSubject()
        {
            return subject;
        }
}

class SendMms : Method
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
            .addParameter(new Parameter(PARAMETER.TO, receivers))
            .addParameter(new Parameter(PARAMETER.SUBJECT, text(mms.getSubject())))
            .addParameter(new Parameter(PARAMETER.SMIL, text(mms.getContent())));

        return requestBuilder;
    }
}