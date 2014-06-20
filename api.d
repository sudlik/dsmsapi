module dsmsapi.api;

import std.stdio : writeln;
import std.conv          : text;
import std.digest.digest : toHexString;
import std.digest.md     : md5Of;

import dsmsapi.core : AGENT, HOST, Method, METHOD, Parameter, PARAMETER, PORT, PROTOCOL, RequestBuilder;

struct Response
{
    private string content;

    pure this(string content)
    {
        this.content = content;
    }

    pure string toString()
    {
        return content;
    }

    pure string getContent()
    {
        return content;
    }
}

struct User
{
    private:
        string    name;
        ubyte[16] hash;

    public:
        pure this(string name, ubyte[16] hash)
        {
            this.name = name;
            this.hash = hash;
        }

        this(string name, string pass)
        {
            this.name = name;
            this.hash = md5Of(pass);
        }

        pure string getName()
        {
            return name;
        }

        pure ubyte[16] getHash()
        {
            return hash;
        }
}

enum FORMAT
{
    JSON = "json",
}

class Api
{
    static const {
        PORT port         = PORT.P80;
        METHOD method     = METHOD.POST;
        AGENT agent       = AGENT.DSMSAPI;
        PROTOCOL protocol = PROTOCOL.HTTP_11;
        FORMAT format     = FORMAT.JSON;
    }

    private:
        HOST host;
        bool test;
        User user;

    public:
        pure this(User user, HOST host, bool test = false)
        {
            user = user;
            host = host;
        }

        Response execute(Method apiMethod)
        {
            RequestBuilder requestBuilder = apiMethod
                .getRequestBuilder()
                .setHost(host)
                .setMethod(method)
                .setProtocol(protocol)
                .setAgent(agent)
                .setPort(port)
                .addParameter(new Parameter(PARAMETER.USERNAME, user.getName()))
                .addParameter(new Parameter(PARAMETER.PASSWORD, text(toHexString(user.getHash()))))
                .addParameter(new Parameter(PARAMETER.FORMAT, format));

            if (test) {
                requestBuilder.addParameter(new Parameter(PARAMETER.TEST, "1"));
            }

            return Response(requestBuilder.getRequest().send());
        }
}