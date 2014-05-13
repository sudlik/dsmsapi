#!/usr/bin/env rdmd

import SMSAPILib : Api, Message, Receiver, Response, Sender, Sms, User;
import std.stdio : writeln;

void main(string[] args)
{
    writeln(
        (new Api(User("username", "password"), true))
            .send(
                new Sms(
                    Sender("ECO"),
                    [Receiver(123456789)],
                    Message("Hello world!")
                )
            )
            .content
    );
}