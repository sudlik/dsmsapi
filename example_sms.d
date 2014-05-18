#!/usr/bin/env rdmd

import SMSAPILib : Api, Content, Receiver, Sender, Sms, TYPE, User;
import std.stdio : writeln;

void main(string[] args)
{
    writeln(
        (new Api(User("username", "password"), true))
            .send(
                new Sms(
                    Sender(TYPE.ECO),
                    Receiver(123456789),
                    Content("Hello world!")
                )
            )
            .content
    );
}