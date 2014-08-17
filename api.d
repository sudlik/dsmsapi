module dsmsapi.api;

import std.conv          : text, to;
import std.digest.digest : toHexString;
import std.digest.md     : md5Of;
import std.json          : JSON_TYPE, JSONException, JSONValue, parseJSON;
import std.regex         : matchFirst;
import std.traits        : hasMember;

import dsmsapi.core : AGENT, HOST, Method, METHOD, Parameter, PARAMETER, PORT, PROTOCOL, RequestBuilder;

struct Item
{
    immutable
        ulong id;
        float points;
        ulong number;
        string status;
}

struct Response
{
    private {
        long count;
        long error;
        Item[] list;
        string message;
        bool success = false;
    }

    this(JSONValue response)
    {
        JSONValue[string] values;
        foreach (string key, JSONValue value; response) {
            values[key] = value;
        }

        if ("error" in values && "message" in values) {
            error   = response["error"].integer();
            message = response["message"].str();
        } else {
            float points;

            success = true;
            count   = response["count"].integer();

            foreach (JSONValue value; response["list"].array()) {
                if (value.type() == JSON_TYPE.FLOAT) {
                    points = value["points"].floating();
                } else {
                    points = to!float(value["points"].str());
                }

                list ~= Item(
                    to!ulong(value["id"].str()),
                    points,
                    to!ulong(value["number"].str()),
                    value["status"].str()
                );
            }
        }
    }

    pure bool isSuccess()
    {
        return success;
    }

    pure long getError()
    {
        return error;
    }

    pure string getMessage()
    {
        return message;
    }

    pure long getCount()
    {
        return count;
    }

    pure Item[] getList()
    {
        return list;
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
        AGENT    agent    = AGENT.DSMSAPI;
        FORMAT   format   = FORMAT.JSON;
        METHOD   method   = METHOD.POST;
        PORT     port     = PORT.P80;
        PROTOCOL protocol = PROTOCOL.HTTP_11;
        string   pattern  = `[a-z0-9](\{.+\})0`;
    }

    private:
        HOST host;
        bool test;
        User user;

    public:
        pure this(User user, HOST host = HOST.PLAIN_1, bool test = false)
        {
            this.user = user;
            this.host = host;
            this.test = test;
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
                .setParameter(new Parameter(PARAMETER.USERNAME, user.getName()))
                .setParameter(new Parameter(PARAMETER.PASSWORD, text(toHexString(user.getHash()))))
                .setParameter(new Parameter(PARAMETER.FORMAT, format));

            if (test) {
                requestBuilder.setParameter(new Parameter(PARAMETER.TEST, "1"));
            }

            /**
             * @todo
             */
            return Response(parseJSON(matchFirst(requestBuilder.getRequest().send(), pattern)[1]));

        }
}