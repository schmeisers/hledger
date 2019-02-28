User-visible changes in hledger-api.
See also the hledger changelog.

# 1.13 (2019/02/01)

- use hledger 1.13

# 1.12 (2018/12/02)

-   use hledger 1.12

# 1.11.1 (2018/10/06)

-   use hledger 1.11.1

# 1.11 (2018/9/30)

-   use hledger 1.11

# 1.10 (2018/6/30)

-   use hledger-lib 1.10

# 1.9.1 (2018/4/30)

-   use hledger-lib 1.9.1

# 1.9 (2018/3/31)

-   support ghc 8.4, latest deps

-   when the system text encoding is UTF-8, ignore any UTF-8 BOM prefix
    found when reading files

# 1.5 (2017/12/31)

-   remove upper bounds on all but hledger* and base (experimental)

# 1.4 (2017/9/30)

-   api: add support for swagger2 2.1.5+ (fixes #612)

# 1.3.1 (2017/8/25)

-   require servant-server 0.10+ to fix compilation warning

-   restore upper bounds on hledger packages

# 1.3 (2017/6/30)

Depends on hledger\[-lib\] 1.3, see related changelogs.

# 1.2 (2017/3/31)

see project changes at http://hledger.org/release-notes

# 1.1 (2016/12/31)

-   serves on 127.0.0.1 by default, --host option added (#432)

    Consistent with hledger-web: serves only local requests by default,
    use --host=IPADDR to change this.

-   fixed the version string in command-line help and swagger info

# 1.0 (2016/10/26)

## misc

-   new hledger-api tool: a simple web API server with example clients (#316)

-   start an Angular-based API example client (#316) (Thomas R. Koll)
