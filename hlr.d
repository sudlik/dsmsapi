module dsmsapi.hlr;

import std.array : empty, join;
import std.conv  : to;
import std.regex : matchFirst;

import dsmsapi.core : Method, Parameter, ParamName, Path, RequestBuilder;

const pattern = `[a-zA-Z0-9]{0,255}`;

class InvalidIdxException : Exception
{
    pure this(string name)
    {
        super(`Idx "` ~ name ~ `" does not match pattern: "/` ~ pattern ~ `/"`);
    }
}

class Hlr
{
    immutable {
        string[] idxes;
        int[]    numbers;
    }

    this(int[] numbers, string[] idxes = [])
    {
        this.numbers = to!(immutable int[])(numbers);

        foreach (string idx; idxes) {
            if (matchFirst(idx, pattern).length() != 1) {
                throw new InvalidIdxException(idx);
            }
        }

        this.idxes = to!(immutable string[])(idxes);
    }
}

class Check : Method
{
    private:
        static const {
            Path path = Path.hlr;
            string
                numberSeparator = ",",
                idxSeparator = ",";
        }

        Hlr hlr;

    public:
        pure this(Hlr hlr)
        {
            this.hlr = hlr;
        }

        RequestBuilder createRequestBuilder()
        {
            RequestBuilder requestBuilder = new RequestBuilder;

            requestBuilder.path = path;

            requestBuilder.setParameter(
                new Parameter(ParamName.number, join(to!(string[])(hlr.numbers), numberSeparator))
                );

            if (!empty(hlr.idxes)) {
                requestBuilder.setParameter(new Parameter(ParamName.idx, join(to!(string[])(hlr.idxes), idxSeparator)));
            }

            return requestBuilder;
        }
}
