# DSmsApi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)),
written in D programming language ([dlang.org](http://dlang.org))
## Examples
### SMS
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, HOST, Response, User;
import dsmsapi.sms  : CHARSET, SendSms, Sms, TYPE;

void main()
{
    SendSms sendSms;
    Response response;
    Sms sms;

    Content content   = Content("Hello world!");
    Receiver receiver = Receiver(555012345);
    User user         = User("username", "password");

    Api api = new Api(user, HOST.PLAIN_1)
        .setTest(true);

    sms = new Sms(TYPE.ECO, receiver, content)
        .setCharset(CHARSET.UTF_8)
        .setNormalize(true);

    sendSms = new SendSms(sms);

    response = api.execute(sendSms);

    writeln(response.content);
}
```
### MMS
``` D
#!/usr/bin/env rdmd

import std.file  : readText;
import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, HOST, Response, User;
import dsmsapi.mms  : SendMms, Mms, Subject;

void main()
{
    Content content   = Content(readText("mms.smil"));
    Receiver receiver = Receiver(555012345);
    Subject subject   = Subject("Test");
    User user         = User("username", "password");
    Mms mms           = new Mms(subject, receiver, content);
    SendMms sendMms   = new SendMms(mms);

    Api api = new Api(user, HOST.PLAIN_1)
        .setTest(true);

    Response response = api
        .execute(sendMms);

    writeln(response.content);
}
```
### Pattern
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, HOST, Response, User;
import dsmsapi.sms  : CHARSET, SendSms, Sms, Parameters, Pattern, TYPE;

void main()
{
    Content content       = Content("Hello world!");
    Parameters parameters = Parameters("a", "b", "c", "d");
    Receiver receiver     = Receiver(555012345);
    User user             = User("username", "password");

    Pattern pattern = new Pattern("Testowa nazwa")
        .setParameters(parameters)
        .setSingle(true);

    Sms sms = new Sms(TYPE.ECO, receiver, pattern)
        .setCharset(CHARSET.UTF_8)
        .setNormalize(true);

    SendSms sendSms = new SendSms(sms);

    Api api = new Api(user, HOST.PLAIN_1)
        .setTest(true);

    Response response = api.execute(sendSms);

    writeln(response.content);
}
```
## Features
### Main
- [x] sending MMS
- [x] sending SMS
- [ ] sending VMS
- [x] multiple receivers
- [ ] multithreading
- [ ] SSL
- [ ] WAP PUSH (udh)
- [ ] HLR

### SMS
- [x] charset (encoding)
- [x] content (message)
- [ ] group
- [x] normalize
- [x] parameters *partially supported*
- [x] patterns (templates)
- [x] sender name
- [x] sender types
- [x] single *partially supported*
- [ ] flash
- [ ] details
- [ ] date_validate
- [ ] data_coding
- [ ] skip_foreign
- [ ] nounicode
- [ ] fast
- [ ] partner_id
- [ ] max_parts
- [ ] expiration_date
- [ ] discount_group
- [ ] remove scheduled message (sch_del)
- [ ] send vCard
- [ ] check account points
- [ ] notify_url
- [ ] date
- [ ] idx
- [ ] check_idx
- [ ] test

### MMS
- [x] content (SMIL)
- [x] subject
- [ ] notify_url
- [ ] date
- [ ] idx
- [ ] check_idx
- [ ] test

### VMS
- [ ] tts
- [ ] file
- [ ] try
- [ ] interval
- [ ] skip_gsm
- [ ] tts_lector
- [ ] notify_url
- [ ] date
- [ ] idx
- [ ] check_idx
- [ ] test

### HLR
- [ ] number
- [ ] idx

## ToDo
 * docs (http://dlang.org/ddoc.html)
 * tests (http://dlang.org/unittest.html)
 * dstyle (http://dlang.org/dstyle.html)
 * installation instruction
 * dub (http://code.dlang.org)
 * versions tags
