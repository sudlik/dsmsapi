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
    new Api(new User("username", "password"))
        .execute(
            new Send(
                new Builder(new Content("Hello world!"), Receiver(555012345))
                    .createEco()
            )
        );
}
```
### SMS
``` D
#!/usr/bin/env rdmd

import std.stdio: writeln;

import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.core : Content, Receiver;
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
    User   user     = new User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(send);

    writeln(response);
}
```
### SMS Builder
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.sms  : Builder, Eco, Send;

void main()
{
    int      phone    = 555012345;
    Receiver receiver = Receiver(phone);
    string   text     = "Hello [%1%]!";
    Content  content  = new Content(text);
    Builder  builder  = new Builder(content, receiver);
    Eco      sms      = builder.createEco();
    Send     sendSms  = new Send(sms);

    string username = "username";
    string password = "password";
    User   user     = new User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);

    writeln(response);
}
```
### SMS Pattern
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

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
    User   user     = new User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(sendSms);

    writeln(response);
}
```
### MMS
``` D
#!/usr/bin/env rdmd

import std.file  : readText;
import std.stdio : writeln;

import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.core : Content, Receiver;
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
    User   user     = new User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(send);

    writeln(response);
}
```
### VMS
``` D
#!/usr/bin/env rdmd

import std.stdio: writeln;

import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.core : Content, Host, Receiver;
import dsmsapi.vms  : Send, Vms;

void main()
{
    int        phone     = 555012345;
    Receiver   receiver  = Receiver(phone);
    Receiver[] receivers = [receiver];
    Content    content   = new Content("Hello world");
    Vms        vms       = new Vms(receivers, content);
    Send       send      = new Send(vms);

    string username = "username";
    string password = "password";
    User   user     = new User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(send);

    writeln(response);
}
```
### HLR
``` D
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.hlr  : Check, Hlr;

void main()
{
    int      phone  = 555012345;
    int[]    phones = [phone];
    string   idx    = "test1";
    string[] idxes  = [idx];
    Hlr      hlr    = new Hlr(phones, idxes);
    Check    check  = new Check(hlr);

    string username = "username";
    string password = "password";
    User   user     = new User(username, password);
    Api    api      = new Api(user);

    Response response = api.execute(check);

    writeln(response);
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
 * rethink `Method`s
 * consider use interfaces
 * consider use unions
 * use `RedBlackTree` for `parameters` in `RequestBuilder`
 * redesign `mms.d` like `sms.d`
 * add timers to debug mode (http://wiki.dlang.org/Timing_Code)
 * rethink current visibility (http://dlang.org/attribute.html#ProtectionAttribute)
 * create `ReceiverSet` that can not be empty
 * phone number validator
 * use `std.datetime` to represent and manipulate dates
