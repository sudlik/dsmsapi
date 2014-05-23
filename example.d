#!/usr/bin/env rdmd

import SMSAPILib:
    Api,
    Content,
    HOST,
    Mms,
    Receiver,
    Response,
    Sender,
    SendMms,
    SendSms,
    Sms,
    Subject,
    TYPE,
    User;

import std.conv     : to;
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
    bool        test;

    if (args.length == 7 || args.length == 8) {
        switch (args[2]) {
            case "test":
                test = true;
                break;
            case "real":
                test = false;
                break;
            default:
                writeln("The program expects that second argument will be 'test' or 'real'");
                exit(-1);
        }

        api         = new Api(User(args[3], args[4]), HOST.PLAIN_1, test);
        receiver    = Receiver(to!uint(args[6]));

        switch (args[1]) {
            case "sms":
                if (args.length == 7) {
                    if (args[5] == "ECO" || args[5] == "2Way") {
                        if (args[5] == "ECO") {
                            type = TYPE.ECO;
                        } else {
                            type = TYPE.WAY;
                        }

                        sms = new Sms(type, receiver, Content(args[7]));
                    } else {
                        sms = new Sms(Sender(args[5]), receiver, Content(args[7]));
                    }

                    reponse = api.execute(new SendSms(sms));
                } else {
                    writeln("The program expects 6 arguments for 'sms'");
                    exit(-1);
                }
                break;
            case "mms":
                if (args.length == 7) {
                    reponse = api.execute(
                        new SendMms(new Mms(Subject(args[5]), receiver, Content(readText("mms.smil"))))
                    );
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