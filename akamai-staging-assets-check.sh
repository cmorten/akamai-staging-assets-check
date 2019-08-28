#!/bin/bash

# Configuration
ASSET_PATHS=()
  
BASE_DOMAIN=""

if [ -z ${ASSET_PATHS} ]; then
  echo "Missing 'ASSET_PATHS'. Exiting."
  exit 1
fi

if [ -z ${BASE_DOMAIN} ]; then
  echo "Missing 'BASE_DOMAIN'. Exiting."
  exit 1
fi


ETC_HOSTS=/etc/hosts

function removeHost() {
    hostname=$1
    if [ -n "$(grep ${hostname} ${ETC_HOSTS})" ]; then
        echo -e "${hostname} found in ${ETC_HOSTS}.\nRemoving ${hostname} now...";
        sudo sed -i ".bak" "/${hostname}/d" ${ETC_HOSTS}
    else
        echo "${hostname} was not found in ${ETC_HOSTS}";
    fi
}

function addHost() {
    hostname=$1
    ip=$2
    hostsLine="${ip}\t${hostname}"
    if [ -n "$(grep ${hostname} ${ETC_HOSTS})" ]; then
      echo "${hostname} already exists: $(grep ${hostname} ${ETC_HOSTS})"
    else
      echo "Adding ${hostname} to your ${ETC_HOSTS}";
      sudo -- sh -c -e "echo '${hostsLine}' >> ${ETC_HOSTS}";

      if [ -n "$(grep ${hostname} ${ETC_HOSTS})" ]; then
        echo -e "${hostname} was added successfully\n$(grep ${hostname} ${ETC_HOSTS})";
      else
        echo "Failed to Add ${hostname}.\nTry again.";
      fi
    fi
}

function flushDNS() {
  sudo killall -HUP mDNSResponder
}

akamaiDomain=$(nslookup ${BASE_DOMAIN} | grep "Name:.*akamaiedge.net" | cut -f2- -d: | xargs)
akamaiStagingDomain=${akamaiDomain//akamaiedge/akamaiedge-staging}
akamaiStagingIP=$(nslookup ${akamaiStagingDomain} | grep "Address:.*" | tail -1 | cut -f2- -d: | xargs)

echo -e "AKAMAI CNAME:\t\t\t${akamaiDomain}"
echo -e "AKAMAI Staging CNAME:\t\t${akamaiStagingDomain}"
echo -e "AKAMAI Staging IP:\t\t${akamaiStagingIP}"

echo "Adding Akamai staging config to ${ETC_HOSTS}..."
addHost ${BASE_DOMAIN} ${akamaiStagingIP}

echo "Flushing DNS..."
flushDNS

for assetPath in "${ASSET_PATHS[@]}"; do
  assetUrl="https://${BASE_DOMAIN}${assetPath}"

  while ! curl -s -I ${assetUrl} | grep -m1 "x-akamai-staging" > /dev/null; do
    echo "Staging header not found. Sleeping..."
    sleep 1
  done

  stagingAssetStatusCode=$(curl -s -o /dev/null -w '%{http_code}' ${assetUrl})
  echo "Received status '${stagingAssetStatusCode}' for asset at url '${assetUrl}'."
done

echo "Removing Akamai staging config from ${ETC_HOSTS}..."
removeHost ${BASE_DOMAIN}

echo "Flushing DNS..."
flushDNS