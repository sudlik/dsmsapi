module dsmsapi.sms;

import dsmsapi.core : Content, Message, Method, Receiver;

import std.conv         : text;
import std.digest.md    : md5Of;
import std.uri          : encode;

enum CHARSET : string {
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

enum TYPE : string {
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
    string
        first,
        second,
        third,
        fourth;
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
    static const string PATH = "sms.do";

    private Sms sms;

    public:
        this(Sms sms)
        {
            setSms(sms);
        }

        string getPath()
        {
            Content content = getSms().getContent();
            string from;
            Pattern pattern = getSms().getPattern();
            Parameters parameters = pattern.getParameters();
            string receivers;

            if (getSms().getSender().name) {
                from = text(sms.getSender());
            } else {
                from = getSms().getType();
            }

            foreach (Receiver receiver; getSms().getReceivers()) {
                receivers ~= "&to[]=" ~ encode(text(receiver));
            }

            if (text(content) != string.init) {
                return
                    PATH ~
                    "?from=" ~  encode(from) ~
                    receivers ~
                    (getSms().getCharset() != CHARSET.DEFAULT ? "&encoding=" ~ encode(getSms().getCharset()) : "") ~
                    (getSms().getNormalize() ? "&normalize=1" : "") ~
                    "&message=" ~ encode(text(content));
            } else {
                return
                    PATH ~
                    "?from=" ~  encode(from) ~
                    receivers ~
                    (parameters.first ? "&param1=" ~ encode(parameters.first) : "") ~
                    (parameters.second ? "&param2=" ~ encode(parameters.second) : "") ~
                    (parameters.third ? "&param3=" ~ encode(parameters.third) : "") ~
                    (parameters.fourth ? "&param4=" ~ encode(parameters.fourth) : "") ~
                    (getSms().getCharset() != CHARSET.DEFAULT ? "&encoding=" ~ encode(getSms().getCharset()) : "") ~
                    (getSms().getNormalize() ? "&normalize=1" : "") ~
                    (pattern.getSingle() ? "&single=1" : "") ~
                    "&template=" ~ encode(pattern.getName());
            }
        }

    protected:
        Sms getSms()
        {
            return sms;
        }

        SendSms setSms(Sms value)
        {
            sms = value;

            return this;
        }
}