module dsmsapi.mms;

import dsmsapi.core : Content, Message, Method, Receiver;

import std.conv : text, to;
import std.uri  : encode;

struct Subject
{
    string content;

    string toString()
    {
        return content;
    }
}

class Mms : Message
{
    private Subject subject;

    public:
        this(Subject subject, Receiver[] receivers, Content content)
        {
            setSubject(subject);
            setReceivers(receivers);
            setContent(content);
        }

        this(Subject subject, Receiver receiver, Content content)
        {
            this(subject, [receiver], content);
        }

        Subject getSubject()
        {
            return subject;
        }

    protected:
        Mms setSubject(Subject value)
        {
            subject = value;

            return this;
        }
}

class SendMms : Method
{
    static const string PATH = "mms.do";

    private Mms mms;

    public:
        this(Mms mms)
        {
            setMms(mms);
        }

        string getPath()
        {
            string receivers;

            foreach (Receiver receiver; getMms().getReceivers()) {
                receivers ~= "&to[]=" ~ encode(text(receiver));
            }

            return
                PATH ~
                "?subject=" ~  encode(text(mms.getSubject())) ~
                receivers ~
                "&smil=" ~ encode(text(mms.getContent()));
        }

    protected:
        Mms getMms()
        {
            return mms;
        }

        SendMms setMms(Mms value)
        {
            mms = value;

            return this;
        }
}