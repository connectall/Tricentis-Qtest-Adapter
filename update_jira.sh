#!/bin/bash

. setup.sh

# brew install jq
echo Log into qTest
if [ ! -e read_token.json ]
then
	touch read_token.json
fi

dte=`date -r read_token.json "+%Y-%m-%dT%H%%3a%M%%3a%S.000${CA_timezone}%%3A00"`
echo Find all records modified since $dte    

curl --header "Content-Type: application/x-www-form-urlencoded" -u "${qTestUserid}:" -X POST -d @login.json -c qtest.cookies $qTestUrl/oauth/token >read_token.json
TOKEN=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.GetQtestLoginToken access_token <read_token.json`

echo Find modified records using token $TOKEN and send them to ConnectALL at ${ConnectAllUrl}/connectall/api/2/postRecord?apikey=$ConnectAllApiKey
echo

curl -o data.json --header "Authorization: Bearer $TOKEN" $qTestUrl/api/v3/projects/$PROJECT/defects/last-change?startTime=$dte&start=1&pageSize=200

i=0
json=`java -cp /Users/doug/git/qtest/target/qtest-0.0.1.jar:bin/json-20090211.jar com/connectall/adapter/qtest/QtestToConnectAllJson $APPLINK $QTEST_ORIGIN $i <data.json`
while [ $? -eq 0 ]
do
	((i++))
	echo $i times through the loop
	echo $json
	echo "$json" | curl --header "Content-Type: application/json;charset=UTF-8" -X POST -T - ${ConnectAllUrl}/connectall/api/2/postRecord?apikey=$ConnectAllApiKey
	json=`java -cp /Users/doug/git/qtest/target/qtest-0.0.1.jar:bin/json-20090211.jar com/connectall/adapter/qtest/QtestToConnectAllJson $APPLINK $QTEST_ORIGIN $i <data.json`
done

echo Log out
curl --header "Authorization: Bearer $TOKEN"  -X POST -c qtest.cookies $qTestUrl/oauth/revoke

