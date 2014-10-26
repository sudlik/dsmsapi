module dsmsapi.api;

import std.conv          : text, to;
import std.digest.digest : toHexString;
import std.digest.md     : md5Of;
import std.json          : JSON_TYPE, JSONException, JSONValue, parseJSON;
import std.regex         : matchFirst;
import std.string        : format;
import std.traits        : hasMember;

import dsmsapi.core: Host, Method, Parameter, ParamName, RequestBuilder;

immutable struct Item
{
    ulong id;
    float points;
    ulong number;
    string status;
}

class Response
{
    private static const unexpectedResponse = "Lib error: unexpected API response";

    long   count;
    long   error;
    Item[] list;
    string message;

    bool success = false;

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
            count   = response["count"].integer();

            foreach (JSONValue item; response["list"].array()) {
                if (item["points"].type() == JSON_TYPE.FLOAT) {
                    points = item["points"].floating();
                } else if (item["points"].type() == JSON_TYPE.INTEGER) {
                    points = item["points"].integer();
                } else if (item["points"].type() == JSON_TYPE.STRING) {
                    points = to!float(item["points"].str());
                } else {
                    message = unexpectedResponse;
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
            count   = 1;

            list ~= Item(
                to!ulong(response["id"].str()),
                to!float(response["price"].str()),
                to!ulong(response["number"].str()),
                response["status"].str()
            );
        } else {
            message = unexpectedResponse;
        }
    }

    override string toString()
    {
        if (success) {
            string response = format("Success! Count: %d", count);

            foreach (int i, Item item; list) {
                response ~=
                    "\r\n"
                    ~ format(
                        `%d. Id: %d, points: %f, number: %d, status: %s.`,
                        i + 1,
                        item.id,
                        item.points,
                        item.number,
                        item.status
                    );
            }

            return response;
        } else {
            return format("Failure! Error code: %d, message: %s.", error, message);
        }
    }
}

class User
{
    immutable {
        string    name;
        ubyte[16] hash;
    }

    pure this(string username, ubyte[16] passwordHash)
    {
        name = username;
        hash = passwordHash;
    }

    pure this(string username, string pass)
    {
        this(username, md5Of(pass));
    }
}

class Api
{
    private:
        static const {
            string
                agent    = "dsmsapi",
                format   = "json",
                method   = "POST",
                protocol = "HTTP/1.1",
                pattern  = `[a-z0-9](\{.+\})`;

            ushort port = 80;
        }

        Host host;
        bool test;
        User user;

    public:
        pure this(User user, Host host = Host.init, bool test = false)
        {
            this.user = user;
            this.host = host;
            this.test = test;
        }

        Response execute(Method apiMethod)
        {
            RequestBuilder requestBuilder = apiMethod.createRequestBuilder();

            requestBuilder.host = host;
            requestBuilder.method = method;
            requestBuilder.protocol = protocol;
            requestBuilder.agent = agent;
            requestBuilder.port = port;

            requestBuilder
                .setParameter(new Parameter(ParamName.username, user.name))
                .setParameter(new Parameter(ParamName.password, text(toHexString(user.hash))))
                .setParameter(new Parameter(ParamName.format, format));

            if (test) {
                requestBuilder.setParameter(new Parameter(ParamName.test, "1"));
            }

            string response = matchFirst(requestBuilder.create().send(), pattern)[1];

            try {
                return new Response(parseJSON(response));
            } catch (JSONException exception) {
                return new Response(parseJSON(`{"error":0,"message":"Lib error: unexpected API response"}`));
            }
        }
}
