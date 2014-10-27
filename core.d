module dsmsapi.core;

debug {
    import std.stdio  : writeln;
    import std.string : strip;
}

debug (WITHOUT_SEND) {
    import std.stdio  : writeln;
    import std.string : strip;
}

import std.array        : empty;
import std.conv         : to;
import std.socketstream : SocketStream;
import std.uri          : encode;

import std.socket: InternetAddress, TcpSocket;

enum Host : string
{
    plain1 = "api.smsapi.pl",
    plain2 = "api2.smsapi.pl",
}

enum Path : string
{
    hlr = "hlr.do",
    mms = "mms.do",
    sms = "sms.do",
    vms = "vms.do",
}

enum ParamName : string
{
    date      = "date",
    encoding  = "encoding",
    format    = "format",
    from      = "from",
    idx       = "idx",
    message   = "message",
    normalize = "normalize",
    number    = "number",
    param1    = "param1",
    param2    = "param2",
    param3    = "param3",
    param4    = "param4",
    password  = "password",
    single    = "single",
    smil      = "smil",
    subject   = "subject",
    tmpl      = "template",
    test      = "test",
    tts       = "tts",
    to        = "to",
    username  = "username",
}

struct Receiver
{
    immutable uint phone;

    pure string toString()
    {
        return to!string(phone);
    }
}

immutable struct Variable
{
    ParamName name;
    string    value;

    pure this(ParamName paramName, string val)
    {
        name  = paramName;
        value = val;
    }
}

class Content
{
    private VariableCollection variableCollection;

    @property pure VariableCollection variables()
    {
        return variableCollection;
    }

    immutable string value;

    pure this(string content, VariableCollection variables = new VariableCollection)
    {
        value = content;
        variableCollection = variables;
    }

    pure override string toString()
    {
        return value;
    }
}

class VariableAlreadyAddedException : Exception
{
    pure this(string name)
    {
        super("Variable already added: " ~ name);
    }
}

class VariableCollection
{
    private Variable[] variables;

    @property pure Variable[] all()
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
            if (variable.name == var.name) {
                throw new VariableAlreadyAddedException(variable.name);
            }
        }

        variables ~= variable;

        return this;
    }
}

interface Method
{
    private static const Path path;

    RequestBuilder createRequestBuilder();
}

abstract class Message
{
    Receiver[]  messageReceivers;
    Content     messageContent;

    @property pure Receiver[] receivers()
    {
        return messageReceivers;
    }

    @property pure Content content()
    {
        return messageContent;
    }
}

class Parameter
{
    immutable {
        string   name;
        string   value;
        string[] values;
    }

    this(string name, string value)
    {
        this.name = name;
        this.value = encode(value);
        this.values = [];
    }

    this(string name, string[] values)
    {
        string[] vals;

        this.name = name;
        this.value = string.init;

        foreach (string value; values) {
            vals ~= encode(value);
        }

        this.values = to!(immutable string[])(vals);
    }
}

class RequestBuilder
{
    private:
        string            userAgent;
        Host              serverHost;
        string            requestMethod;
        Parameter[string] parameters;
        Path              requestPath;
        ushort            serverPort;
        string            requestProtocol;

    public:
        @property pure string agent(string agent)
        {
            return userAgent = agent;
        }

        @property pure string method(string method)
        {
            return requestMethod = method;
        }

        @property pure string protocol(string protocol)
        {
            return requestProtocol = protocol;
        }

        @property pure Host host(Host host)
        {
            return serverHost = host;
        }

        @property pure ushort port(ushort port)
        {
            return serverPort = port;
        }

        @property pure Path path(Path path)
        {
            return requestPath = path;
        }

        pure RequestBuilder setParameter(Parameter parameter)
        {
            parameters[parameter.name] = parameter;

            return this;
        }

        Request create()
        {
            bool first = true;
            string headers = requestMethod ~ " /" ~ requestPath;

            foreach (string name, Parameter parameter; parameters) {
                if (!empty(parameter.values)) {
                    foreach (string value; parameter.values) {
                        headers ~= (first ? "?" : "&") ~ name ~ "[]=" ~ value;

                        first = false;
                    }
                } else {
                    headers ~= (first ? "?" : "&") ~ name ~ "=" ~ parameter.value;
                }

                first = false;
            }

            return new Request(
                serverHost,
                serverPort,
                headers ~ " "
                    ~ requestProtocol
                    ~ "\r\nHost: " ~ serverHost
                    ~ "\r\nUser-Agent: " ~ userAgent ~ "\r\n\r\n"
            );
        }
}

class Request
{
    private:
        string headers;
        SocketStream socketStream;

    public:
        this(Host host, ushort port, string headers)
        {
            this.socketStream = new SocketStreamFactory().create(host, port);
            this.headers      = headers;

            debug {
                writeln("[DEBUG] REQUEST HEADERS:");
                writeln(strip(headers));
            }

            debug (WITHOUT_SEND) {
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
