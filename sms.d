module dsmsapi.sms;

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

enum CHARSET : string
{
    DEFAULT         = "",
    ISO_8859_1      = "iso-8859-1",
    ISO_8859_2      = "iso-8859-2",
    ISO_8859_3      = "iso-8859-3",
    ISO_8859_4      = "iso-8859-4",
    ISO_8859_5      = "iso-8859-5",
    ISO_8859_7      = "iso-8859-7",
    UTF_8           = "utf-8",
    WINDOWS_1250    = "windows-1250",
    WINDOWS_1251    = "windows-1251",
}

enum TYPE : string
{
    ECO = "ECO",
    WAY = "2Way",
}

struct Sender
{
    string name;

    string toString()
    {
        return name;
    }
}

struct Parameters
{
    string first, second, third, fourth;
}

class Pattern
{
    private:
        string name;
        Parameters parameters;
        bool single;

    public:
        this(string name)
        {
            setName(name);
        }

        bool getSingle()
        {
            return single;
        }

        Pattern setSingle(bool value)
        {
            single = value;

            return this;
        }

        Parameters getParameters()
        {
            return parameters;
        }
        
        Pattern setParameters(Parameters value)
        {
            parameters = value;

            return this;
        }

        string getName()
        {
            return name;
        }

    protected:
        Pattern setName(string value)
        {
            name = value;

            return this;
        }
}

class Sms : Message
{
    private:
        CHARSET charset = CHARSET.DEFAULT;
        bool    normalize = false;
        Pattern pattern;
        Sender  sender;
        TYPE    type;

    public:
        this(Sender sender, Receiver[] receivers, Content content)
        {
            setSender(sender);
            setReceivers(receivers);
            setContent(content);
        }

        this(Sender sender, Receiver receiver, Content content)
        {
            this(sender, [receiver], content);
        }

        this(TYPE type, Receiver[] receivers, Content content)
        {
            setType(type);
            setReceivers(receivers);
            setContent(content);
        }

        this(TYPE type, Receiver receiver, Content content)
        {
            this(type, [receiver], content);
        }

        this(Sender sender, Receiver[] receivers, Pattern pattern)
        {
            setSender(sender);
            setReceivers(receivers);
            setPattern(pattern);
        }

        this(Sender sender, Receiver receiver, Pattern pattern)
        {
            this(sender, [receiver], pattern);
        }

        this(TYPE type, Receiver[] receivers, Pattern pattern)
        {
            setType(type);
            setReceivers(receivers);
            setPattern(pattern);
        }

        this(TYPE type, Receiver receiver, Pattern pattern)
        {
            this(type, [receiver], pattern);
        }

        bool getNormalize()
        {
            return normalize;
        }

        Sms setNormalize(bool value)
        {
            normalize = value;
            
            return this;
        }

        CHARSET getCharset()
        {
            return charset;
        }

        Sms setCharset(CHARSET value)
        {
            charset = value;
            
            return this;
        }

        Sender getSender()
        {
            return sender;
        }

        TYPE getType()
        {
            return type;
        }

        Pattern getPattern()
        {
            return pattern;
        }

    protected:
        Sms setSender(Sender value)
        {
            sender = value;

            return this;
        }

        Sms setType(TYPE value)
        {
            type = value;

            return this;
        }

        Sms setPattern(Pattern value)
        {
            pattern = value;

            return this;
        }
}

class SendSms : Method
{
    static const dsmsapi.core.PATH PATH = PATH.SMS;

    private:
        RequestBuilder requestBuilder;
        Sms sms;

        ParameterFactory parameterFactory = new ParameterFactory;

    public:
        this(Sms sms)
        {
            setSms(sms);
            setRequestBuilder((new RequestBuilderFactory).create());
        }

        RequestBuilder getRequest()
        {
            string[] receivers;

            Sms sms                             = getSms();
            Content content                     = sms.getContent();
            Pattern pattern                     = sms.getPattern();
            Parameters parameters               = pattern.getParameters();
            CHARSET charset                     = sms.getCharset();
            ParameterFactory parameterFactory   = getParameterFactory();

            RequestBuilder requestBuilder = getRequestBuilder().setPath(PATH);

            if (getSms().getSender().name) {
                requestBuilder.addParameter(parameterFactory.create(PARAMETER.FROM, text(sms.getSender())));
            } else {
                requestBuilder.addParameter(parameterFactory.create(PARAMETER.FROM, sms.getType()));
            }

            foreach (Receiver receiver; sms.getReceivers()) {
                receivers[] = text(receiver);
            }

            requestBuilder.addParameter(parameterFactory.create(PARAMETER.TO, receivers));

            if (charset != CHARSET.DEFAULT) {
                requestBuilder.addParameter(parameterFactory.create(PARAMETER.ENCODING, charset));
            }

            if (sms.getNormalize()) {
                requestBuilder.addParameter(parameterFactory.create(PARAMETER.NORMALIZE, "1"));
            }

            if (text(content) != string.init) {
                requestBuilder.addParameter(parameterFactory.create(PARAMETER.MESSAGE, text(content)));
            } else {
                requestBuilder
                    .addParameter(parameterFactory.create(PARAMETER.PARAM_1, parameters.first))
                    .addParameter(parameterFactory.create(PARAMETER.PARAM_2, parameters.second))
                    .addParameter(parameterFactory.create(PARAMETER.PARAM_3, parameters.third))
                    .addParameter(parameterFactory.create(PARAMETER.PARAM_4, parameters.fourth))
                    .addParameter(parameterFactory.create(PARAMETER.TEMPLATE, pattern.getName()));

                if (pattern.getSingle()) {
                    requestBuilder.addParameter(parameterFactory.create(PARAMETER.SINGLE, "1"));
                }
            }

            return requestBuilder;
        }

    protected:
        Sms getSms()
        {
            return sms;
        }

        SendSms setSms(Sms value)
        {
            this.sms = sms;

            return this;
        }

        RequestBuilder getRequestBuilder()
        {
            return requestBuilder;
        }

        SendSms setRequestBuilder(RequestBuilder requestBuilder)
        {
            this.requestBuilder = requestBuilder;

            return this;
        }

        ParameterFactory getParameterFactory()
        {
            return parameterFactory;
        }
}