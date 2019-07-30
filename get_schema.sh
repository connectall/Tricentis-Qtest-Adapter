. qtest_setup.sh

# Login
curl --header "Content-Type: application/x-www-form-urlencoded" -u "${qTestUserid}:" -X POST -d @login.json -c qtest.cookies $qTestUrl/oauth/token >token.json
TOKEN=`java -cp target/qtest-0.0.1.jar:bin/json-20090211.jar com.connectall.adapter.qtest.GetQtestLoginToken <token.json`

# Read the field schema
curl --header "Authorization: Bearer $TOKEN" $qTestUrl/api/v3/projects/$PROJECT/settings/defects/fields | jq . | tee fields.json

#Logout
curl --header "Authorization: Bearer $TOKEN"  -X POST -c qtest.cookies $qTestUrl/oauth/revoke
