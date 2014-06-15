# DSmsApi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)) written in D programming language ([dlang.org](http://dlang.org))
## Examples
### Simple
``` d
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, HOST, User;
import dsmsapi.sms  : CHARSET, SendSms, Sms, TYPE;

void main()
{
    User user = User("username", "password");
    Api api = new Api(user, HOST.PLAIN_1);
    api.setTest(true);
    Receiver receiver = Receiver(555012345);
    Content content = Content("Hello world!");
    Sms sms = new Sms(TYPE.ECO, receiver, content);
    sms.setCharset(CHARSET.UTF_8);
    sms.setNormalize(true);
    SendSms sendSms = new SendSms(sms);
    writeln(api.execute(sendSms).content);
}
```
### Pattern usage
``` d
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, HOST, User;
import dsmsapi.sms  : CHARSET, SendSms, Sms, Parameters, Pattern, TYPE;

void main()
{
    User user = User("username", "password");
    Api api = new Api(user, HOST.PLAIN_1);
    api.setTest(true);
    Receiver receiver = Receiver(555012345);
    Pattern pattern = new Pattern("Testowa nazwa");
    pattern.setParameters(Parameters("a", "b", "c", "d"));
    pattern.setSingle(true);
    Sms sms = new Sms(TYPE.ECO, receiver, pattern);
    sms.setCharset(CHARSET.UTF_8);
    sms.setNormalize(true);
    SendSms sendSms = new SendSms(sms);
    writeln(api.execute(sendSms).content);
}
```
## ToDo
 * add docs
 * add tests
 * implement the rest of the API (smsapi.pl)
 * add support for the hqsms.com
 * add multithreading
 * add support for ssl
 * add more examples