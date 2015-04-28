module dsmsapi.api;

import std.conv : text, to;
import std.digest.digest : toHexString;
import std.digest.md : md5Of;
import std.format : format;
import std.json : JSON_TYPE, JSONException, JSONValue, parseJSON;

import dsmsapi.core: Method, Parameter, ParamName, RequestBuilder, Server;

immutable struct Item
{
    ulong id;
    ulong number;
    float points;
    string status;
}

class ApiException : Exception
{
	immutable {
		long code;
		string message;
	}

	@safe pure this(long code, string message)
	{
		this.code = code;
		this.message = message;

		super(format("Code: %d. Message: %s", code, message));
	}
}

class UnexpectedResponseException : Exception
{
	private static const message = "Unexpected response: ";

	@safe pure this(string response)
	{
		super(message ~ response);
	}

	this(JSONValue response)
	{
		super(message ~ response.toString);
	}

	@safe pure this(string response, Throwable next)
	{
		super(message ~ response, next);
	}
}

class Response
{
    immutable {
        long count;
        Item[] list;
    }

    this(JSONValue response)
    {
        JSONValue[string] values;
        foreach (string key, JSONValue value; response) {
            values[key] = value;
        }

        if ("error" in values) {
			string message = "";

            if ("message" in values) {
                message = response["message"].str();
            }

			throw new ApiException(response["error"].integer(), message);
        } else if ("count" in values && "list" in values) {
            float points;
            Item[] items;

            count = response["count"].integer();

            foreach (JSONValue item; response["list"].array()) {
				switch (item["points"].type()) {
					case JSON_TYPE.FLOAT:
						points = item["points"].floating();
						break;
					case JSON_TYPE.INTEGER:
						points = item["points"].integer();
						break;
					case JSON_TYPE.STRING:
						points = to!float(item["points"].str());
						break;
					default:
						throw new UnexpectedResponseException(response);
				}

                items ~= Item(
                    to!ulong(item["id"].str()),
                    to!ulong(item["number"].str()),
                    points,
                    item["status"].str()
                );
            }

            list = cast(immutable Item[])items;
        } else if ("id" in values && "price" in values && "number" in values && "status" in values) {
            count = 1;

            list ~= Item(
                to!ulong(response["id"].str()),
                to!ulong(response["number"].str()),
                to!float(response["price"].str()),
                response["status"].str()
            );
        } else {
			throw new UnexpectedResponseException(response);
        }
    }

    override string toString()
    {
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
    }
}

class User
{
    immutable {
        string name;
        ubyte[16] hash;
    }

    @safe pure this(string username, ubyte[16] passwordHash)
    {
        name = username;
        hash = passwordHash;
    }

    @safe pure this(string username, string password)
    {
        this(username, md5Of(password));
    }
}

class Api
{
    private:
        static const {
            string
                format  = "json",
                pattern = `[a-z0-9](\{.+\})`;
        }

        Server server;
        bool test;
        User user;

    public:
        @safe pure this(User user, Server server = Server.init, bool test = false)
        {
            this.user = user;
            this.server = server;
            this.test = test;
        }

        Response execute(Method apiMethod)
        {
            RequestBuilder requestBuilder = apiMethod.createRequestBuilder();

            string response;

            requestBuilder.server = server;

            requestBuilder
                .setParameter(new Parameter(ParamName.username, user.name))
                .setParameter(new Parameter(ParamName.password, text(toHexString(user.hash))))
                .setParameter(new Parameter(ParamName.format, format));

            if (test) {
                requestBuilder.setParameter(new Parameter(ParamName.test, "1"));
            }

            response = requestBuilder.create().send();

            try {
                return new Response(parseJSON(response));
            } catch (JSONException exception) {
				throw new UnexpectedResponseException(response, exception);
            }
        }
}
