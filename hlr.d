module dsmsapi.hlr;

import std.array : empty, join;
import std.conv  : to;
import std.regex : matchFirst;

import dsmsapi.core : Method, Parameter, PARAMETER, PATH, RequestBuilder;

struct Hlr
{
    private string pattern = `[a-zA-Z0-9]{0,255}`;

    immutable {
        string idx;
        int[]  numbers;
    }

    this(int[] numbers, string idx = "")
    {
        this.numbers = to!(immutable int[])(numbers);

        if (idx != "") {
            if (matchFirst(idx, pattern).length() == 1) {
                this.idx = to!(immutable string)(idx);
            } else {
                throw new Exception("Invalid idx (/" ~ pattern ~ "/)");
            }
        }
    }
}

class Check : Method
{
    static const PATH path = PATH.HLR;

    private Hlr hlr;

    this(Hlr hlr)
    {
        this.hlr = hlr;
    }

    RequestBuilder getRequestBuilder()
    {
        RequestBuilder requestBuilder = new RequestBuilder()
            .setPath(path)
            .setParameter(new Parameter(PARAMETER.NUMBER, join(to!(string[])(hlr.numbers), ",")));

        if (hlr.idx != "") {
            requestBuilder.setParameter(new Parameter(PARAMETER.IDX, hlr.idx))
        }

        return requestBuilder;
    }
}