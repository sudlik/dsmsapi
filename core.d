module dsmsapi.core;

import std.array        : empty;
import std.conv         : to;
import std.socket       : InternetAddress, TcpSocket;
import std.socketstream : SocketStream;
import std.uri          : encode;

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

interface Method
{
    RequestBuilder getRequest();
}

enum HOST
{
    PLAIN_1 = "api.smsapi.pl",
    PLAIN_2 = "api2.smsapi.pl",
}

enum PATH : string
{
    SMS = "sms.do",
    MMS = "mms.do",
}

enum AGENT : string
{
    DSMSAPI = "dsmsapi",
}

enum PROTOCOL : string
{
    HTTP_11 = "HTTP/1.1",
}

enum METHOD : string
{
    POST = "post",
}

enum PORT : ushort
{
    P80 = 80,
}

enum PARAMETER : string
{
    USERNAME    = "username",
    PASSWORD    = "password",
    FORMAT      = "format",
    TEST        = "test",
    TO          = "to",
    FROM        = "from",
    ENCODING    = "encoding",
    NORMALIZE   = "normalize",
    MESSAGE     = "message",
    PARAM_1     = "param1",
    PARAM_2     = "param2",
    PARAM_3     = "param3",
    PARAM_4     = "param4",
    SINGLE      = "single",
    TEMPLATE    = "template",
    SUBJECT     = "subject",
    SMIL        = "smil",
}

class Parameter
{
    private:
        string name;
        string value;
        string[] values;

    this(string name, string value)
    {
        setName(name);
        setValue(value);
    }

    this(string name, string[] values)
    {
        setName(name);
        setValues(values);
    }

    string getName()
    {
        return value;
    }

    Parameter setName(string value)
    {
        name = value;

        return this;
    }

    string getValue()
    {
        return value;
    }

    Parameter setValue(string val)
    {
        value = encode(val);

        return this;
    }

    string[] getValues()
    {
        return values;
    }

    Parameter setValues(string[] vals)
    {
        foreach (string val; vals) {
            values[] = encode(val);
        }

        return this;
    }
}

class RequestBuilder
{
    private:
        AGENT agent;
        HOST host;
        METHOD method;
        Parameter[] parameters;
        PATH path;
        PORT port;
        PROTOCOL protocol;

    public:
        RequestBuilder setAgent(AGENT agent)
        {
            this.agent = agent;

            return this;
        }

        RequestBuilder setMethod(METHOD method)
        {
            this.method = method;

            return this;
        }

        RequestBuilder setProtocol(PROTOCOL protocol)
        {
            this.protocol = protocol;

            return this;
        }

        RequestBuilder setHost(HOST host)
        {
            this.host = host;

            return this;
        }

        RequestBuilder setPort(PORT port)
        {
            this.port = port;

            return this;
        }

        RequestBuilder setPath(PATH path)
        {
            this.path = path;

            return this;
        }

        RequestBuilder addParameter(Parameter parameter)
        {
            parameters[] = parameter;

            return this;
        }

        Request getRequest()
        {
            string headers = getMethod() ~ " /" ~ getPath();
            string singleValue;
            string[] multipleValues;

            foreach (int i, Parameter parameter; getParameters()) {
                if (!empty(parameter.getValues())) {
                    foreach (string value; parameter.getValues()) {
                        headers ~= (i == 1 ? "?" : "&") ~ parameter.getName() ~ "[]=" ~ value;
                    }
                } else {
                    headers ~= (i == 1 ? "?" : "&") ~ parameter.getName() ~ "=" ~ parameter.getValue();
                }
            }

            return (new RequestFactory).create(
                getHost(),
                getPort(),
                headers ~ " " ~ getProtocol() ~ "\r\nHost: "  ~ getHost() ~ "\r\nUser-Agent: " ~ getAgent() ~ "\r\n\r\n"
            );
        }

    protected:
        AGENT getAgent()
        {
            return agent;
        }

        METHOD getMethod()
        {
            return method;
        }

        PROTOCOL getProtocol()
        {
            return protocol;
        }

        HOST getHost()
        {
            return host;
        }

        PORT getPort()
        {
            return port;
        }

        PATH getPath()
        {
            return path;
        }

        Parameter[] getParameters()
        {
            return parameters;
        }
}

class Request
{
    private:
        string headers;
        SocketStream stream;

    public:
        this(HOST host, ushort port, string headers)
        {
            setStream((new SocketStreamFactory).create(host, port));
            setHeaders(headers);
        }

        string send()
        {
            string content;

            getStream().writeString(getHeaders());
            
            while (!getStream().eof()) {
                content ~= getStream().readLine();
            }

            return content;
        }
        
    protected:
        Request setStream(SocketStream value)
        {
            stream = value;

            return this;
        }

        SocketStream getStream()
        {
            return stream;
        }

        Request setHeaders(string headers)
        {
            this.headers = headers;

            return this;
        }

        string getHeaders()
        {
            return headers;
        }
}

class SocketStreamFactory
{
    SocketStream create(string host, ushort port)
    {
        return new SocketStream(new TcpSocket(new InternetAddress(host, port)));
    }
}

class RequestBuilderFactory
{
    RequestBuilder create()
    {
        return new RequestBuilder;
    }
}

class ParameterFactory
{
    Parameter create(string name, string value)
    {
        return new Parameter(name, value);
    }

    Parameter create(string name, string[] values)
    {
        return new Parameter(name, values);
    }
}

class RequestFactory
{
    Request create(HOST host, ushort port, string headers)
    {
        return new Request(host, port, headers);
    }
}