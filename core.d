module dsmsapi.core;

version (linux) {
    pragma(lib, ":libcurl.so.4");
    pragma(lib, "phobos2");
}

debug {
    import std.stdio  : writeln;
    import std.string : strip;
}

debug (WITHOUT_SEND) {
    import std.stdio  : writeln;
    import std.string : strip;
}

import std.array    : empty;
import std.conv     : to;
import std.net.curl : get;
import std.uri      : encode;

enum Server : string
{
    def         = "https://ssl.smsapi.pl/",
    alternative = "https://ssl2.smsapi.pl/",
}

enum Resource : string
{
    hlr = "hlr.do?",
    mms = "mms.do?",
    sms = "sms.do?",
    vms = "vms.do?",
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

    @safe pure string toString()
    {
        return to!string(phone);
    }
}

immutable struct Variable
{
    ParamName name;
    string    value;

    @safe pure this(ParamName paramName, string val)
    {
        name  = paramName;
        value = val;
    }
}

class InvalidDateStringException : Exception
{
    @safe pure this(string dateTime)
    {
        super("Invalid date string: " ~ dateTime);
    }
}

class InvalidTimestampException : Exception
{
    @safe pure this(ulong timestamp)
    {
        super("Timestamp is invalid: " ~ to!string(timestamp) ~ ". Set future date or omit it.");
    }
}

class VariableAlreadyAddedException : Exception
{
    @safe pure this(string name)
    {
        super("Variable already added: " ~ name);
    }
}

class Content
{
    private VariableCollection variableCollection;

    immutable string value;

    @safe @property pure VariableCollection variables()
    {
        return variableCollection;
    }

    @safe pure this(string content, VariableCollection variables = new VariableCollection)
    {
        value              = content;
        variableCollection = variables;
    }

    @safe pure override string toString()
    {
        return value;
    }
}

class VariableCollection
{
    private Variable[] variables;

    @safe @property pure Variable[] all()
    {
        return variables;
    }

    @safe VariableCollection set(Variable[] variables)
    {
        foreach (Variable variable; variables) {
            add(variable);
        }

        return this;
    }

    @safe VariableCollection add(Variable variable)
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
    private static const Resource resource;

    RequestBuilder createRequestBuilder();
}

abstract class Message
{
    Receiver[]  messageReceivers;
    Content     messageContent;

    @safe @property pure Receiver[] receivers()
    {
        return messageReceivers;
    }

    @safe @property pure Content content()
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
        this.name   = name;
        this.value  = encode(value);
        this.values = [];
    }

    this(string name, string[] values)
    {
        string[] vals;

        this.name  = name;
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
        Resource          methodResource;
        Parameter[string] parameters;
        Server            serverName;

    public:
        @safe @property pure Resource resource(Resource resource)
        {
            return methodResource = resource;
        }

        @safe @property pure Server server(Server server)
        {
            return serverName = server;
        }

        @safe pure RequestBuilder setParameter(Parameter parameter)
        {
            parameters[parameter.name] = parameter;

            return this;
        }

        Request create()
        {
            bool first = true;
            string url = serverName ~ methodResource;

            foreach (string name, Parameter parameter; parameters) {
                if (!empty(parameter.values)) {
                    foreach (string value; parameter.values) {
                        url ~= (first ? "" : "&") ~ name ~ "[]=" ~ value;

                        first = false;
                    }
                } else {
                    url ~= (first ? "" : "&") ~ name ~ "=" ~ parameter.value;
                }

                first = false;
            }

            return new Request(url);
        }
}

class Request
{
    private string url;

    this(string url)
    {
        this.url = url;

        debug {
            writeln("[DEBUG] REQUEST HEADERS:");
            writeln(url);
        }

        debug (WITHOUT_SEND) {
            writeln("[DEBUG] REQUEST HEADERS:");
            writeln(url);
        }
    }

    string send()
    {
        string content;

        debug (WITHOUT_SEND) {
            writeln("[DEBUG] WITHOUT SEND");

            return `0{"error":0,"message":""}0`;
        } else {
            content = to!string(get(url));

            debug {
                writeln("[DEBUG] RESPONSE:");
                writeln(content);
            }

            return content;
        }
    }
}
