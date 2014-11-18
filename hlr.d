module dsmsapi.hlr;

import std.array : empty, join;
import std.conv  : to;

import dsmsapi.core : Idx, InvalidIdxException, Method, Parameter, ParamName, RequestBuilder, Resource;

class Hlr
{
    immutable {
        Idx[] idxes;
        int[] numbers;
    }

    pure this(int[] numbers, Idx[] idxes = [])
    {
        this.idxes   = to!(immutable Idx[])(idxes);
        this.numbers = to!(immutable int[])(numbers);
    }

    pure this(int number, Idx idx)
    {
        this([number], [idx]);
    }

    pure this(int number, Idx idxes[])
    {
        this([number], idxes);
    }

    pure this(int[] numbers, Idx idx)
    {
        this(numbers, [idx]);
    }
}

class Check : Method
{
    private:
        static const {
            Resource resource = Resource.hlr;
            string
                numberSeparator = ",",
                idxSeparator = ",";
        }

        Hlr hlr;

    public:
        @safe pure this(Hlr hlr)
        {
            this.hlr = hlr;
        }

        RequestBuilder createRequestBuilder()
        {
            RequestBuilder requestBuilder = new RequestBuilder;

            requestBuilder.resource = resource;

            requestBuilder.setParameter(
                new Parameter(ParamName.number, join(to!(string[])(hlr.numbers), numberSeparator))
                );

            if (!empty(hlr.idxes)) {
                requestBuilder.setParameter(new Parameter(ParamName.idx, join(to!(string[])(hlr.idxes), idxSeparator)));
            }

            return requestBuilder;
        }
}