#!/bin/bash -eu
chmod +x ./jq/jq-linux64
cp jq/jq-linux64 /usr/local/bin/jq

chmod +x ./om-cli/om-linux
cp om-cli/om-linux /usr/local/bin/om
chmod +x ./pivnet-cli/pivnet-linux-*
cp pivnet-cli/pivnet-linux-* /usr/local/bin/pivnet
echo $ZSCALER_CERT |  sed 's/----- /-----\n/g' | sed 's/ -----/\n-----/g' | sed '2s/ /\n/g' > zscaler.crt
mv zscaler.crt /usr/local/share/ca-certificates/
update-ca-certificates
#awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
pivnet login --api-token=${PIVNET_API_TOKEN}

function check_pivnet_version(){

  VER=$2
  VER=${VER//./\\.}
  PIV_VERSION=$(pivnet releases -p $1 | grep $VER | head -n 2 | cut -d'|' -f3,4)
  echo $PIV_VERSION

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
   echo "CURRENT VERSION DETAILS:  Product : ${PRODUCT} , Version is : ${VERSION} , Major Version is : ${MAJOR_VERSION}"
   echo "CURRENT VERSION DETAILS:  Product : ${PRODUCT} , Version is : ${VERSION} , Major Version is : ${MAJOR_VERSION}" >> generated-versions/current_versions.txt
   PIVNET_VERSION=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION | cut -d'|' -f1)
   echo "Pivnet latest version is : $PIVNET_VERSION"
   echo "Pivnet latest version is : $PIVNET_VERSION" >> generated-versions/current_versions.txt
  elif [ ${PRODUCT} == p-bosh ];then
   PRODUCT=ops-manager
   MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   CURRENT_VERSION=$(pivnet releases -p $PRODUCT | grep $VERSION -B1 | cut -d'|' -f3)
   echo "CURRENT VERSION DETAILS:  Product : ${PRODUCT} , Real Version is: $CURRENT_VERSION , Version is : ${VERSION} , Major Version is : ${MAJOR_VERSION}"
   echo "CURRENT VERSION DETAILS:  Product : ${PRODUCT} , Real Version is: $CURRENT_VERSION , Version is : ${VERSION} , Major Version is : ${MAJOR_VERSION}" >> generated-versions/current_versions.txt
   #Speical processing
   PIVNET_VERSION_OUT=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION_OUT | cut -d'|' -f1)
   PIVNET_SPECIAL_VERSION=$( echo $PIVNET_VERSION_OUT | cut -d'|' -f3)
   echo "Pivnet latest version is : $PIVNET_VERSION" 
   echo "Pivnet special version is : $PIVNET_SPECIAL_VERSION"
   echo "Pivnet latest version is : $PIVNET_VERSION" >> generated-versions/current_versions.txt 
   echo "Pivnet special version is : $PIVNET_SPECIAL_VERSION" >> generated-versions/current_versions.txt 
  else
    MAJOR_VERSION=$(echo $VERSION | grep -o '[0-9]\{1,2\}\.[0-9]\{1,2\}')
   echo "CURRENT VERSION DETAILS:  Product : ${PRODUCT} , Version is : ${VERSION} , Major Version is : ${MAJOR_VERSION}"
   echo "CURRENT VERSION DETAILS:  Product : ${PRODUCT} , Version is : ${VERSION} , Major Version is : ${MAJOR_VERSION}" >> generated-versions/current_versions.txt
   PIVNET_VERSION=$(check_pivnet_version $PRODUCT $MAJOR_VERSION)
   PIVNET_VERSION=$( echo $PIVNET_VERSION | cut -d'|' -f1)
   echo "Pivnet latest version is : $PIVNET_VERSION"
   echo "Pivnet latest version is : $PIVNET_VERSION" >> generated-versions/current_versions.txt
  fi
echo ""
done
