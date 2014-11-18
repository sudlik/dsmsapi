# dsmsapi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)),
written in D programming language ([dlang.org](http://dlang.org))
## Requirements
* DMD (dmd v2.066)
* cURL (libcurl3 v7.32)

## Installation
`$ git clone git@github.com:sudlik/dsmsapi.git`
## Examples
### Shorter
``` D
#!/usr/bin/env rdmd

import dsmsapi.api;
import dsmsapi.core;
import dsmsapi.sms;

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
import dsmsapi.core : Content, Receiver;
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

import dsmsapi.api  : Api, Item, Response, User;
import dsmsapi.core : Content, Receiver;
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
## Implemented components
### SMS
- [x] charset (encoding)
- [ ] check_idx
- [x] content (message)
- [ ] data_coding
- [x] date
- [ ] date_validate
- [ ] details
- [ ] discount_group
- [x] expiration_date
- [ ] fast
- [ ] group
- [ ] idx
- [ ] max_parts
- [x] normalize
- [ ] notify_url
- [ ] nounicode
- [x] parameters
- [ ] partner_id
- [x] patterns (templates)
- [ ] remove scheduled message (sch_del)
- [ ] send vCard
- [x] sender name
- [x] sender types
- [x] single
- [ ] skip_foreign

### Flash
- [ ] flash

### WAP PUSH (udh)
- [ ] udh

### MMS
- [ ] check_idx
- [x] content (SMIL)
- [x] date
- [ ] idx
- [ ] notify_url
- [x] subject

### VMS
- [ ] check_idx
- [x] date
- [ ] file
- [ ] idx
- [ ] interval
- [ ] notify_url
- [ ] skip_gsm
- [ ] try
- [ ] tts
- [ ] tts_lector

### HLR
- [x] idx
- [x] number

### User
- [ ] credits (check account points)
- [ ] details
- [ ] without_prefix
- [ ] add_user
- [ ] pass
- [ ] pass_api
- [ ] limit
- [ ] month_limit
- [ ] senders
- [ ] phonebook
- [ ] active
- [ ] info
- [ ] without_prefix
- [ ] set_user
- [ ] list
- [ ]

### Sender fields
- [ ] add
- [ ] delete
- [ ] list
- [ ] with_nat_names
- [ ] default

### Phonebook
- [ ] get_group
- [ ] list_groups
- [ ] add_group
- [ ] info
- [ ] edit_group
- [ ] name
- [ ] delete_group
- [ ] remove_contacts
- [ ] get_contact
- [ ] list_contacts
- [ ] groups
- [ ] text_search
- [ ] gender
- [ ] number
- [ ] order_by
- [ ] order_dir
- [ ] limit
- [ ] offset
- [ ] add_contact
- [ ] first_name
- [ ] last_name
- [ ] email
- [ ] birthday
- [ ] city
- [ ] groups
- [ ] edit_contact
- [ ] add_to_group
- [ ] remove_from_groups
- [ ] delete_contact

## Additional features
- [ ] content validator
- [ ] date validator
- [x] debug mode
- [ ] events
- [ ] host auto-switch
- [ ] idx generator
- [ ] idx validator
- [ ] logger
- [ ] multithreading
- [ ] phone validator
- [ ] profile mode
- [ ] SMIL generator
- [ ] SMIL validator
- [ ] subject validator
- [ ] test request

## ToDo
 * add docs (http://dlang.org/ddoc.html)
 * add tests (http://dlang.org/unittest.html)
 * use dstyle (http://dlang.org/dstyle.html)
 * use dub (http://code.dlang.org)
 * use versions tags
 * consider use contracts
 * rethink `Method`
 * consider use `interface`
 * consider use `union`
 * use `RedBlackTree` for `parameters` in `RequestBuilder`
 * redesign `mms.d` like `sms.d`
 * redesign `vms.d` like `sms.d`
 * redesign `hlr.d` like `sms.d`
 * rethink current visibility (http://dlang.org/attribute.html#ProtectionAttribute)
 * add `ReceiverSet` that can not be empty
 * rethink `VariableCollection`
 * add tests for SMSAPI
 * create `Message` with internally choosen type (SMS, MMS...)
