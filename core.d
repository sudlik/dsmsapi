module dsmsapi.core;

import std.conv : to;

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
    string getPath();
}