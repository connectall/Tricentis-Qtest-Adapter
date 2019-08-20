#!/bin/bash

if [ $# != 2 ]
then
    echo "Usage: ./update_qtest.sh AppLinkName QtestProjectId"
else

. qtest_setup.sh $1 $2

echo Log into qTest
if [ ! -e $APPLINK_write_token.json ]
then
	touch $APPLINK_write_token.json
fi
	
dte=`date -r $APPLINK_write_token.json "+%Y-%m-%d %H:%M:%S.000"`
curl --header "Content-Type: application/x-www-form-urlencoded" -u "${qTestUserid}:" -X POST -d @login.json -c qtest.cookies $qTestUrl/oauth/token >$APPLINK_write_token.json
TOKEN=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.GetQtestLoginToken access_token <$APPLINK_write_token.json`


# Find all the records updated at the other endpoint and write them to qTest
json=$(cat <<EOF
{
	"appLinkName":"$APPLINK",
	"origin":"$OTHER_ORIGIN",
	"lastModifiedTime":"$dte"
}
EOF
)
#	"lastModifiedTime":"2019-07-01 16:53:15.000"

echo Find the 'other' records updated since $dte from ConnectAll
echo "$json" | curl -o data.json --header "Content-Type: application/json;charset=UTF-8" -X POST -T - ${ConnectAllUrl}/connectall/api/2/search?apikey=$ConnectAllApiKey
echo the records to send to qTest are: `cat data.json`

# Convert the next read record and send it to qtest
i=0
ID=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.JsontoQTest $i qTestCustomAdapterDescriptor.json qTest.json <data.json`

while [ $? -eq 0 ]
do
	((i++))
	echo $i times through the loop
	cat qTest.json


	json=$(cat <<EOF
	{
		"appLinkName":"$APPLINK",
		"origin":"$OTHER_ORIGIN",
		"recordId":"$ID"}
	EOF
	)
	echo search for the record link using the json $json
	echo "$json" | curl -o qtest_id.json --header "Content-Type: application/json;charset=UTF-8" -X PUT -T - ${ConnectAllUrl}/connectall/api/2/getLinkedRecordId?apikey=$ConnectAllApiKey
	echo the id lookup resulty is: `cat qtest_id.json`
	QTEST_ID=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.GetQtestLoginToken id <qtest_id.json`

	if [ "$ID" = "" ]
	then
		defect=""
		method="POST"
		echo Create is NOT supported in qTest custom adapter. Going to the next record to process...
	else
		defect="/$ID"
		method="PUT"
		echo update an existing qtest defect $defect using the data: `cat qtest.json`
		cat qtest.json | curl --header "Authorization: Bearer $TOKEN" --header "Content-Type: application/json;charset=UTF-8" -X $method -T - ${qTestUrl}/api/v3/projects/$PROJECT/defects$defect
	fi
	ID=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.JsontoQTest $i qTestCustomAdapterDescriptor.json qTest.json <data.json`
done

echo Log out
curl --header "Authorization: Bearer $TOKEN"  -X POST -c qtest.cookies $qTestUrl/oauth/revoke

fi
