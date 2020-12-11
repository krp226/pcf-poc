#!/bin/bash -eux
chmod +x ./jq/jq-linux64
cp jq/jq-linux64 /usr/local/bin/jq
chmod +x ./om-cli/om-linux
cp om-cli/om-linux /usr/local/bin/om
echo $ZSCALER_CERT |  sed 's/----- /-----\n/g' | sed 's/ -----/\n-----/g' | sed '2s/ /\n/g' > zscaler.crt
mv zscaler.crt /usr/local/share/ca-certificates/
update-ca-certificates
exec > generated-html/certs_expiry.html
cd generated-html
count=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | grep -c 'configurable')
#echo $count
max=$(($count-1))
#echo $max
echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "<style>"
echo "table, th, td {  border: 1px solid black; border-collapse: collapse;}"
echo "</style>"
echo "</head>"
echo "<body>"
echo "<h2>Sample certs expiry Report</h2>"
echo "<table style="width:100%">"
echo "<tr>"
echo "<th>" "validity date" "</th>"
echo "<th>" "configurable" "</th>"
echo "<th>" "property_type" "</th>"
echo "<th>" "product_guid" "</th>"
echo "<th>" "property_reference" "</th>"
echo "<th>" "issuer" "</th>"
for (( i=0; i <= $max; i++ ))
do
  #echo $i
  echo "<tr>"
  column1=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | jq '.certificates['$i'].valid_until')
  column2=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | jq '.certificates['$i'].configurable')
  column3=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | jq '.certificates['$i'].property_type')
  column4=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | jq '.certificates['$i'].product_guid')
  column5=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | jq '.certificates['$i'].property_reference') 
  column6=$(om --target=https://$OPSMAN_URL/ --username=$OPSMAN_USERNAME --password=$OPSMAN_PASSWORD --skip-ssl-validation=true curl -p https://$OPSMAN_URL/api/v0/deployed/certificates?expires_within=8m --silent | jq '.certificates['$i'].issuer')
  echo "<th>" "$column1" "</th>"
  echo "<th>" "$column2" "</th>"
  echo "<th>" "$column3" "</th>"
  echo "<th>" "$column4" "</th>"
  echo "<th>" "$column5" "</th>"
  echo "<th>" "$column6" "</th>"
done
echo "</table>"
echo "</body>"
echo "</html>"
