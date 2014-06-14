module dsmsapi.mms;

import dsmsapi.core :
    Content,
    Message,
    Method,
    ParameterFactory,
    PARAMETER,
    PATH,
    Receiver,
    RequestBuilder,
    RequestBuilderFactory;

import std.conv : text;

struct Subject
{
    string content;

    string toString()
    {
        return content;
    }
}

class Mms : Message
{
    private Subject subject;

    public:
        this(Subject subject, Receiver[] receivers, Content content)
        {
            setSubject(subject);
            setReceivers(receivers);
            setContent(content);
        }

        this(Subject subject, Receiver receiver, Content content)
        {
            this(subject, [receiver], content);
        }

        Subject getSubject()
        {
            return subject;
        }

    protected:
        Mms setSubject(Subject value)
        {
            subject = value;

            return this;
        }
}

class SendMms : Method
{
    static const dsmsapi.core.PATH PATH = PATH.MMS;

    private:
        Mms mms;
        RequestBuilder requestBuilder;

        ParameterFactory parameterFactory = new ParameterFactory;

    public:
        this(Mms mms)
        {
            setMms(mms);
            setRequestBuilder((new RequestBuilderFactory).create());
        }

        RequestBuilder getRequest()
        {
            string[] receivers;
            
            Mms mms = getMms();

            RequestBuilder requestBuilder = getRequestBuilder().setPath(PATH);

            foreach (Receiver receiver; mms.getReceivers()) {
                receivers[] = text(receiver);
            }

            requestBuilder
                .addParameter(parameterFactory.create(PARAMETER.TO, receivers))
                .addParameter(parameterFactory.create(PARAMETER.SUBJECT, text(mms.getSubject())))
                .addParameter(parameterFactory.create(PARAMETER.SMIL, text(mms.getContent())));

            return requestBuilder;
        }

    protected:
        Mms getMms()
        {
            return mms;
        }

        SendMms setMms(Mms mms)
        {
            this.mms = mms;

            return this;
        }

        RequestBuilder getRequestBuilder()
        {
            return requestBuilder;
        }

        SendMms setRequestBuilder(RequestBuilder requestBuilder)
        {
            this.requestBuilder = requestBuilder;

            return this;
        }

        ParameterFactory getParameterFactory()
        {
            return parameterFactory;
        }
}