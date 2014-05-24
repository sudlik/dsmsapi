module dsmsapi.api;

import dsmsapi.core : Method;

import std.conv             : text;
import std.digest.digest    : toHexString;
import std.digest.md        : md5Of;
import std.socket           : InternetAddress, TcpSocket;
import std.socketstream     : SocketStream;
import std.stream           : Stream;
import std.uri              : encode;

enum HOST {
    PLAIN_1 = "api.smsapi.pl",
    PLAIN_2 = "api2.smsapi.pl",
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

class Api
{
    static const ushort PORT = 80;

    static const string
        METHOD              = "POST",
        USER_AGENT          = "dsmsapi",
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