# DSmsApi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)),
written in D programming language ([dlang.org](http://dlang.org))
## Requirements
dmd 2.065
## Installation
`git clone git@github.com:sudlik/dsmsapi.git`
## Examples
### Short
``` D
#!/usr/bin/env rdmd

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, User;
import dsmsapi.sms  : Builder, Eco, SendSms;

void main()
{
    new Api(User("username", "password"))
        .execute(
            new SendSms(
                Builder(new Content("Hello [%1%]!"), Receiver(555012345))
                    .getEco()
            )
        );
}
```
### SMS
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, Response, User;
import dsmsapi.sms  : Config, Eco, SendSms;

void main()
{
    int        phone     = 555012345;
    Receiver[] receivers = [Receiver(phone)];
    string     text      = "Hello [%1%]!";
    Content    content   = new Content(text);
    Config     config    = Config();
    Eco        sms       = new Eco(receivers, content, config);
    SendSms    sendSms   = new SendSms(sms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);
    string   result   = response.getContent();

    writeln(result);
}
```
### SMS builder
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, Response, User;
import dsmsapi.sms  : Builder, Eco, SendSms;

void main()
{
    int      phone    = 555012345;
    Receiver receiver = Receiver(phone);
    string   text     = "Hello [%1%]!";
    Content  content  = new Content(text);
    Builder  builder  = Builder(content, receiver);
    Eco      sms      = builder.getEco();
    SendSms  sendSms  = new SendSms(sms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);
    string   result   = response.getContent();

    writeln(result);
}
```
### SMS Pattern
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Receiver;
import dsmsapi.api  : Api, Response, User;
import dsmsapi.sms  : Config, Eco, Pattern, SendSms;

void main()
{
    int        phone     = 555012345;
    Receiver[] receivers = [Receiver(phone)];
    string     name      = "Hello world";
    Pattern    pattern   = new Pattern(name);
    Config     config    = Config();
    Eco        sms       = new Eco(receivers, pattern, config);
    SendSms    sendSms   = new SendSms(sms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);
    string   result   = response.getContent();

    writeln(result);
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
- [ ] host auto-switch

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
 * add support for subusers and sender fields (http://smsapi.pl/assets/files/api/SMSAPI_http_EXT.pdf)
 * add support for phonebook (http://smsapi.pl/assets/files/api/SMSAPI_phonebook.pdf)
 * improve `SendSms`
 * consider use interfaces
 * consider use unions
 * use `RedBlackTree` for `parameters` in `RequestBuilder`
 * redesign `mms.d` like `sms.d`
 * rethink `class` and `struct` usage
 * add timers to debug mode (http://wiki.dlang.org/Timing_Code)
 * rethink current visibility (http://dlang.org/attribute.html#ProtectionAttribute)
 * add custom exception classes
 * create ReceiverSet that can not be empty
 * use custom exceptions
