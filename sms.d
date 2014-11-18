module dsmsapi.sms;

import core.time    : dur;
import std.array    : empty;
import std.conv     : text;
import std.datetime : Clock, DateTime, DateTimeException, SysTime;

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
    def         = "default",
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

struct SendDate
{
    private:
        DateTime expirationDate;
        bool     isImmediately = false;
        DateTime sendDate;

    public:
        @safe @property pure immutable DateTime expiration()
        {
            return expirationDate;
        }

        @safe @property pure immutable bool immediately()
        {
            return isImmediately;
        }

        @safe @property pure immutable DateTime send()
        {
            return sendDate;
        }

        this(DateTime send = DateTime.init, DateTime expiration = DateTime.init)
        {
            SysTime sendSysTime    = SysTime(send);
            long    timestamp      = sendSysTime.toUnixTime();
            SysTime currentSysTime = Clock.currTime();

            if (send == DateTime.init) {
                isImmediately = true;
            } else {
                currentSysTime.add!"months"(3);

                if (timestamp <= Clock.currTime().toUnixTime()) {
                    throw new TooLowSendDateException(send);
                } else if (timestamp > currentSysTime.toUnixTime()) {
                    throw new TooHighSendDateException(send);
                }

                sendDate = send;
            }

            if (expiration != DateTime.init) {
                setExpiration(expiration, sendSysTime);
            }
        }

    private:
        @safe void setExpiration(DateTime expiration, SysTime send)
        {
            long    timestamp = SysTime(expiration).toUnixTime();
            SysTime from      = send + dur!"minutes"(15);
            SysTime to        = send + dur!"hours"(48);

            if (timestamp < from.toUnixTime()) {
                throw new TooLowExpirationDateException(expiration);
            } else if (timestamp > to.toUnixTime()) {
                throw new TooHighExpirationDateException(expiration);
            }

            expirationDate = expiration;
        }
}

immutable struct Config
{
    Charset  charset;
    bool     normalize;
    SendDate sendDate;
    bool     single;
}

class TooLowExpirationDateException : Exception
{
    @safe pure this(DateTime expirationDate)
    {
        super("Too low expiration date: " ~ expirationDate.toSimpleString() ~ " (expirationDate > sendDate + 15 min)");
    }
}

class TooHighExpirationDateException : Exception
{
    @safe pure this(DateTime expirationDate)
    {
        super("Too high expiration date: " ~ expirationDate.toSimpleString() ~ " (expirationDate < cuurentDate + 48 hours)");
    }
}

class TooLowSendDateException : Exception
{
    @safe pure this(DateTime sendDate)
    {
        super("Too low send date: " ~ sendDate.toSimpleString() ~ " (sendDate > currentDate)");
    }
}

class TooHighSendDateException : Exception
{
    @safe pure this(DateTime sendDate)
    {
        super("Too high send date: " ~ sendDate.toSimpleString() ~ " (sendDate < currentDate + 3 months)");
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

class EmptyReceiversException : Exception
{
    @safe pure this()
    {
        super("Receivers can not be empty");
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
        SendDate   sendDate;

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

        @safe @property pure SendDate send(SendDate send)
        {
            return sendDate = send;
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

        @safe this(Content content, Receiver receiver)
        {
            this(content, [receiver]);
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
            return Config(messageCharset, normalizeMessage, sendDate, singleMessage);
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
            RequestBuilder requestBuilder = new RequestBuilder;

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

            if (sms.config.sendDate != SendDate.init) {
                if (sms.config.sendDate.immediately) {
                    requestBuilder.setParameter(
                        new Parameter(ParamName.date, text(SysTime(sms.config.sendDate.send).toUnixTime()))
                    );
                } else if (sms.config.sendDate.expiration != DateTime.init) {
                    requestBuilder.setParameter(
                        new Parameter(
                            ParamName.expirationDate,
                            text(SysTime(sms.config.sendDate.expiration).toUnixTime())
                        )
                    );
                }
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
