module dsmsapi.hlr;

import std.array : empty, join;
import std.conv  : to;
import std.regex : matchFirst;

import dsmsapi.core : Method, Parameter, PARAMETER, PATH, RequestBuilder;

struct Hlr
{
    private string pattern = `[a-zA-Z0-9]{0,255}`;

    immutable {
        string[] idxes;
        int[]    numbers;
    }

    this(int[] numbers, string[] idxes = [])
    {
        this.numbers = to!(immutable int[])(numbers);
        this.idxes = to!(immutable string[])(idxes);

        foreach (string idx; idxes) {
            if (matchFirst(idx, pattern).length() != 1) {
                throw new Exception("Invalid idx (/" ~ pattern ~ "/)");
            }
        }
    }
}

class Check : Method
{
    static const {
        PATH path = PATH.HLR;
        string
            number_separator = ",",
            idx_separator = "|";
    }

    private Hlr hlr;

    this(Hlr hlr)
    {
        this.hlr = hlr;
    }

    RequestBuilder getRequestBuilder()
    {
        RequestBuilder requestBuilder = new RequestBuilder()
            .setPath(path)
            .setParameter(new Parameter(PARAMETER.NUMBER, join(to!(string[])(hlr.numbers), number_separator)));

        if (!empty(hlr.idxes)) {
            requestBuilder.setParameter(new Parameter(PARAMETER.IDX, join(to!(string[])(hlr.idxes), idx_separator)));
        }

        return requestBuilder;
    }
}