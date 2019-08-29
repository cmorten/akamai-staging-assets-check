# akamai-staging-assets-check

This project is for check the status of assets in Akamai staging.

## Usage

There are two scripts available, a powershell and a bash script. Both have the same functionality, just the argument syntax is subtly different.

### Powershell

```console
akamai-staging-assets-check - check the status of assets in Akamai staging

Usage:

./akamai-staging-assets-check.ps1 [BaseDomain] [AssetPath,...] [flags]

Parameters:
-Help                         show brief help
-AssetPaths     [REQUIRED]    specify the asset paths to check
-BaseDomain     [REQUIRED]    specify the base domain for assets

Examples:

    ./akamai-staging-assets-check.ps1 "my.assets.com" "/asset/path/one.js", "/asset/path/two.js"
    ./akamai-staging-assets-check.ps1 -BaseDomain "my.assets.com" -AssetPaths "/asset/path/one.js", "/asset/path/two.js"
```

### Bash

```console
akamai-staging-assets-check - check the status of assets in Akamai staging

Usage:

./akamai-staging-assets-check.sh [flags]

Flags:
-h                        show brief help
-a          [REQUIRED]    specify an asset path to check (can use multiple times)
-b          [REQUIRED]    specify the base domain for assets

Example:

    ./akamai-staging-assets-check.sh -a "/asset/path/one.js" -a "/asset/path/two.js" -b "my.assets.com"
```
