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

enum TYPE {
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

class Sms : Message
{
    private:
        string  charset;
        Sender  sender;
        TYPE    type;

    public:
        this(Sender sender, Receiver[] receivers, Content content, CHARSET charset = CHARSET.DEFAULT)
        {
            setSender(sender);
            setReceivers(receivers);
            setContent(content);
            setCharset(charset);
        }

        this(TYPE type, Receiver[] receivers, Content content, CHARSET charset = CHARSET.DEFAULT)
        {
            setType(type);
            setReceivers(receivers);
            setContent(content);
            setCharset(charset);
        }

        this(Sender sender, Receiver receiver, Content content, CHARSET charset = CHARSET.DEFAULT)
        {
            this(sender, [receiver], content, charset);
        }

        this(TYPE type, Receiver receiver, Content content, CHARSET charset = CHARSET.DEFAULT)
        {
            this(type, [receiver], content, charset);
        }

        Sender getSender()
        {
            return sender;
        }

        string getCharset()
        {
            return charset;
        }

        TYPE getType()
        {
            return type;
        }

    protected:
        Sms setSender(Sender value)
        {
            sender = value;

            return this;
        }

        Sms setCharset(string value)
        {
            charset = value;

            return this;
        }

        Sms setType(TYPE value)
        {
            type = value;

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
            string receivers;
            string from;

            foreach (Receiver receiver; getSms().getReceivers()) {
                receivers ~= "&to[]=" ~ encode(text(receiver));
            }

            if (getSms().getSender().name) {
                from = text(sms.getSender());
            } else {
                from = getSms().getType();
            }

            return
                PATH ~
                "?from=" ~  encode(from) ~
                receivers ~
                (getSms().getCharset() != CHARSET.DEFAULT ? "&encoding=" ~ encode(getSms().getCharset()) : "") ~
                "&message=" ~ encode(text(getSms().getContent()));
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