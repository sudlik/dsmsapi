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
    Content content   = Content("Hello world!");
    Receiver receiver = Receiver(555012345);
    User user         = User("username", "password");
    Sms sms           = new Sms(TYPE.ECO, receiver, content, CHARSET.UTF_8, true);
    SendSms sendSms   = new SendSms(sms);
    Api api           = new Api(user, HOST.PLAIN_1, true);
    Response response = api.execute(sendSms);

    writeln(response.getContent());
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
    Subject subject   = Subject("Hello world!");
    User user         = User("username", "password");
    Mms mms           = new Mms(subject, receiver, content);
    SendMms sendMms   = new SendMms(mms);
    Api api           = new Api(user, HOST.PLAIN_1, true);
    Response response = api.execute(sendMms);

    writeln(response.getContent());
}
```
### Pattern
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Receiver;
import dsmsapi.api  : Api, HOST, Response, User;
import dsmsapi.sms  : CHARSET, Parameters, Pattern, SendSms, Sms, TYPE;

void main()
{
    Parameters parameters = Parameters("a", "b", "c", "d");
    Pattern pattern       = new Pattern("Hello world", parameters, true);
    Receiver receiver     = Receiver(555012345);
    User user             = User("username", "password");
    Sms sms               = new Sms(TYPE.ECO, receiver, pattern, CHARSET.UTF_8, true);
    SendSms sendSms       = new SendSms(sms);
    Api api               = new Api(user, HOST.PLAIN_1, true);
    Response response     = api.execute(sendSms);

    writeln(response.getContent());
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
- [ ] SMIL generator
- [ ] SMIL validator

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
 * contracts
 * improve `struct Response`
 * move `class RequestBuilder` to separate repository
