#!/bin/bash
apt-get update -y
apt-get install -y wget vim telnet gnupg jq
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
# ...then, update your local package index, then finally install the cf CLI

apt-get update -y
apt-get install -y cf-cli
StackstoRetain=${BUILDPACKSTORETAIN}
cf api $CF_API_URI --skip-ssl-validation
cf auth $CF_USERNAME $CF_PASSWORD
echo "Current Buildpacks list"
cf buildpacks

for STACK_NAME in $STACKS;
do
    #set +e
    existing_buildpack=$(cf buildpacks | grep "${BUILDPACK_NAME}" | grep "${STACK_NAME}")
    #set -e
    if [ -z "${existing_buildpack}" ]; then
      COUNT=$(cf buildpacks | grep --regexp=".zip" --count)
      NEW_POSITION=$(expr $COUNT + 1)
      echo "Latest Buildpack getting created"
      cf create-buildpack ${BUILDPACK_NAME} buildpack/*java-buildpack-offline-*.zip $NEW_POSITION --enable
      cf update-buildpack ${BUILDPACK_NAME} --assign-stack ${STACK_NAME}
      echo "Latest Buildpack Added"
    else
      index=$(echo $existing_buildpack | cut -d' ' -f2)
      echo $existing_buildpack | cut -d' ' -f2
      echo $existing_buildpack
      echo "Buildpack exists, updating buildpack"
      cf update-buildpack ${BUILDPACK_NAME} -p buildpack/*java-buildpack-offline-*.zip -s $STACK_NAME -i $index --enable
    fi
done
cf buildpacks


VERSION_DOWNLOADED=$(cat /tmp/build/ac5d84bf/buildpack/metadata.json | jq -r .Release.Version)
echo $VERSION_DOWNLOADED | sed 's/\./_/g' > VERSION
VERSION=$(cat VERSION)
for STACK_NAME in $STACKS;
do
    #set +e
    existing_buildpack=$(cf buildpacks | grep "${AUX_BUILDPACK_NAME}_${VERSION}" | grep "${STACK_NAME}")
    #set -e
    if [ -z "${existing_buildpack}" ]; then
      COUNT=$(cf buildpacks | grep --regexp=".zip" --count)
      NEW_POSITION=$(expr $COUNT + 1)
      echo "Creating Auxiliary Buildpack"
      cf create-buildpack ${AUX_BUILDPACK_NAME}_${VERSION} buildpack/*java-buildpack-offline-*.zip $NEW_POSITION --enable
      cf update-buildpack ${AUX_BUILDPACK_NAME}_${VERSION} --assign-stack ${STACK_NAME}
    else
      index=$(echo $existing_buildpack | cut -d' ' -f2)
      echo $existing_buildpack | cut -d' ' -f2
      echo $existing_buildpack
      echo "Buildpack exists"
      #cf update-buildpack ${AUX_BUILDPACK_NAME}_${VERSION} -p buildpack/*java-buildpack-offline-*.zip -s $STACK_NAME -i $index --enable
    fi
done
cf buildpacks

echo "Removing old buildpacks"
echo "Additinal Buildpacks of ${AUX_BUILDPACK_NAME}_ available are:"
cf buildpacks | grep ${AUX_BUILDPACK_NAME}_ | grep "$STACK_NAME" | cut -d' ' -f1
echo "Latest buildpacks to be retained: ${StackstoRetain}"
OldStackCount=$(cf buildpacks | grep ${AUX_BUILDPACK_NAME}_ | grep "$STACK_NAME" | cut -d' ' -f1 | wc -l)
echo "No of old buildpacks: ${OldStackCount}"
if [[ ${OldStackCount} > ${StackstoRetain} ]]; then
  StackstoDelete=$((${OldStackCount}-${StackstoRetain}))
  echo "Buildpacks to be deleted: ${StackstoDelete}"
  #for StackCount in ${StackstoDelete};
  for (( c=1; c<=${StackstoDelete}; c++ ))
  do
      #set +e
      echo "Buildpack count: ${StackCount}"
      cf_buildpack_name=$(cf buildpacks | grep ${AUX_BUILDPACK_NAME}_ | grep "$STACK_NAME" | cut -d' ' -f1 | head -n 1)
      echo "Deleting stack ${cf_buildpack_name}"
      cf delete-buildpack ${cf_buildpack_name} -s $STACK_NAME -f
      echo "Buildpack deleted, updated list"
      cf buildpacks | grep ${AUX_BUILDPACK_NAME}_ | grep "$STACK_NAME"
  done
else
  echo "Avaialable buildpacks and to be retained count is same, no need to clean up"
  cf buildpacks | grep ${AUX_BUILDPACK_NAME}_ | grep "$STACK_NAME"
fi
echo "Final list of ${BUILDPACK_NAME} versions available"
cf buildpacks | grep ${BUILDPACK_NAME} | grep "$STACK_NAME"

echo "Final list of Buildpacks available"
cf buildpacks
