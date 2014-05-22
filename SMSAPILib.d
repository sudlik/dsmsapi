module SMSAPILib;

import std.conv             : text, to;
import std.digest.digest    : toHexString;
import std.digest.md        : md5Of;
import std.socket           : InternetAddress, TcpSocket;
import std.socketstream     : SocketStream;
import std.stream           : Stream;
import std.uri              : encode;

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

enum HOST {
    PLAIN_1 = "api.smsapi.pl",
    PLAIN_2 = "api2.smsapi.pl",
}

struct Sender
{
    string name;

    string toString()
    {
        return name;
    }
}

struct Receiver
{
    uint phone;

    string toString()
    {
        return to!string(phone);
    }
}

struct Content
{
    string content;

    string toString()
    {
        return content;
    }
}

struct Response
{
    string content;

    string toString()
    {
        return content;
    }
}

struct User
{
    string      name;
    ubyte[16]   hash;

    this(string name, ubyte[16] hash)
    {
        this.name = name;
        this.hash = hash;
    }

    this(string name, string pass)
    {
        this.name = name;
        this.hash = md5Of(pass);
    }
}

struct Subject
{
    string content;

    string toString()
    {
        return content;
    }
}

abstract class Message
{
    private:
        Receiver[]  receivers;
        Content     content;

    public:
        Receiver[] getReceivers()
        {
            return receivers;
        }

        Content getContent()
        {
            return content;
        }

    protected:
        Message setReceivers(Receiver[] value)
        {
            receivers = value;

            return this;
        }

        Message setContent(Content value)
        {
            content = value;

            return this;
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

interface Method
{
    string getPath();
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

class SendMms : Method
{
    static const string PATH = "mms.do";

    private Mms mms;

    public:
        this(Mms mms)
        {
            setMms(mms);
        }

        string getPath()
        {
            string receivers;

            foreach (Receiver receiver; getMms().getReceivers()) {
                receivers ~= "&to[]=" ~ encode(text(receiver));
            }

            return
                PATH ~
                "?subject=" ~  encode(text(mms.getSubject())) ~
                receivers ~
                "&smil=" ~ encode(text(mms.getContent()));
        }

    protected:
        Mms getMms()
        {
            return mms;
        }

        SendMms setMms(Mms value)
        {
            mms = value;

            return this;
        }
}

class Api
{
    static const ushort PORT = 80;

    static const string
        METHOD              = "POST",
        USER_AGENT          = "SMSAPILib.d",
        PROTOCOL_NAME       = "HTTP",
        PROTOCOL_VERSION    = "1.1";

    private:
        bool    test;
        HOST    host;
        Stream  stream;
        User    user;

    public:
        this(User user, HOST host, bool test = false)
        {
            setUser(user);
            setHost(host);
            setTest(test);
            setStream(createStream(getHost(), getPort()));
        }

        Response execute(Method method)
        {
            string content;

            getStream().writeString(buildHeaders(method.getPath()));
            
            while (!getStream().eof()) {
                content ~= getStream().readLine();
            }

            return Response(content);
        }

    protected:
        string buildHeaders(string path)
        {
            return
                getMethod() ~ " /" ~ path ~
                "&username=" ~ encode(getUser().name) ~
                "&password=" ~ encode(text(toHexString(getUser().hash))) ~
                "&format=json" ~
                (getTest() ? "&test=1" : "") ~
                " " ~
                getProtocolName() ~ "/" ~ getProtocolVersion() ~ "\r\n"
                "Host: "  ~ getHost() ~ "\r\n"
                "User-Agent: " ~ getUserAgent() ~ "\r\n\r\n";
        }

        User getUser()
        {
            return user;
        }

        bool getTest()
        {
            return test;
        }

        string getMethod()
        {
            return METHOD;
        }

        string getHost()
        {
            return host;
        }

        ushort getPort()
        {
            return PORT;
        }

        string getUserAgent()
        {
            return USER_AGENT;
        }

        string getProtocolName()
        {
            return PROTOCOL_NAME;
        }

        string getProtocolVersion()
        {
            return PROTOCOL_VERSION;
        }

        Api setUser(User value)
        {
            user = value;

            return this;
        }

        Api setTest(bool value)
        {
            test = value;

            return this;
        }

        Api setHost(HOST value)
        {
            host = value;

            return this;
        }
        
        SocketStream createStream(string host, ushort port)
        {
            return new SocketStream(new TcpSocket(new InternetAddress(host, port)));
        }

        Api setStream(SocketStream value)
        {
            stream = value;

            return this;
        }

        Stream getStream()
        {
            return stream;
        }
}