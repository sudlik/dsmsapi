# DSmsApi
## About
Client for SMSAPI REST API ([smsapi.pl/rest](http://smsapi.pl/rest)) written in D programming language ([dlang.org](http://dlang.org))
## Example
``` d
import smsapid.core : Content, Receiver;
import smsapid.api  : Api, HOST, User;
import smsapid.sms  : SendSms, Sms, TYPE;

void main()
{
    User user = User("username", "password");
    Api api = new Api(user, HOST.PLAIN_1, true);
    Receiver receiver = Receiver(555012345);
    Content content = Content("Hello world!");
    Sms sms = new Sms(TYPE.ECO, receiver, content);
    SendSms sendSms = new SendSms(sms);
    api.execute(sendSms);
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