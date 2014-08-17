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
                Builder(new Content("Hello world!"), Receiver(555012345))
                    .getEco()
            )
        );
}
```
### SMS
``` D
#!/usr/bin/env rdmd

import std.stdio : writefln;

import dsmsapi.core : Content, HOST, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.sms  : Config, Eco, Send;

void main()
{
    int        phone     = 555012345;
    Receiver   receiver  = Receiver(phone);
    Receiver[] receivers = [receiver];
    string     text      = "Hello world!";
    Content    content   = new Content(text);
    Config     config    = Config();
    Eco        sms       = new Eco(receivers, content, config);
    Send       send      = new Send(sms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(send);

    if (response.isSuccess()) {
        writefln(`Success! Count: %d`, response.getCount());

        foreach (int i, Item item; response.getList()) {
            writefln(
                `%d. Id: %d, points: %f, number: %d, status: %s.`,
                i + 1,
                item.id,
                item.points,
                item.number,
                item.status
            );
        }
    } else {
        writefln(`Failure! Error code: %d, message: %s.`, response.getError(), response.getMessage());
    }
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
    string   text     = "Hello world!";
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
import std.stdio : writefln;

import dsmsapi.core : Content, HOST, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.mms  : Send, Mms, Subject;

void main()
{
    int        phone     = 555012345;
    Receiver   receiver  = Receiver(phone);
    Receiver[] receivers = [receiver];
    string     file      = "mms.smil";
    string     data      = readText(file);
    Content    content   = new Content(data);
    string     name      = "Hello world!";
    Subject    subject   = Subject(name);
    Mms        mms       = new Mms(subject, receiver, content);
    Send       send      = new Send(mms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(send);

    if (response.isSuccess()) {
        writefln(`Success! Count: %d`, response.getCount());

        foreach (int i, Item item; response.getList()) {
            writefln(
                `%d. Id: %d, points: %f, number: %d, status: %s.`,
                i + 1,
                item.id,
                item.points,
                item.number,
                item.status
            );
        }
    } else {
        writefln(`Failure! Error code: %d, message: %s.`, response.getError(), response.getMessage());
    }
}
```
### HLR
``` D
#!/usr/bin/env rdmd

import std.stdio : writefln;

import dsmsapi.core : Content, HOST, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.hlr  : Check, Hlr;

void main()
{
    int    phone  = 555012345;
    int[]  phones = [phone];
    string idx    = "test1";
    Hlr    hlr    = Hlr(phones, idx);
    Check  check  = new Check(hlr);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(check);
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
- [x] HLR
- [ ] SMIL generator
- [ ] SMIL validator
- [x] host switch
- [x] test request
- [ ] host auto-switch
- [ ] idx generator
- [ ] subusers
- [ ] sender fields
- [ ] phonebook

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
- [x] number
- [x] idx

## ToDo
 * add docs (http://dlang.org/ddoc.html)
 * add tests (http://dlang.org/unittest.html)
 * use dstyle (http://dlang.org/dstyle.html)
 * use dub (http://code.dlang.org)
 * versions tags
 * consider use contracts
 * move `RequestBuilder` to separate repository
 * rethink Methods
 * consider use interfaces
 * consider use unions
 * use `RedBlackTree` for `parameters` in `RequestBuilder`
 * redesign `mms.d` like `sms.d`
 * rethink `class` and `struct` usage
 * add timers to debug mode (http://wiki.dlang.org/Timing_Code)
 * rethink current visibility (http://dlang.org/attribute.html#ProtectionAttribute)
 * add custom exception classes
 * create ReceiverSet that can not be empty
 * add support for HLR responses