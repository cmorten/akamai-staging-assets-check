#!/bin/bash

function usage() {
  echo "akamai-staging-assets-check - check the status of assets in Akamai staging"
  echo " "
  echo "Usage:"
  echo " "
  echo "./akamai-staging-assets-check.sh [flags]"
  echo " "
  echo "Flags:"
  echo "-h                        show brief help"
  echo "-a          [REQUIRED]    specify an asset path to check (can use multiple times)"
  echo "-b          [REQUIRED]    specify the base domain for assets"
  echo " "
  echo "Example:"
  echo " "
  echo '    ./akamai-staging-assets-check.sh -a "/asset/path/one.js" -a "/asset/path/two.js" -b "my.assets.com"'
}

ASSET_PATHS=()
BASE_DOMAIN=""

while getopts "a:b:h" opt; do
    case $opt in
        a) ASSET_PATHS+=("${OPTARG}");;
        b) BASE_DOMAIN="${OPTARG}";;
        h) usage; exit 0;;
    esac
done
shift $((OPTIND - 1))

if [ -z ${BASE_DOMAIN} ]; then
  echo -e "Error: A base domain must be provided.\n"
  usage
  exit 1
fi

if [ -z ${ASSET_PATHS} ]; then
  echo -e "Error: At least one asset path must be provided.\n"
  usage
  exit 1
fi

akamaiDomain=$(nslookup ${BASE_DOMAIN} | grep "Name:.*akamaiedge.net" | cut -f2- -d: | xargs)
akamaiStagingDomain=${akamaiDomain//akamaiedge/akamaiedge-staging}

echo -e "BASE DOMAIN:\t\t\t${BASE_DOMAIN}"
echo -e "AKAMAI CNAME:\t\t\t${akamaiDomain}"
echo -e "AKAMAI STAGING CNAME:\t\t${akamaiStagingDomain}\n"
echo -e "Asset Status Checks:"

connectToString="${BASE_DOMAIN}:443:${akamaiStagingDomain}:443"
exitCode=0

for assetPath in "${ASSET_PATHS[@]}"; do
  assetUrl="https://${BASE_DOMAIN}${assetPath}"
  stagingAssetStatusCode=$(curl -s --connect-to ${connectToString} -o /dev/null -w '%{http_code}' ${assetUrl})
  echo -e "\t${stagingAssetStatusCode}\t${assetUrl}"

  if [ ${stagingAssetStatusCode} -ne 200 ]; then
    exitCode=1
  fi
done

exit ${exitCode}