# Lua `#inst`

A simple implementation of [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date parser for Lua via patterns, and implementation of the `#inst` tagged literal from Clojure.

## Rationale

Lua doesn't have inbuilt support for parsing date strings.
So I've thought: "what would it take to make a simple ISO8601 parser via Lua's patterns?"
Patterns in Lua don't allow alterations, or optional groups, so to workaround this, I've predefined common date and time formats supported by ISO 8601, and composed those into all possible variants.
The resulting `inst` functions support the following formats: `YYYY`, `YYYY-MM`, `YYYY-MM-DD`, `YYYY-MM-DDThh:mm:ssZ`, `YYYY-MM-DDThh:mm:ss.msZ`, `YYYY-MM-DDThh:mm:ss±hh:mm`, and `YYYY-MM-DDThh:mm:ss.ms±hh:mm`, where the dashes and the colon in the zone offset are optional.

And because Lua allows function calls without parentheses if there's only one literal argument, and also allows overriding the `#` operator for tables, I've decided to make it work like Clojure's `#inst` tagged literal.

``` lua
Lua 5.4.3  Copyright (C) 1994-2021 Lua.org, PUC-Rio
> inst = require "inst"
> #inst "2021"
#inst "2021-01-01T00:00:00.000-00:00"
> #inst "2021-11"
#inst "2021-11-01T00:00:00.000-00:00"
> #inst "2021-11-21"
#inst "2021-11-21T00:00:00.000-00:00"
> #inst "2021-11-21T23:01:42Z"
#inst "2021-11-21T23:01:42.000-00:00"
> #inst "2021-11-21T23:01:42.228Z"
#inst "2021-11-21T23:01:42.228-00:00"
> #inst "2021-11-21T23:01:42.228+03:00"
#inst "2021-11-21T20:01:42.228-00:00"
> #inst "2021-11-21T23:01:42.228-03:00"
#inst "2021-11-22T02:01:42.228-00:00"
```

Calling `#inst` on a string returns a representation that can be read back directly by the Lua reader, thus acting as a data literal.
Lua still doesn't support dates, but with this library, you can use this "tag" to implement some support, as the returned table format is fully compatible with `os.time` and `os.date`:

``` lua
> os.date("%c", os.time(inst "2021-11-21T23:01:42.228-03:00"))
Mon Nov 22 02:01:42 2021
```

The `#inst` syntax idea is taken from Clojure:

``` clojure
Clojure 1.10.3
user=> #inst "2021"
#inst "2021-11-21T20:01:42.123-00:00"
user=> #inst "2021-11-21T23:01:42.123-03:00"
#inst "2021-11-22T02:01:42.123-00:00"
```

## Caveats

This repository is more of a proof of concept.
The parser doesn't fully implement ISO 8601 standard.

Use at your own risk.
