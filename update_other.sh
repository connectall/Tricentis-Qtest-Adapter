#!/bin/bash

. qtest_setup.sh $1 $2

# brew install jq
echo Log into qTest
if [ ! -e $APPLINK_read_token.json ]
then
	touch $APPLINK_read_token.json
fi


dte=`date -r $APPLINK_read_token.json "+%Y-%m-%dT%H%%3a%M%%3a%S.000${CA_timezone}%%3A00"`
#dte="2019-07-28T16%3a17%3a43.000%2B04%3A00"
echo Find all qTest records modified since $dte    

curl --header "Content-Type: application/x-www-form-urlencoded" -u "${qTestUserid}:" -X POST -d @login.json -c qtest.cookies $qTestUrl/oauth/token >$APPLINK_read_token.json
echo login response is: `cat $APPLINK_read_token.json`
TOKEN=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.GetQtestLoginToken access_token <$APPLINK_read_token.json`

echo Find all modified qTest records in the $PROJECT project using token $TOKEN and send them to ConnectALL at ${ConnectAllUrl}/connectall/api/2/postRecord?apikey=$ConnectAllApiKey
echo

if [ -e data.json ]
then
rm data.json
fi

#curl -v -o data.json --header "Authorization: Bearer $TOKEN" "$qTestUrl/api/v3/projects/$PROJECT/defects/last-change?startTime=$dte&start=1&pageSize=200"
curl --header "Authorization: Bearer $TOKEN" "$qTestUrl/api/v3/projects/$PROJECT/defects/last-change?startTime=$dte&start=1&pageSize=200" >data.json 

if [ -e data.json ]
then

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
else
	echo No new data found
	echo ""
fi

echo Log out
curl --header "Authorization: Bearer $TOKEN"  -X POST -c qtest.cookies $qTestUrl/oauth/revoke
