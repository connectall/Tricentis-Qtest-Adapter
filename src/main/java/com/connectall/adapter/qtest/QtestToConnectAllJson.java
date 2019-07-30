/**
 * Convert the data records returned from qTest to the formatted json that the ConnectALL rest api requires.
 */
package com.connectall.adapter.qtest;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * @author doug
 *
 */
public class QtestToConnectAllJson {

	/**
	 * @param args the json to convert
	 */
	public static void main(String[] args) {

		String appName = args[0];
		String origin = args[1];
		JSONArray records =  null;
		JSONObject result = new JSONObject();
		String input =  convertStreamToString(System.in);// records.getJSONObject(i);
		try {
			//System.out.println("[");
			//JSONArray records = new JSONArray(convertStreamToString(System.in));
			//for (int i = 0; i < 1; i++) {
			//	if (i != 0)
			//		System.out.println(",");
			records =  new JSONArray(input);
			int recordNum = Integer.parseInt(args[2]);
			if (recordNum >= records.length()) 
				System.exit(-2);
			else {
				JSONObject record = records.getJSONObject(recordNum);
				//System.out.println(String.format("{\"fields\":{\n"));
				//fields.put("id",  record.getString("id"));
				result.put("appLinkName",  appName);
				result.put("origin", origin);
				//System.out.println(String.format("\"id\":\"%s\",\"reporter\":\"%s\",\"createdOn\":\"%s\",\"modifiedBy\":\"%s\",\"modifiedOn\":\"%s\",\"_URL\":\"%s\"",key,createdBy,createdOn,modifiedBy,modifiedOn,_URL));
				JSONArray properties = record.getJSONArray("properties");
				JSONObject fields = new JSONObject();
				fields.put("id",  record.getString("id"));
				fields.put("createdOn",  record.getString("submitted_date"));
				fields.put("modifiedOn", record.getString("last_modified_date")); // 2019-05-09T09:53:42-04:00
				fields.put("createdBy",  record.getString("submitter_id")); // 105875
				fields.put("modifiedBy", record.getString("last_modified_user_id")); // 107085
				fields.put("_URL",  record.getString("web_url")); // https://connectall.qtestnet.com/p/86769/portal/project#tab=defects&object=17&id=2181383
				for (int j=0; j < properties.length(); j++) {
					JSONObject field = properties.getJSONObject(j);
					String fieldId = field.getString("field_id");
					String fieldName = field.getString("field_name");
					String fieldValue = field.getString("field_value");
					if (field.has("field_value_name")) {
						fieldValue = field.getString("field_value_name");
					}
					fields.put(fieldName, fieldValue);
				}
				result.put("fields", fields);
				result.put("appLinkName",  appName);
				result.put("origin",  origin);

				//}
				//System.out.println("}");
			}
		} catch (Exception e) {
			System.err.println("\n\nUnable to parse the json" + input);
			e.printStackTrace();
			System.exit(-1); // parse error
		}
		System.out.println(result.toString());
		System.exit(0);
	}

	static String encode(String s) {
		return s;//encode.URLEncoder.encode(s);//.replace("\"", "&quot;");
	}


	static String convertStreamToString(java.io.InputStream is) {
		java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
		return s.hasNext() ? s.next() : "";
	}
}
