#!/bin/bash

apt-get update
apt-get install gnupg2 wget vim -y

wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v2.0.2/pivnet-linux-amd64-2.0.2
mv pivnet-linux-amd64-2.0.2 /usr/local/bin/pivnet
chmod +x /usr/local/bin/pivnet

#wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | apt-key add -
#echo "deb http://apt.starkandwayne.com stable main" | tee /etc/apt/sources.list.d/starkandwayne.list

wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

apt-get update
#apt-get install om jq cf-cli -y

apt-get install cf-cli -y

cf install-plugin -r CF-Community "report-buildpacks" -f
cf login -a ${Endpoint} -u ${USERNAME} -p ${PASSWORD} -o ${ORG} -s ${SPACE} --skip-ssl-validation
cf report-buildpacks

pivnet login --api-token=${PIVNET_API_TOKEN}

function check_pivnet_version(){

  VER=$2
  VER=${VER//./\\.}
  PIV_VERSION=$(pivnet releases -p $1 | grep $VER | head -n 2 | cut -d'|' -f3,4)
  echo $PIV_VERSION

}

function check_pivnet_latest_version(){

  PIV_LATEST_VERSION=$(pivnet releases -p $1 | sed -n '4p' | cut -d'|' -f3,4)
  echo $PIV_LATEST_VERSION

}


products=$(om -t ${OPSMAN_URL} -u ${OPSMAN_USERNAME} -p ${OPSMAN_PASSWORD} -k curl --path /api/v0/deployed/products | jq -r '.[]' | jq -r '.type,.product_version,"\\n"')

echo -e $products | while read line; do
  PRODUCT=${line% *}
  VERSION=${line##* }
#  echo "Product: "$PRODUCT
#  echo "Ver: "$VERSION
  # echo "line: "$line
  if [ "$line" == "" ]; then
      break
  fi
#echo ""
#echo ""
  if [ ${PRODUCT} == cf ];then
   PRODUCT=elastic-runtime
   MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   echo "CURRENT VERSION DETAILS: Product: ${PRODUCT}, Major Version is: ${MAJOR_VERSION}"
   PIVNET_VERSION=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION | cut -d'|' -f1)
   PIVNET_LATEST_VERSION=$(check_pivnet_latest_version $PRODUCT)
   PIVNET_LATEST_VERSION=$( echo $PIVNET_LATEST_VERSION | cut -d'|' -f1)
   echo "Current Version is:              $VERSION"
   echo "Pivnet latest minor version is:  $PIVNET_VERSION"
   echo "Pivnet latest major version is:  $PIVNET_LATEST_VERSION"
  elif [ ${PRODUCT} == p-bosh ];then
   PRODUCT=ops-manager
   MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   CURRENT_VERSION=$(pivnet releases -p $PRODUCT | grep $VERSION -B1 | cut -d'|' -f3)
   echo "CURRENT VERSION DETAILS: Product: $PRODUCT, Major Version is: $MAJOR_VERSION"
   #Speical processing
   PIVNET_VERSION_OUT=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION_OUT | cut -d'|' -f1)
   PIVNET_SPECIAL_VERSION=$( echo $PIVNET_VERSION_OUT | cut -d'|' -f3,3)
   PIVNET_LATEST_VERSION=$(check_pivnet_latest_version $PRODUCT)
   PIVNET_LATEST_VERSION=$( echo $PIVNET_LATEST_VERSION | cut -d'|' -f1)
   echo "Current Version is:              $VERSION"
   echo "Pivnet latest minor version is:  $PIVNET_VERSION"
   #echo "Pivnet special version is:       $PIVNET_SPECIAL_VERSION"
   echo "Pivnet latest major version is:  $PIVNET_LATEST_VERSION"
  elif [ ${PRODUCT} == appMetrics ];then
   PRODUCT=apm
   MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   echo "CURRENT VERSION DETAILS: Product: ${PRODUCT}, Major Version is: ${MAJOR_VERSION}"
   PIVNET_VERSION=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION | cut -d'|' -f1)
   PIVNET_LATEST_VERSION=$(check_pivnet_latest_version $PRODUCT)
   PIVNET_LATEST_VERSION=$( echo $PIVNET_LATEST_VERSION | cut -d'|' -f1)
   echo "Current Version is:              $VERSION"
   echo "Pivnet latest minor version is:  $PIVNET_VERSION"
   echo "Pivnet latest major version is:  $PIVNET_LATEST_VERSION"
  elif [ ${PRODUCT} ==  metric-store ];then
   PRODUCT=p-metric-store
   MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   echo "CURRENT VERSION DETAILS: Product: ${PRODUCT}, Major Version is: ${MAJOR_VERSION}"
   PIVNET_VERSION=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION | cut -d'|' -f1)
   PIVNET_LATEST_VERSION=$(check_pivnet_latest_version $PRODUCT)
   PIVNET_LATEST_VERSION=$( echo $PIVNET_LATEST_VERSION | cut -d'|' -f1)
   echo "Current Version is:              $VERSION"
   echo "Pivnet latest minor version is:  $PIVNET_VERSION"
   echo "Pivnet latest major version is:  $PIVNET_LATEST_VERSION"
  else
   MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   echo "CURRENT VERSION DETAILS: Product: ${PRODUCT}, Major Version is: ${MAJOR_VERSION}"
   PIVNET_VERSION=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION | cut -d'|' -f1)
   PIVNET_LATEST_VERSION=$(check_pivnet_latest_version $PRODUCT)
   PIVNET_LATEST_VERSION=$( echo $PIVNET_LATEST_VERSION | cut -d'|' -f1)
   echo "Current Version is:              $VERSION"
   echo "Pivnet latest minor version is:  $PIVNET_VERSION"
   echo "Pivnet latest major version is:  $PIVNET_LATEST_VERSION"
  fi
echo ""
done
