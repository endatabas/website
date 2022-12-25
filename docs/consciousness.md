
# Stream-of-Consciousness Document

* Author: Steven
* Tags: #why
* Date: 2022-12-25T17:20:00Z

I often find it useful to write my thoughts down instead of simply
thinking about them or discussing them out loud. Håkan may also find
this to be useful -- I'm not sure. Hence the `Author` key.

I see no point in locking these thoughts up in a private repository,
but I also see no point in publicly proclaiming our daily thoughts
about the design of Endatabas. This file is readable, but it is not
necessarily intended to be read.

This document is top-down, immutable, and unmaintained.

Format:

```
# Title

* Author: Your Name
* Tags: #ifyouwant #optionally
* Date: 1970-01-01 or 1970-01-01T00:00:00Z
```

Please double-space entries.


# SQL:2016 And So On

* Author: Steven
* Tags: #nested
* Date: 2022-12-25T18:00:00Z

On some level, it's a shame that XML hasn't retained the level of
popularity that JSON attained a generation later. SQL:2016 is
simultaneously tolerable (even attractive), in the light of decades-old
RDBMSes, and a bones-protruding-through-skin freak show, in the light
of document, property-graph, and other semi-structured data stores.

## API

The difficulty extends beyond the clunky interfaces of `JSON_*`
functions. `JSON_OBJECT` can be replaced by an optional `{'k': v}`
literal and so on, and queries could contain `parent.child.grandkid`
paths directly, as an extension. Still, the rough edges of SQL:2016
are most abrasive in the treatment of `NULL` and the unavoidable
nature of untyped JSON documents as second-class citizens.

Postgres is arguably more broken, in this regard. JSON is very clearly
segregated from native records in such a way as to feel the user has
walked through a JSON doorway into another query language entirely.
This is cleaner, but provides little opportunity to bridge these
worlds.

## Null

While the goal of the Endatabas SQL dialect is to bring the comfort
and plasticity of Clojure (if not all of Lisp) to database queries,
I must go out on a limb from the beginning to proclaim a distrust of
any possibility that our dialect will support "nil punning". Endb
will be schemaless and semi-structured, but the future will not
forgive us if we leave data in limbo. Everything must be strongly
typed -- and this includes `NULL`.

While Endatabas has little choice but to support 3VL (Three-Valued
Logic) in a way which will not surprise experienced SQL users, we
are bound to harm ourselves if we extend 3VL to a world of documents.
"Null as absence" is precisely the consequence of semi-structured
data trying to exist natively in older RDBMSes.

At this stage, I believe:

1. Homogenized tuple data, containing a superset of record keys,
should differentiate between `NULL` in the value position and `MISSING`
where a given key is not present.
2. Heterogeneous document data, containing nested objects
(dictionaries) should permit `NULL` in the value position. "Missing"
keys are inherent to documents.

## Types

Endatabas storage must support a comprehensive type system. What is
less clear to me at this point are the following:

* Will we diverge from SQL spec types to support UUIDs, URIs,
GIS (Geometry/Geography) types, and so on?
* Will we diverge from SQL spec formats to support ISO dates? (I
assum yes.)
* Will we force/support typed JSON onto clients which speak a
document-friendly variant of the Endatabas SQL dialect, if one exists?
If so, which brand?
* Is JSON Schema antithetical to Endatabas?

It seems "obvious" that the semi-structured format of choice for
clients which perform DML and DQL (particularly over HTTP) will be
JSON. What is less obvious is how to reconcile JSON's tiny, almost
nonexistent, type surface area with that of endb's SQL dialect,
execution, and storage engine.

As far as I'm concerned, this is the greatest UX design hurdle. We
want the SQL dialect to feel effortless, familiar, natural. We also
want it to be safe. Ambiguity, imprecision, and data loss are all
unforgivable at this stage.

## Spec Divergence

The more I consider our adherence to the SQL spec, the less concerned
I am with spec alignment for advanced functionality. No other SQL
vendor bothers with strict spec compliance, and it is the core of the
language which allows users to get started instantly that matters most.

The core should be spec-compliant.

I would argue that the Principle of Least Surprise should guide the
development of core-adjacent, spec-aligned features. Can a new user,
working on a real system, type arbitrary SQL into their program (not
a terminal) and get meaningful, debuggable results back? Can the
process of building on top of Endatabas be simple, easy, and fun?
When the system/service/app the user is building starts to get Very
Serious, can we guarantee their feeling of safety?

Semi-structured data is not native to any other SQL system and I am
more or less convinced that as soon as the user has begun to create
or query _nested_ data, we should feel completely at liberty to diverge
from the spec. If the user is only working with semi-structured _flat_
data, however, we should be extremely cautious. It is extremely
difficult to divorce these two, which (to my mind) necessitates the
existence of `MISSING`, our one early and forgivable transgression from
the spec for flat data.


--
