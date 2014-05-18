#!/usr/bin/env rdmd

import SMSAPILib : Api, Content, Mms, Receiver, Subject, User;
import std.stdio : writeln;

void main(string[] args)
{
    writeln(
        (new Api(User("username", "password"), true))
            .send(
                new Mms(
                    Subject("Test"),
                    Receiver(123456789),
                    Content(
                        `<smil>
                            <head>
                                <layout>
                                    <root-layout height="600" width="425"/>
                                    <region id="img" top="0" left="0" height="100%" width="100%" fit="meet" />
                                </layout>
                            </head>
                            <body>
                                <par dur="5000ms">
                                    <img src="http://www.smsapi.pl/assets/img/mms.jpg" region="img" />
                                </par>
                            </body>
                        </smil>`
                    )
                )
            )
            .content
    );
}