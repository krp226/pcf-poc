#!/bin/bash
#set -eux
apt-get update
apt-get install gettext-base gnupg2 wget vim -y
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
apt-get update
apt-get install jq cf-cli -y


export datetime=$(date '+%Y-%m-%d %H:%M:%S')
echo $datetime

input_start=$(date '+%Y-%m-%d' -d '-1 day')
input_end=$(date '+%Y-%m-%d')

touch maxdata.json
var='{ "TimeStamp": "${datetime}", "Environment": "${ENV}", "Org": ['
echo $var > maxdata.json
envsubst < maxdata.json > maxupdate.json

cf login -a ${Endpoint} -u ${USERNAME} -p ${PASSWORD} -o ${ORG} -s ${SPACE} --skip-ssl-validation
orgs="$(cf curl /v3/organizations | jq -r '.resources[].name')"
IFS='
'
for i in ${orgs}
do
  if [ "'${i}'" == "'system'" ] || [ "'${i}'" == "'credhub-service-broker-org'" ]
  then
    echo "Skipping Org ------------------------------ $i"
  else
    echo "Org ------------------------------ $i"
    count=0
    orgguid=$(cf org "$i" --guid)
    var='{"Spaces": ['
    echo $var > maxdata.json
    envsubst < maxdata.json >> maxupdate.json
    spaces=$(cf curl /v3/spaces?organization_guids=${orgguid} | jq -r '.resources[].name')
    IFS='
    '
    for j in ${spaces}
    do
      spacemaxai=0
      spacemaxai=$(curl "https://${ApiEndpoint}/proxy/home/accounting_report/organizations/${orgguid}/app_usages?start=${input_start}&end=${input_end}" -k -H "authorization: `cf oauth-token`" | jq -r '[[.app_usages[] | select(.space_name == "'${j}'") | {app: .app_name, count: .instance_count}] | sort_by(.app, .count) | group_by(.app) | .[] | last | .count] | add')
      echo "Org: ${i}, Space: ${j}, SpaceMaxAI: ${spacemaxai}, Startdate: ${input_start}, EndDate: ${input_end}"
      export i=${i}
      export j=${j}
      export spacemaxai=${spacemaxai}
      export input_start=${input_start}
      export input_end=${input_end}
      var='{"Name": "${j}", "SpaceMaxAIs": "${spacemaxai}"}'
      echo $var > maxdata.json
      envsubst < maxdata.json >> maxupdate.json
      var=','
      echo $var > maxdata.json
      envsubst < maxdata.json >> maxupdate.json
      if [ "'${spacemaxai}'" == "'null'" ]
      then
        spacemaxai=0
      fi
      let count=$count+$spacemaxai
    done
    echo ${count}
    sed -i '$s/,//' maxupdate.json
    var='],'
    echo $var >> maxupdate.json
    export count=${count} 
    var='"Name": "${i}", "OrgMaxAIs": "${count}"}'
    echo $var > maxdata.json
    envsubst < maxdata.json >> maxupdate.json
    var=','
    echo $var > maxdata.json
    envsubst < maxdata.json >> maxupdate.json
  fi
done
sed -i '$s/,//' maxupdate.json
var=']}'
echo $var >> maxupdate.json
#cat maxupdate.json

mv /tools/json2dyno .

./json2dyno -u ${AWSKEY} -pw ${AWSVALUE} -r ${AWSREGION} -t ${TABLE} -p "maxupdate.json" -f ${FUNCTION}

sed -i '1s/^/{"sourcetype": "json",  "event":/' maxupdate.json

echo "}" >> maxupdate.json

curl -X POST -H "Content-Type: application/json"  -H "X-SF-Token: ${SIGNALFX_TOKEN}" -d @maxupdate.json https://ingest.us1.signalfx.com/v1/log

curl --insecure -X POST -H "Content-Type: application/json"  -H "Authorization: Splunk ${SPLUNK_TOKEN}" -d @maxupdate.json https://<>:8088/services/collector

cat maxupdate.json
