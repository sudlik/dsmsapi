# DSmsApi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)),
written in D programming language ([dlang.org](http://dlang.org))
## Examples
### SMS
``` d
#!/usr/bin/env rdmd

import std.stdio : writeln;

import dsmsapi.core : Content, Receiver;
import dsmsapi.api  : Api, HOST, User;
import dsmsapi.sms  : CHARSET, SendSms, Sms, TYPE;

void main()
{
    Sms sms;
    SendSms sendSms;

    User user           = User("username", "password");
    Receiver receiver   = Receiver(555012345);
    Content content     = Content("Hello world!");

    Api api = new Api(user, HOST.PLAIN_1)
        .setTest(true);

    sms = new Sms(TYPE.ECO, receiver, content)
        .setCharset(CHARSET.UTF_8)
        .setNormalize(true);

    sendSms = new SendSms(sms);

    writeln(api.execute(sendSms).content);
}
```
### MMS
...
### Pattern
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
 * examples
 * debug mode
 * docs
 * tests