module dsmsapi.core;

debug import std.string : strip;
debug import std.stdio  : writeln;

import std.array        : empty;
import std.conv         : to;
import std.socketstream : SocketStream;
import std.uri          : encode;

import std.socket : InternetAddress, TcpSocket;

struct Receiver
{
    private uint phone;

    pure this(uint phone)
    {
        this.phone = phone;
    }

    pure string toString()
    {
        return to!string(phone);
    }

    pure uint getPhone()
    {
        return phone;
    }
}

struct Variable
{
    PARAMETER name;
    string    value;

    pure this(PARAMETER name, string value)
    {
        if (
            name == PARAMETER.PARAM_1
            || name == PARAMETER.PARAM_2
            || name == PARAMETER.PARAM_3
            || name == PARAMETER.PARAM_4
        ) {
            this.name  = name;
        } else {
            throw new Exception("Invalid name");
        }

        this.value = value;
    }

    pure string getName()
    {
        return name;
    }

    pure string getValue()
    {
        return value;
    }
}

struct VariableCollection
{
    private Variable[] variables;

    pure Variable[] all()
    {
        return variables;
    }

    VariableCollection set(Variable[] variables)
    {
        foreach (Variable variable; variables) {
            add(variable);
        }

        return this;
    }

    VariableCollection add(Variable variable)
    {
        foreach (Variable var; variables) {
            if (variable.getName() == var.getName()) {
                throw new Exception("Variable already added");
            }
        }

        variables ~= variable;

        return this;
    }
}

class Content
{
    private {
        string             value;
        VariableCollection variableCollection;
    }

    pure this(string value, VariableCollection variableCollection = VariableCollection())
    {
        this.value = value;
        this.variableCollection = variableCollection;
    }

    override pure string toString()
    {
        return value;
    }

    pure string getValue()
    {
        return value;
    }

    pure VariableCollection getVariableCollection()
    {
        return variableCollection;
    }
}

abstract class Message
{
    protected:
        Receiver[]  receivers;
        Content     content;

    public:
        pure Receiver[] getReceivers()
        {
            return receivers;
        }

        pure Content getContent()
        {
            return content;
        }
}

interface Method
{
    RequestBuilder getRequestBuilder();
}

enum HOST : string
{
    PLAIN_1 = "api.smsapi.pl",
    PLAIN_2 = "api2.smsapi.pl",
    ***REMOVED***
}

enum PATH : string
{
    HLR = "hlr.do",
    MMS = "mms.do",
    SMS = "sms.do",
    VMS = "vms.do",
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
    POST = "POST",
}

enum PORT : ushort
{
    P80 = 80,
}

enum PARAMETER : string
{
    DATE      = "date",
    ENCODING  = "encoding",
    FORMAT    = "format",
    FROM      = "from",
    IDX       = "idx",
    MESSAGE   = "message",
    NORMALIZE = "normalize",
    NUMBER    = "number",
    PARAM_1   = "param1",
    PARAM_2   = "param2",
    PARAM_3   = "param3",
    PARAM_4   = "param4",
    PASSWORD  = "password",
    SINGLE    = "single",
    SMIL      = "smil",
    SUBJECT   = "subject",
    TEMPLATE  = "template",
    TEST      = "test",
    TTS       = "tts",
    TO        = "to",
    USERNAME  = "username",
}

class Parameter
{
    private:
        string name;
        string value;
        string[] values;

    public:
        this(string name, string value)
        {
            this.name = name;

            setValue(value);
        }

        this(string name, string[] values)
        {
            this.name = name;

            setValues(values);
        }

        pure string getName()
        {
            return name;
        }

        pure string getValue()
        {
            return value;
        }

        pure string[] getValues()
        {
            return values;
        }

    private:
        Parameter setValue(string value)
        {
            this.value = encode(value);

            return this;
        }

        Parameter setValues(string[] values)
        {
            foreach (string value; values) {
                this.values ~= encode(value);
            }

            return this;
        }
}

class RequestBuilder
{
    private:
        AGENT             agent;
        HOST              host;
        METHOD            method;
        Parameter[string] parameters;
        PATH              path;
        PORT              port;
        PROTOCOL          protocol;

    public:
        pure RequestBuilder setAgent(AGENT agent)
        {
            this.agent = agent;

            return this;
        }

        pure RequestBuilder setMethod(METHOD method)
        {
            this.method = method;

            return this;
        }

        pure RequestBuilder setProtocol(PROTOCOL protocol)
        {
            this.protocol = protocol;

            return this;
        }

        pure RequestBuilder setHost(HOST host)
        {
            this.host = host;

            return this;
        }

        pure RequestBuilder setPort(PORT port)
        {
            this.port = port;

            return this;
        }

        pure RequestBuilder setPath(PATH path)
        {
            this.path = path;

            return this;
        }

        pure RequestBuilder setParameter(Parameter parameter)
        {
            parameters[parameter.getName()] = parameter;

            return this;
        }

        Request getRequest()
        {
            bool first = true;
            string headers = method ~ " /" ~ path;

            foreach (string name, Parameter parameter; parameters) {
                if (!empty(parameter.getValues())) {
                    foreach (string value; parameter.getValues()) {
                        headers ~= (first ? "?" : "&") ~ name ~ "[]=" ~ value;

                        first = false;
                    }
                } else {
                    headers ~= (first ? "?" : "&") ~ name ~ "=" ~ parameter.getValue();
                }

                first = false;
            }

            return new Request(
                host,
                port,
                headers ~ " " ~ protocol ~ "\r\nHost: "  ~ host ~ "\r\nUser-Agent: " ~ agent ~ "\r\n\r\n"
            );
        }
}

class Request
{
    private:
        string headers;
        SocketStream socketStream;

    public:
        this(HOST host, ushort port, string headers)
        {
            this.socketStream = new SocketStreamFactory().create(host, port);
            this.headers = headers;

            debug {
                writeln("[DEBUG] REQUEST HEADERS:");
                writeln(strip(headers));
            }
        }

        string send()
        {
            string content;

            debug (WITHOUT_SEND) {
                writeln("[DEBUG] WITHOUT SEND");

                return `0{"error":0,"message":""}0`;
            } else {
                socketStream.writeString(headers);

                while (!socketStream.eof()) {
                    content ~= socketStream.readLine();
                }

                debug {
                    writeln("[DEBUG] RESPONSE:");
                    writeln(content);
                }

                return content;
            }
        }
}

class SocketStreamFactory
{
    SocketStream create(string host, ushort port)
    {
        return new SocketStream(new TcpSocket(new InternetAddress(host, port)));
    }
}
