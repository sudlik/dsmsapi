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
    immutable string name;
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
    immutable {
        Config config;
        Sender sender;
        TYPE   type;
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
    immutable:
        CHARSET charset;
        ulong   date;
        bool    normalize;
        bool    single;
}

struct Builder
{
    private {
        CHARSET            charset            = CHARSET.DEFAULT;
        bool               normalize          = false;
        bool               single             = false;
        VariableCollection variableCollection = VariableCollection();

        Content    content;
        ulong      date;
        Receiver[] receivers;
        Sender     sender;
    }

    this(Sender sender, Content content, Receiver[] receivers)
    {
        this.sender  = sender;
        this.content = content;

        setReceivers(receivers);
    }

    this(Content content, Receiver[] receivers)
    {
        this.content = content;

        setReceivers(receivers);
    }

    pure this(Content content, Receiver receiver)
    {
        this.content   = content;
        this.receivers = [receiver];
    }

    pure Builder setCharset(CHARSET charset)
    {
        this.charset = charset;

        return this;
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

    pure Builder setDate(ulong date)
    {
        this.date = date;

        return this;
    }

    pure Builder setContent(Content content)
    {
        this.content = content;

        return this;
    }

    Builder setReceivers(Receiver[] receivers)
    {
        if (empty(receivers)) {
            throw new Exception("Receivers can not be empty");
        } else {
            this.receivers = receivers;
        }

        return this;
    }

    pure Builder addReceiver(Receiver receiver)
    {
        this.receivers ~= receiver;

        return this;
    }

    pure Builder setVariables(VariableCollection variables)
    {
        variableCollection = variables;

        return this;
    }

    Builder setVariables(Variable[] variables)
    {
        variableCollection.set(variables);

        return this;
    }

    Builder addVariable(Variable variable)
    {
        variableCollection.add(variable);

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
            return Config(charset, date, normalize, single);
        }

        Content getContent()
        {
            if (!empty(variableCollection.all())) {
                if(cast(Pattern)this.content) {
                    return new Pattern(this.content.getValue(), this.variableCollection);
                } else {
                    return new Content(this.content.getValue(), this.variableCollection);
                }
            } else {
                return this.content;
            }
        }
}

class Send : Method
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

        if (sms.sender.name) {
            requestBuilder.setParameter(new Parameter(PARAMETER.FROM, sms.sender.name));
        } else {
            requestBuilder.setParameter(new Parameter(PARAMETER.FROM, sms.type));
        }

        foreach (Receiver receiver; sms.receivers) {
            receivers ~= text(receiver);
        }

        requestBuilder.setParameter(new Parameter(PARAMETER.TO, receivers));

        if (sms.config.charset != CHARSET.DEFAULT) {
            requestBuilder.setParameter(new Parameter(PARAMETER.ENCODING, sms.config.charset));
        }

        if (sms.config.date != ulong.init) {
            requestBuilder.setParameter(new Parameter(PARAMETER.DATE, text(sms.config.date)));
        }

        if (sms.config.normalize) {
            requestBuilder.setParameter(new Parameter(PARAMETER.NORMALIZE, "1"));
        }

        if (sms.config.single) {
            requestBuilder.setParameter(new Parameter(PARAMETER.SINGLE, "1"));
        }

        foreach (Variable variable; sms.content.getVariableCollection().all()) {
            requestBuilder.setParameter(new Parameter(variable.getName(), variable.getValue()));
        }

        if (cast(Pattern)sms.content) {
            requestBuilder.setParameter(new Parameter(PARAMETER.TEMPLATE, sms.content.getValue()));
        } else {
            requestBuilder.setParameter(new Parameter(PARAMETER.MESSAGE, sms.content.getValue()));
        }

        return requestBuilder;
    }
}
