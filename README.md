# DSmsApi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)),
written in D programming language ([dlang.org](http://dlang.org))
## Requirements
dmd 2.065
## Installation
`git clone git@github.com:sudlik/dsmsapi.git`
## Examples
### SMS
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, PARAMETER, Receiver;
import dsmsapi.api  : Api, HOST, Response, User;
import dsmsapi.sms  : Builder, CHARSET, Eco, SendSms, TYPE, Variable;

void main()
{
    Content  content  = new Content("Hello [%1%]!");
    Receiver receiver = Receiver(555012345);
    User     user     = User("username", "password");

    Eco sms = new Builder(content)
        .setNormalize(true)
        .setSingle(true)
        .setCharset(CHARSET.UTF_8)
        .addReceiver(receiver)
        .addVariable(Variable(PARAMETER.PARAM_1, "world"))
        .getEco();

    SendSms  sendSms  = new SendSms(sms);
    Api      api      = new Api(user, HOST.PLAIN_1, true);
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
    Content  content  = new Content(readText("mms.smil"));
    Receiver receiver = Receiver(555012345);
    Subject  subject  = Subject("Hello world!");
    User     user     = User("username", "password");
    Mms      mms      = new Mms(subject, receiver, content);
    SendMms  sendMms  = new SendMms(mms);
    Api      api      = new Api(user, HOST.PLAIN_1, true);
    Response response = api.execute(sendMms);

    writeln(response.getContent());
}
```
### Pattern
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : PARAMETER, Receiver;
import dsmsapi.api  : Api, HOST, Response, User;
import dsmsapi.sms  : Builder, CHARSET, Eco, Pattern, SendSms, TYPE, Variable;

void main()
{
    Pattern  pattern  = new Pattern("Hello world");
    Receiver receiver = Receiver(555012345);
    User     user     = User("username", "password");

    Eco sms = new Builder(pattern)
        .setNormalize(true)
        .setSingle(true)
        .setCharset(CHARSET.UTF_8)
        .addReceiver(receiver)
        .addVariable(Variable(PARAMETER.PARAM_1, "world"))
        .getEco();

    SendSms  sendSms  = new SendSms(sms);
    Api      api      = new Api(user, HOST.PLAIN_1, true);
    Response response = api.execute(sendSms);

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
- [x] host switch
- [x] test request

### SMS
- [x] charset (encoding)
- [x] content (message)
- [ ] group
- [x] normalize
- [x] parameters
- [x] patterns (templates)
- [x] sender name
- [x] sender types
- [x] single
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

### MMS
- [x] content (SMIL)
- [x] subject
- [ ] notify_url
- [ ] date
- [ ] idx
- [ ] check_idx

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

### HLR
- [ ] number
- [ ] idx

## ToDo
 * add docs (http://dlang.org/ddoc.html)
 * add tests (http://dlang.org/unittest.html)
 * use dstyle (http://dlang.org/dstyle.html)
 * use dub (http://code.dlang.org)
 * versions tags
 * consider use contracts
 * improve `Response`
 * move `RequestBuilder` to separate repository
 * consider use immutable
 * add support for subusers and sender fields (http://smsapi.pl/assets/files/api/SMSAPI_http_EXT.pdf)
 * add support for phonebook (http://smsapi.pl/assets/files/api/SMSAPI_phonebook.pdf)
 * improve `SendSms`
 * consider use interfaces
 * consider use unions
 * use `RedBlackTree` for `parameters` in `RequestBuilder`
 * redesign `mms.d` like `sms.d`
 * rethink `class` and `struct` usage
 * add timers to debug mode (http://wiki.dlang.org/Timing_Code)