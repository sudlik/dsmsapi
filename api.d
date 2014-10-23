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
        string message = "No message";
        bool success = false;
    }

    this(JSONValue response)
    {
        JSONValue[string] values;
        foreach (string key, JSONValue value; response) {
            values[key] = value;
        }

        if ("error" in values) {
            error = response["error"].integer();

            if ("message" in values) {
                message = response["message"].str();
            }
        } else if ("count" in values && "list" in values) {
            float points;

            success = true;
            count = response["count"].integer();

            foreach (JSONValue item; response["list"].array()) {
                if (item["points"].type() == JSON_TYPE.FLOAT) {
                    points = item["points"].floating();
                } else if (item["points"].type() == JSON_TYPE.INTEGER) {
                    points = item["points"].integer();
                } else if (item["points"].type() == JSON_TYPE.STRING) {
                    points = to!float(item["points"].str());
                } else {
                    message = "Lib error: unexpected API response";
                }

                list ~= Item(
                    to!ulong(item["id"].str()),
                    points,
                    to!ulong(item["number"].str()),
                    item["status"].str()
                );
            }
        } else if ("id" in values && "price" in values && "number" in values && "status" in values) {
            success = true;
            count = 1;

            list ~= Item(
                to!ulong(response["id"].str()),
                to!float(response["price"].str()),
                to!ulong(response["number"].str()),
                response["status"].str()
            );
        } else {
            message = "Lib error: unexpected API response";
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
        string   pattern  = `[a-z0-9](\{.+\})`;
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

            string response = matchFirst(requestBuilder.getRequest().send(), pattern)[1];

            try {
                return Response(parseJSON(response));
            } catch (JSONException exception) {
                return Response(parseJSON(`{"error":0,"message":"Lib error: unexpected API response"}`));
            }
        }
}
