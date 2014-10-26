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
import dsmsapi.sms  : Builder, Eco, Send;

void main()
{
    new Api(User("username", "password"))
        .execute(
            new Send(
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

import std.stdio : writefln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.sms  : Builder, Eco, Send;

void main()
{
    int      phone    = 555012345;
    Receiver receiver = Receiver(phone);
    string   text     = "Hello [%1%]!";
    Content  content  = new Content(text);
    Builder  builder  = Builder(content, receiver);
    Eco      sms      = builder.getEco();
    Send     sendSms  = new Send(sms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);

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
### SMS Pattern
``` D
#!/usr/bin/env rdmd

import std.stdio : writefln;

import dsmsapi.core : Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.sms  : Config, Eco, Pattern, Send;

void main()
{
    int        phone     = 555012345;
    Receiver[] receivers = [Receiver(phone)];
    string     name      = "Hello world";
    Pattern    pattern   = new Pattern(name);
    Config     config    = Config();
    Eco        sms       = new Eco(receivers, pattern, config);
    Send       sendSms   = new Send(sms);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);

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
### VMS
``` D
#!/usr/bin/env rdmd

import std.conv     : to;
import std.datetime : DateTime, SysTime;
import std.stdio : writefln;

import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.core : Content, HOST, Receiver;
import dsmsapi.vms  : Send, Vms;

void main()
{
    int        phone     = 555012345;
    Receiver   receiver  = Receiver(phone);
    Receiver[] receivers = [receiver];
    string     text      = "Hello world!";
    Content    content   = new Content(text);
    ulong      date      = to!ulong(SysTime(DateTime(2014, 9, 25, 12, 0, 0)).toUnixTime());
    Vms        vms       = new Vms(receivers, content, date);
    Send       send      = new Send(vms);

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

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.hlr  : Check, Hlr;

void main()
{
    int      phone  = 555012345;
    int[]    phones = [phone];
    string   idx    = "test1";
    string[] idxes  = [idx];
    Hlr      hlr    = Hlr(phones, idxes);
    Check    check  = new Check(hlr);

    string username = "username";
    string password = "password";
    User   user     = User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(check);

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
## Features
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
- [x] date
- [ ] idx
- [ ] check_idx
- [ ] WAP PUSH (udh)

### MMS
- [x] content (SMIL)
- [x] subject
- [ ] notify_url
- [x] date
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
- [x] date
- [ ] idx
- [ ] check_idx

### HLR
- [x] number
- [x] idx

### Subusers

### Sender fields

### Phonebook

### Other
- [ ] multithreading
- [ ] SSL support
- [ ] SMIL generator
- [ ] SMIL validator
- [x] manage hosts
- [x] test request
- [ ] host auto-switch
- [ ] idx generator
- [ ] idx validator

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
 * add timers to debug mode (http://wiki.dlang.org/Timing_Code)
 * rethink current visibility (http://dlang.org/attribute.html#ProtectionAttribute)
 * create ReceiverSet that can not be empty
 * add support for HLR responses
 * phone number validator
 * use std.datetime to represent and manipulate dates
