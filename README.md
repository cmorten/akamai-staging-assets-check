# akamai-staging-assets-check

This project is for check the status of assets in Akamai Staging.

## Usage

The script will currently only work for MacOS Mojave. In it's current state it is geared towards personal use opposed to use in CI pipelines.

To check assets, first update the `ASSET_PATHS` array with the list of asset paths you wish to test and the `BASE_DOMAIN` for the domain the assets are hosted on.

Once configuration is set, run the script by

```console
./akamai-staging-assets-check.sh
```
