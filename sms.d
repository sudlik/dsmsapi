module dsmsapi.sms;

import std.array : empty;
import std.conv  : text;

import dsmsapi.core :
    Content,
    Message,
    Method,
    Parameter,
    PARAMETER,
    PATH,
    Receiver,
    RequestBuilder,
    Variable,
    VariableCollection;

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
    ECO     = "ECO",
    PRO     = "",
    TWO_WAY = "2Way",
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

class Pattern : Content
{
    pure this(string value)
    {
        super(value);
    }

    pure this(string value, VariableCollection variableCollection)
    {
        super(value, variableCollection);
    }
}

abstract class Sms : Message
{
    private:
        Config config;
        Sender sender;
        TYPE   type;

    public:
        pure Sender getSender()
        {
            return sender;
        }

        pure TYPE getType()
        {
            return type;
        }

        pure Config getConfig()
        {
            return config;
        }

    protected:
        this(TYPE type, Sender sender, Receiver[] receivers, Content content, Config config)
        {
            this.type      = type;
            this.sender    = sender;
            this.receivers = receivers;
            this.config    = config;
            this.content   = content;
        }

        this(TYPE type, Receiver[] receivers, Content content, Config config)
        {
            this(type, Sender(), receivers, content, config);
        }
}

class Eco : Sms
{
    this(Receiver[] receivers, Content content, Config config)
    {
        super(TYPE.ECO, receivers, content, config);
    }
}

class Pro : Sms
{
    this(Sender sender, Receiver[] receivers, Content content, Config config)
    {
        super(TYPE.PRO, sender, receivers, content, config);
    }
}

class TwoWay : Sms
{
    this(Receiver[] receivers, Content content, Config config)
    {
        super(TYPE.TWO_WAY, receivers, content, config);
    }
}

struct Config
{
    private:
        CHARSET charset;
        bool    normalize;
        bool    single;

    public:
        pure this(CHARSET charset = CHARSET.DEFAULT, bool normalize = false, bool single = false)
        {
            this.charset   = charset;
            this.normalize = normalize;
            this.single    = single;
        }

        pure getCharset()
        {
            return charset;
        }

        pure getNormalize()
        {
            return normalize;
        }

        pure getSingle()
        {
            return single;
        }
}

struct Builder
{
    private:
        CHARSET            charset = CHARSET.DEFAULT;
        Content            content;
        bool               normalize = false;
        VariableCollection variableCollection = VariableCollection();
        Receiver[]         receivers;
        Sender             sender;
        bool               single = false;

    public:
        pure this(Sender sender, Content content)
        {
            this.sender  = sender;
            this.content = content;
        }

        pure this(Content content)
        {
            this.content = content;
        }

        pure Builder setNormalize(bool normalize)
        {
            this.normalize = normalize;

            return this;
        }
        
        pure Builder setSingle(bool single)
        {
            this.single = single;

            return this;
        }
        
        pure Builder setCharset(CHARSET charset)
        {
            this.charset = charset;

            return this;
        }
        
        pure Builder addReceiver(Receiver receiver)
        {
            this.receivers ~= receiver;

            return this;
        }
        
        pure Builder setReceivers(Receiver[] receivers)
        {
            this.receivers = receivers;

            return this;
        }
        
        pure Builder setVariableCollection(VariableCollection variableCollection)
        {
            this.variableCollection = variableCollection;

            return this;
        }
        
        Builder setVariables(Variable[] variables)
        {
            this.variableCollection.set(variables);

            return this;
        }
        
        Builder addVariable(Variable variable)
        {
            this.variableCollection.add(variable);

            return this;
        }

        Eco getEco()
        {
            return new Eco(receivers, getContent(), getConfig());
        }

        Pro getPro()
        {
            return new Pro(sender, receivers, getContent(), getConfig());
        }

        TwoWay getTwoWay()
        {
            return new TwoWay(receivers, getContent(), getConfig());
        }

        private:
            Config getConfig()
            {
                return Config(charset, normalize, single);
            }

            Content getContent()
            {
                Content content = this.content;

                if (!empty(variableCollection.all())) {
                    if(cast(Pattern)this.content) {
                        content = new Pattern(this.content.getValue(), this.variableCollection);
                    } else {
                        content = new Content(this.content.getValue(), this.variableCollection);
                    }
                }
                
                return content;
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
            requestBuilder.setParameter(new Parameter(PARAMETER.FROM, text(sms.getSender())));
        } else {
            requestBuilder.setParameter(new Parameter(PARAMETER.FROM, sms.getType()));
        }

        foreach (Receiver receiver; sms.getReceivers()) {
            receivers ~= text(receiver);
        }

        requestBuilder.setParameter(new Parameter(PARAMETER.TO, receivers));

        if (sms.getConfig().charset != CHARSET.DEFAULT) {
            requestBuilder.setParameter(new Parameter(PARAMETER.ENCODING, sms.getConfig().charset));
        }

        if (sms.getConfig().normalize) {
            requestBuilder.setParameter(new Parameter(PARAMETER.NORMALIZE, "1"));
        }

        if (sms.getConfig().getSingle()) {
            requestBuilder.setParameter(new Parameter(PARAMETER.SINGLE, "1"));
        }

        foreach (Variable variable; sms.getContent().getVariableCollection().all()) {
            requestBuilder.setParameter(new Parameter(variable.getName(), variable.getValue()));
        }

        if (cast(Pattern)sms.getContent()) {
            requestBuilder.setParameter(new Parameter(PARAMETER.TEMPLATE, sms.getContent().getValue()));
        } else {
            requestBuilder.setParameter(new Parameter(PARAMETER.MESSAGE, sms.getContent().getValue()));
        }

        return requestBuilder;
    }
}