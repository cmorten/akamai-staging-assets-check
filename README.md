# akamai-staging-assets-check

This project is for check the status of assets in Akamai staging.

## Usage

The script has only been tested on MacOS Mojave and not guaranteed to work elsewhere

```console
akamai-staging-assets-check - check the status of assets in Akamai staging

Usage:

akamai-staging-assets-check [flags]

Flags:
-h                        show brief help
-a          [REQUIRED]    specify an asset path to check (can use multiple times)
-b          [REQUIRED]    specify the base domain for assets

Example:

    akamai-staging-assets-check -a /asset/path/one.js -a /asset/path/two.js -b my.assets.com
```
