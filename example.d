#!/usr/bin/env rdmd

import std.conv     : to;
import SMSAPILib    : Api, Content, HOST, Mms, Receiver, Response, Sender, Sms, Subject, TYPE, User;
import std.stdio    : writeln;
import std.c.stdlib : exit;
import std.file     : readText;

void main(string[] args)
{
    TYPE        type;
    Receiver    receiver;
    Response    reponse;
    Sms         sms;
    Api         api;

    if (args.length == 6 || args.length == 7) {
        api         = new Api(User(args[2], args[3]), HOST.PLAIN_1, true);
        receiver    = Receiver(to!uint(args[5]));

        switch (args[1]) {
            case "sms":
                if (args.length == 7) {
                    if (args[4] == "ECO" || args[4] == "2Way") {
                        if (args[4] == "ECO") {
                            type = TYPE.ECO;
                        } else {
                            type = TYPE.WAY;
                        }

                        sms = new Sms(type, receiver, Content(args[6]));
                    } else {
                        sms = new Sms(Sender(args[4]), receiver, Content(args[6]));
                    }

                    reponse = api.send(sms);
                } else {
                    writeln("The program expects 6 arguments for 'sms'");
                    exit(-1);
                }
                break;
            case "mms":
                if (args.length == 6) {
                    reponse = api.send(new Mms(Subject(args[4]), receiver, Content(readText("mms.smil"))));
                } else {
                    writeln("The program expects 5 arguments for 'mms'");
                    exit(-1);
                }
                break;
            default:
                writeln("First arguments should be 'sms' or 'mms'");
                exit(-1);
        }

        writeln(reponse.content);
    } else {
        writeln("The program expects 6 arguments for 'sms' or 5 for 'mms'");
        exit(-1);
    }
}