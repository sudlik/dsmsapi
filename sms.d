module dsmsapi.sms;

import std.array    : empty;
import std.conv     : text;
import std.datetime : DateTime, DateTimeException, SysTime;

import dsmsapi.core :
    Content,
    InvalidDateStringException,
    InvalidTimestampException,
    Message,
    Method,
    Parameter,
    ParamName,
    Receiver,
    RequestBuilder,
    Resource,
    Variable,
    VariableCollection;

enum Charset : string
{
    def         = string.init,
    iso88591    = "iso-8859-1",
    iso88592    = "iso-8859-2",
    iso88593    = "iso-8859-3",
    iso88594    = "iso-8859-4",
    iso88595    = "iso-8859-5",
    iso88597    = "iso-8859-7",
    utf8        = "utf-8",
    windows1250 = "windows-1250",
    windows1251 = "windows-1251",
}

enum Type : string
{
    eco    = "ECO",
    pro    = "PRO",
    twoWay = "2Way",
}

immutable struct Sender
{
    string name;
}

class InvalidExpirationDateException : Exception
{
    @safe pure this(DateTime dateTime)
    {
        super("Invalid expiration date: " ~ dateTime ~ ". Expiration date must be ");
    }
}

immutable struct Config
{
    Charset  charset;
    DateTime expiration;
    bool     normalize;
    DateTime send;
    bool     single;
    
    this(Charset  charset, DateTime expiration, bool normalize, DateTime send, bool single)
    {
        if ((SysTime(sms.config.send).toUnixTime() + 900) > (SysTime(sms.config.expiration).toUnixTime()) {
            throw new InvalidExpirationDateException();
        }
        
        Charset  = charset;
        DateTime = expiration;
        bool     = normalize;
        DateTime = send;
        bool     = single;
    }
}

abstract class Sms : Message
{
    immutable {
        Config config;
        Sender sender;
        Type   type;
    }

    protected:
        @safe pure this(Type type, Sender sender, Receiver[] receivers, Content content, Config config)
        {
            this.type        = type;
            this.sender      = sender;
            messageReceivers = receivers;
            messageContent   = content;
            this.config      = config;
        }

        @safe pure this(Type type, Receiver[] receivers, Content content, Config config)
        {
            this(type, Sender(), receivers, content, config);
        }
}

class Pattern : Content
{
    @safe pure this(string value)
    {
        super(value);
    }

    @safe pure this(string value, VariableCollection variableCollection)
    {
        super(value, variableCollection);
    }
}

class Eco : Sms
{
    @safe pure this(Receiver[] receivers, Content content, Config config)
    {
        super(Type.eco, receivers, content, config);
    }
}

class Pro : Sms
{
    @safe pure this(Sender sender, Receiver[] receivers, Content content, Config config)
    {
        super(Type.pro, sender, receivers, content, config);
    }
}

class TwoWay : Sms
{
    @safe pure this(Receiver[] receivers, Content content, Config config)
    {
        super(Type.twoWay, receivers, content, config);
    }
}

class EmptyReceiversException : Exception
{
    @safe pure this(string message = string.init)
    {
        super("Receivers can not be empty");
    }
}

class Builder
{
    private:
        Charset            messageCharset     = Charset.init;
        bool               normalizeMessage   = false;
        bool               singleMessage      = false;
        VariableCollection variableCollection = new VariableCollection;

        Content    content;
        Receiver[] receivers;
        Sender     sender;
        DateTime   sendDate;

    public:
        @safe @property pure Charset charset(Charset charset)
        {
            return messageCharset = charset;
        }

        @safe @property pure bool normalize(bool normalize)
        {
            return normalizeMessage = normalize;
        }

        @safe @property pure bool single(bool single)
        {
            return singleMessage = single;
        }

        @safe @property pure DateTime send(ulong timestamp)
        {
            DateTime dateTime = DateTime(1970, 1, 1);

            dateTime.roll!"seconds"(timestamp);

            return sendDate = dateTime;
        }

        @safe @property pure DateTime send(string date)
        {
            DateTime dateTime;

            try {
                dateTime = DateTime.fromISOString(date);
            } catch (DateTimeException exception) {
                try {
                    dateTime = DateTime.fromISOExtString(date);
                } catch (DateTimeException exception) {
                    try {
                        dateTime = DateTime.fromSimpleString(date);
                    } catch (DateTimeException exception) {
                        throw new InvalidDateStringException(date);
                    }
                }
            }

            return sendDate = dateTime;
        }

        @safe @property pure DateTime send(DateTime dateTime)
        {
            return sendDate = dateTime;
        }

        @safe @property pure DateTime expiration(ulong timestamp)
        {
            DateTime dateTime = DateTime(1970, 1, 1);

            dateTime.roll!"seconds"(timestamp);

            return expirationDate = dateTime;
        }

        @safe @property pure DateTime expiration(string date)
        {
            DateTime dateTime;

            try {
                dateTime = DateTime.fromISOString(date);
            } catch (DateTimeException exception) {
                try {
                    dateTime = DateTime.fromISOExtString(date);
                } catch (DateTimeException exception) {
                    try {
                        dateTime = DateTime.fromSimpleString(date);
                    } catch (DateTimeException exception) {
                        throw new InvalidDateStringException(date);
                    }
                }
            }

            return expirationDate = dateTime;
        }

        @safe @property pure DateTime expiration(DateTime dateTime)
        {
            return expirationDate = dateTime;
        }

        @safe @property pure VariableCollection variables(VariableCollection variables)
        {
            return variableCollection = variables;
        }

        @safe this(Sender sender, Content content, Receiver[] receivers)
        {
            this.sender  = sender;
            this.content = content;

            setReceivers(receivers);
        }

        @safe this(Content content, Receiver[] receivers)
        {
            this.content = content;

            setReceivers(receivers);
        }

        @safe pure this(Content content, Receiver receiver)
        {
            this.content   = content;
            this.receivers = [receiver];
        }

        @safe Eco createEco()
        {
            return new Eco(receivers, createContent(), createConfig());
        }

        @safe Pro createPro()
        {
            return new Pro(sender, receivers, createContent(), createConfig());
        }

        @safe TwoWay createTwoWay()
        {
            return new TwoWay(receivers, createContent(), createConfig());
        }

    private:
        @safe Builder setReceivers(Receiver[] receivers)
        {
            if (empty(receivers)) {
                throw new EmptyReceiversException;
            } else {
                this.receivers = receivers;
            }

            return this;
        }

        @safe Config createConfig()
        {
            return Config(messageCharset, expirationDate, normalizeMessage, sendDate, singleMessage);
        }

        @safe Content createContent()
        {
            if (!empty(variableCollection.all())) {
                if(cast(Pattern)this.content) {
                    return new Pattern(this.content.value, this.variableCollection);
                } else {
                    return new Content(this.content.value, this.variableCollection);
                }
            } else {
                return this.content;
            }
        }
}

class Send : Method
{
    private:
        static const Resource resource = Resource.sms;

        Sms sms;

    public:
        @safe pure this(Sms sms)
        {
            this.sms = sms;
        }

        RequestBuilder createRequestBuilder()
        {
            RequestBuilder requestBuilder      = new RequestBuilder;
            long           sendTimestamp       = SysTime(sms.config.send).toUnixTime();
            long           expirationTimestamp = SysTime(sms.config.expiration).toUnixTime();

            string[] receivers;
            string   from;

            requestBuilder.resource = resource;

            if (sms.sender.name) {
                from = sms.sender.name;
            } else {
                from = sms.type;
            }
            requestBuilder.setParameter(new Parameter(ParamName.from, from));

            foreach (Receiver receiver; sms.receivers) {
                receivers ~= text(receiver);
            }

            requestBuilder.setParameter(new Parameter(ParamName.to, receivers));

            if (sms.config.charset != Charset.init) {
                requestBuilder.setParameter(new Parameter(ParamName.encoding, sms.config.charset));
            }

            if (sendTimestamp > SysTime().toUnixTime()) {
                requestBuilder.setParameter(new Parameter(ParamName.date, text(sendTimestamp)));
            }

            if (expirationTimestamp > SysTime().toUnixTime()) {
                requestBuilder.setParameter(new Parameter(ParamName.date, text(expirationTimestamp)));
            }

            if (sms.config.normalize) {
                requestBuilder.setParameter(new Parameter(ParamName.normalize, "1"));
            }

            if (sms.config.single) {
                requestBuilder.setParameter(new Parameter(ParamName.single, "1"));
            }

            foreach (Variable variable; sms.content.variables.all()) {
                requestBuilder.setParameter(new Parameter(variable.name, variable.value));
            }

            if (cast(Pattern)sms.content) {
                requestBuilder.setParameter(new Parameter(ParamName.tmpl, sms.content.value));
            } else {
                requestBuilder.setParameter(new Parameter(ParamName.message, sms.content.value));
            }

            return requestBuilder;
        }
}
