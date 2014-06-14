module dsmsapi.api;

import dsmsapi.core : AGENT, HOST, Method, METHOD, ParameterFactory, PARAMETER, PORT, PROTOCOL, RequestBuilder;

import std.conv             : text;
import std.digest.digest    : toHexString;
import std.digest.md        : md5Of;

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

enum FORMAT
{
    JSON = "json";
}

class Api
{
    static const {
        dsmsapi.core.PORT PORT          = PORT.P80;
        dsmsapi.core.METHOD METHOD      = METHOD.POST;
        dsmsapi.core.AGENT AGENT        = AGENT.DSMSAPI;
        dsmsapi.core.PROTOCOL PROTOCOL  = PROTOCOL.HTTP_11;
        dsmsapi.core.FORMAT FORMAT      = FORMAT.JSON;
    }

    private:
        HOST host;
        User user;

        ParameterFactory parameterFactory   = new ParameterFactory;
        bool test                           = false;

    public:
        this(User user, HOST host)
        {
            setUser(user);
            setHost(host);
        }

        Api setTest(bool test)
        {
            this.test = test;

            return this;
        }

        Response execute(Method method)
        {
            ParameterFactory parameterFactory = getParameterFactory();

            RequestBuilder requestBuilder = method
                .getRequest()
                .setHost(getHost())
                .setMethod(METHOD)
                .setProtocol(PROTOCOL)
                .setAgent(AGENT)
                .setPort(PORT)
                .addParameter(parameterFactory.create(PARAMETER.USERNAME, getUser().name))
                .addParameter(parameterFactory.create(PARAMETER.PASSWORD, text(toHexString(getUser().hash))))
                .addParameter(parameterFactory.create(PARAMETER.FORMAT, FORMAT));

            if (getTest()) {
                requestBuilder.addParameter(parameterFactory.create(PARAMETER.TEST, "1"));
            }

            return Response(requestBuilder.getRequest().send());
        }

    protected:
        bool getTest()
        {
            return test;
        }

        User getUser()
        {
            return user;
        }

        Api setUser(User user)
        {
            this.user = user;

            return this;
        }

        HOST getHost()
        {
            return host;
        }

        Api setHost(HOST host)
        {
            this.host = host;

            return this;
        }

        ParameterFactory getParameterFactory()
        {
            return parameterFactory;
        }
}