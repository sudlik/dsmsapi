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

struct Message
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

struct Smil
{
    string content;

    string toString()
    {
        return content;
    }
}

class Sms
{
    private:
        string      charset;
        Message     message;
        Receiver[]  receivers;
        Sender      sender;

    public:
        this(Sender sender, Receiver[] receivers, Message message, CHARSET charset = CHARSET.DEFAULT)
        {
            setSender(sender);
            setReceivers(receivers);
            setMessage(message);
            setCharset(charset);
        }

        this(Sender sender, Receiver receiver, Message message, CHARSET charset = CHARSET.DEFAULT)
        {
            setSender(sender);
            setReceivers([receiver]);
            setMessage(message);
            setCharset(charset);
        }

        Sender getSender()
        {
            return sender;
        }

        Receiver[] getReceivers()
        {
            return receivers;
        }

        Message getMessage()
        {
            return message;
        }

    protected:
        void setSender(Sender value)
        {
            sender = value;
        }

        string getCharset()
        {
            return charset;
        }

        void setReceivers(Receiver[] value)
        {
            receivers = value;
        }

        void setMessage(Message value)
        {
            message = value;
        }

        void setCharset(string value)
        {
            charset = value;
        }
}

class Mms
{
    private:
        Receiver[]  receivers;
        Smil        smil;
        Subject     subject;

    public:
        this(Subject subject, Receiver[] receivers, Smil smil)
        {
            setSubject(subject);
            setReceivers(receivers);
            setSmil(smil);
        }

        this(Subject subject, Receiver receiver, Smil smil)
        {
            setSubject(subject);
            setReceivers([receiver]);
            setSmil(smil);
        }

        Subject getSubject()
        {
            return subject;
        }

        Receiver[] getReceivers()
        {
            return receivers;
        }

        Smil getSmil()
        {
            return smil;
        }

    protected:
        Mms setSubject(Subject value)
        {
            subject = value;

            return this;
        }

        Mms setReceivers(Receiver[] value)
        {
            receivers = value;

            return this;
        }

        Mms setSmil(Smil value)
        {
            smil = value;

            return this;
        }
}

class Api
{
    static const ushort PORT = 80;

    static const string HOST                = "panel.localhost";
    static const string PATH                = "sms.do";
    static const string MMS_PATH            = "mms.do";
    static const string METHOD              = "METHOD";
    static const string USER_AGENT          = "SMSAPILib.d";
    static const string PROTOCOL_NAME       = "HTTP";
    static const string PROTOCOL_VERSION    = "1.1";

    private:
        bool    test;
        Stream  stream;
        User    user;

    public:
        this(User user, bool test = false)
        {
            setUser(user);
            setTest(test);
            setStream(createStream(getHost(), getPort()));
        }

        Response send(Sms sms)
        {
            string content;

            getStream().writeString(
                getMethod() ~ " /" ~ getPath() ~ asQuery(sms) ~ " " ~
                getProtocolName() ~ "/" ~ getProtocolVersion() ~ "\r\n"
                "Host: "  ~ getHost() ~ "\r\n"
                "User-Agent: " ~ getUserAgent() ~ "\r\n\r\n"
            );
            
            while (!getStream().eof()) {
                content ~= getStream().readLine();
            }

            return Response(content);
        }

        Response send(Mms mms)
        {
            string content;

            getStream().writeString(
                getMethod() ~ " /" ~ getMmsPath() ~ asQuery(mms) ~ " " ~
                getProtocolName() ~ "/" ~ getProtocolVersion() ~ "\r\n"
                "Host: "  ~ getHost() ~ "\r\n"
                "User-Agent: " ~ getUserAgent() ~ "\r\n\r\n"
            );
            
            while (!getStream().eof()) {
                content ~= getStream().readLine();
            }

            return Response(content);
        }

    protected:
        string asQuery(Sms value)
        {
            string receivers;

            foreach (Receiver receiver; value.getReceivers()) {
                receivers ~= "&to[]=" ~ encode(text(receiver));
            }

            return
                "?username=" ~ encode(getUser().name) ~
                "&password=" ~ encode(text(toHexString(getUser().hash))) ~
                "&from=" ~  encode(text(value.getSender())) ~
                receivers ~
                "&format=json" ~
                (value.getCharset() != CHARSET.DEFAULT ? "&encoding=" ~ encode(value.getCharset()) : "") ~
                (getTest() ? "&test=1" : "") ~
                "&message=" ~ encode(text(value.getMessage()));
        }

        string asQuery(Mms value)
        {
            string receivers;

            foreach (Receiver receiver; value.getReceivers()) {
                receivers ~= "&to[]=" ~ encode(text(receiver));
            }

            return
                "?username=" ~ encode(getUser().name) ~
                "&password=" ~ encode(text(toHexString(getUser().hash))) ~
                "&subject=" ~  encode(text(value.getSubject())) ~
                receivers ~
                "&format=json" ~
                (getTest() ? "&test=1" : "") ~
                "&smil=" ~ encode(text(value.getSmil()));
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

        string getPath()
        {
            return PATH;
        }

        string getMmsPath()
        {
            return MMS_PATH;
        }

        string getHost()
        {
            return HOST;
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