# timedot format

This doc is for version **1.2**. []{.docversions}

\$toc\$

## NAME

Timedot - hledger's human-friendly time logging format

## DESCRIPTION

Timedot is a plain text format for logging dated, categorised quantities
(eg time), supported by hledger. It is convenient for approximate and
retroactive time logging, eg when the real-time clock-in/out required
with a timeclock file is too precise or too interruptive. It can be
formatted like a bar chart, making clear at a glance where time was
spent.

Though called "timedot", the format does not specify the commodity being
logged, so could represent other dated, quantifiable things. Eg you
could record a single-entry journal of financial transactions, perhaps
slightly more conveniently than with hledger\_journal(5) format.

## FILE FORMAT

A timedot file contains a series of day entries. A day entry begins with
a date, and is followed by category/quantity pairs, one per line. Dates
are hledger-style [simple dates](#simple-dates) (see
hledger\_journal(5)). Categories are hledger-style account names,
optionally indented. There must be at least two spaces between the
category and the quantity. Quantities can be written in two ways:

1.  a series of dots (period characters). Each dot represents "a
    quarter" - eg, a quarter hour. Spaces can be used to group dots into
    hours, for easier counting.

2.  a number (integer or decimal), representing "units" - eg, hours. A
    good alternative when dots are cumbersome. (A number also can record
    negative quantities.)

Blank lines and lines beginning with \#, ; or \* are ignored. An
example:

``` {.timedot}
# on this day, 6h was spent on client work, 1.5h on haskell FOSS work, etc.
2016/2/1
inc:client1   .... .... .... .... .... ....
fos:haskell   .... .. 
biz:research  .

2016/2/2
inc:client1   .... ....
biz:research  .
```

Or with numbers:

``` {.timedot}
2016/2/3
inc:client1   4
fos:hledger   3
biz:research  1
```

Reporting:

``` {.shell}
$ hledger -f t.timedot print date:2016/2/2
2016/02/02 *
    (inc:client1)          2.00

2016/02/02 *
    (biz:research)          0.25
```

``` {.shell}
$ hledger -f t.timedot bal --daily --tree
Balance changes in 2016/02/01-2016/02/03:

            ||  2016/02/01d  2016/02/02d  2016/02/03d 
============++========================================
 biz        ||         0.25         0.25         1.00 
   research ||         0.25         0.25         1.00 
 fos        ||         1.50            0         3.00 
   haskell  ||         1.50            0            0 
   hledger  ||            0            0         3.00 
 inc        ||         6.00         2.00         4.00 
   client1  ||         6.00         2.00         4.00 
------------++----------------------------------------
            ||         7.75         2.25         8.00 
```

I prefer to use period for separating account components. We can make
this work with an [account alias](#account-aliases):

``` {.timedot}
2016/2/4
fos.hledger.timedot  4
fos.ledger           ..
```

``` {.shell}
$ hledger -f t.timedot --alias /\\./=: bal date:2016/2/4
                4.50  fos
                4.00    hledger:timedot
                0.50    ledger
--------------------
                4.50
```

Here is a
[sample.timedot](https://raw.github.com/simonmichael/hledger/master/examples/sample.timedot).
<!-- to download and some queries to try: -->

<!-- ```shell -->
<!-- $ hledger -f sample.timedot balance                               # current time balances -->
<!-- $ hledger -f sample.timedot register -p 2009/3                    # sessions in march 2009 -->
<!-- $ hledger -f sample.timedot register -p weekly --depth 1 --empty  # time summary by week -->
<!-- ``` -->

