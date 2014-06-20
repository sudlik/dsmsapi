module dsmsapi.sms;

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

enum CHARSET : string
{
    DEFAULT      = "",
    ISO_8859_1   = "iso-8859-1",
    ISO_8859_2   = "iso-8859-2",
    ISO_8859_3   = "iso-8859-3",
    ISO_8859_4   = "iso-8859-4",
    ISO_8859_5   = "iso-8859-5",
    ISO_8859_7   = "iso-8859-7",
    UTF_8        = "utf-8",
    WINDOWS_1250 = "windows-1250",
    WINDOWS_1251 = "windows-1251",
}

enum TYPE : string
{
    ECO = "ECO",
    WAY = "2Way",
}

struct Sender
{
    private string name;

    pure this(string name)
    {
        this.name = name;
    }

    pure string toString()
    {
        return name;
    }

    pure string getName()
    {
        return name;
    }
}

struct Parameters
{
    private string first, second, third, fourth;

    pure this(string first, string second, string third, string fourth)
    {
        this.first  = first;
        this.second = second;
        this.third  = third;
        this.fourth = fourth;
    }

    pure string getFirst()
    {
        return first;
    }

    pure string getSecond()
    {
        return second;
    }

    pure string getThird()
    {
        return third;
    }

    pure string getFourth()
    {
        return fourth;
    }
}

class Pattern
{
    private:
        string name;
        Parameters parameters;
        bool single;

    public:
        pure this(string name, Parameters parameters = Parameters(), bool single = false)
        {
            this.name = name;
            this.parameters = parameters;
            this.single = single;
        }

        pure string getName()
        {
            return name;
        }

        pure Parameters getParameters()
        {
            return parameters;
        }

        pure bool getSingle()
        {
            return single;
        }
}

class Sms : Message
{
    private:
        CHARSET charset;
        bool normalize;
        Pattern pattern;
        Sender sender;
        TYPE type;

    public:
        pure this(
            Sender sender,
            Receiver[] receivers,
            Content content,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.sender = sender;
            this.receivers = receivers;
            this.content = content;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            Sender sender,
            Receiver receiver,
            Content content,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.sender = sender;
            this.receivers = [receiver];
            this.content = content;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            TYPE type,
            Receiver[] receivers,
            Content content,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.type = type;
            this.receivers = receivers;
            this.content = content;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            TYPE type,
            Receiver receiver,
            Content content,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.type = type;
            this.receivers = [receiver];
            this.content = content;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            Sender sender,
            Receiver[] receivers,
            Pattern pattern,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.sender = sender;
            this.receivers = receivers;
            this.pattern = pattern;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            Sender sender,
            Receiver receiver,
            Pattern pattern,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.sender = sender;
            this.receivers = [receiver];
            this.pattern = pattern;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            TYPE type,
            Receiver[] receivers,
            Pattern pattern,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.type = type;
            this.receivers = receivers;
            this.pattern = pattern;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure this(
            TYPE type,
            Receiver receiver,
            Pattern pattern,
            CHARSET charset = CHARSET.DEFAULT,
            bool normalize = false
        ) {
            this.type = type;
            this.receivers = [receiver];
            this.pattern = pattern;
            this.charset = charset;
            this.normalize = normalize;
        }

        pure Sender getSender()
        {
            return sender;
        }

        pure TYPE getType()
        {
            return type;
        }

        pure Pattern getPattern()
        {
            return pattern;
        }
}

class SendSms : Method
{
    static const PATH path = PATH.SMS;

    private Sms sms;

    this(Sms sms)
    {
        this.sms = sms;
    }

    RequestBuilder getRequestBuilder()
    {
        string[] receivers;

        RequestBuilder requestBuilder = new RequestBuilder().setPath(path);

        if (sms.getSender().name) {
            requestBuilder.addParameter(new Parameter(PARAMETER.FROM, text(sms.getSender())));
        } else {
            requestBuilder.addParameter(new Parameter(PARAMETER.FROM, sms.getType()));
        }

        foreach (Receiver receiver; sms.getReceivers()) {
            receivers ~= text(receiver);
        }

        requestBuilder.addParameter(new Parameter(PARAMETER.TO, receivers));

        if (sms.charset != CHARSET.DEFAULT) {
            requestBuilder.addParameter(new Parameter(PARAMETER.ENCODING, sms.charset));
        }

        if (sms.normalize) {
            requestBuilder.addParameter(new Parameter(PARAMETER.NORMALIZE, "1"));
        }

        if (text(sms.content) != string.init) {
            requestBuilder.addParameter(new Parameter(PARAMETER.MESSAGE, text(sms.content)));
        } else {
            requestBuilder
                .addParameter(new Parameter(PARAMETER.PARAM_1, sms.pattern.getParameters().getFirst()))
                .addParameter(new Parameter(PARAMETER.PARAM_2, sms.pattern.getParameters().getSecond()))
                .addParameter(new Parameter(PARAMETER.PARAM_3, sms.pattern.getParameters().getThird()))
                .addParameter(new Parameter(PARAMETER.PARAM_4, sms.pattern.getParameters().getFourth()))
                .addParameter(new Parameter(PARAMETER.TEMPLATE, sms.pattern.getName()));

            if (sms.pattern.getSingle()) {
                requestBuilder.addParameter(new Parameter(PARAMETER.SINGLE, "1"));
            }
        }

        return requestBuilder;
    }
}