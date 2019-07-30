/**
 * Convert the data records returned from ConnectALL to the formatted json that the qTest rest api requires.
 */
package com.connectall.adapter.qtest;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * @author doug
 *
 */
public class JsontoQTest {

	/**
	 * @param args the json to convert
	 */
	public static void main(String[] args) {

		JSONArray records =  null;
		JSONArray properties = new JSONArray();
		JSONObject result = new JSONObject();
		String input =  convertStreamToString(System.in);// records.getJSONObject(i);
		try {
			//Map fieldMap = getFieldMap(args[1]);
			//System.out.println("[");
			//JSONArray records = new JSONArray(convertStreamToString(System.in));
			//for (int i = 0; i < 1; i++) {
			//	if (i != 0)
			//		System.out.println(",");
			JSONObject inputMessage = new JSONObject(input);
			int numRecords = inputMessage.getInt("totalrecords");
			if (numRecords <= 0)
				System.exit(-1);
			records =  inputMessage.getJSONArray("data");// records.getJSONObject(i);
			int recordNum = Integer.parseInt(args[0]);
			if (recordNum >= records.length()) 
				System.exit(-2);
			else {
				JSONObject record = records.getJSONObject(recordNum);
				String id = record.getString("id");
				JSONObject fields = record.getJSONObject("fields");
				for (Iterator<String> i=fields.keys(); i.hasNext(); ) {
					Map field = new HashMap();
					String fieldName = i.next();
					if (!fieldName.equalsIgnoreCase("id") && !fieldName.equalsIgnoreCase("issuetype") && !fieldName.endsWith("_CONSTANT")) {
						//String fieldId = (String) fieldMap.get(fieldName);
						//System.err.println("The field id for field " + fieldName + " is " + id);
						field.put("field_id", Integer.parseInt(fieldName));
						field.put("field_value", fields.getString(fieldName));
						properties.put(field);

					}
				}
				result.put("properties", properties);
				PrintWriter out = new PrintWriter(args[2]);
				out.println(result.toString());
				out.close();
				System.out.println(id);
			}
		} catch (Exception e) {
			System.err.println("\n\nUnable to parse the json" + input);
			e.printStackTrace();
			System.exit(-1); // parse error
		}
		System.exit(0);
	}

	static String encode(String s) {
		return s;//encode.URLEncoder.encode(s);//.replace("\"", "&quot;");
	}


	static String convertStreamToString(java.io.InputStream is) {
		java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
		return s.hasNext() ? s.next() : "";
	}

	static Map getFieldMap(String descriptorFileName) throws Exception {
		Map result = new HashMap();
		String content = new String ( Files.readAllBytes( Paths.get(descriptorFileName) ) );

		JSONObject descriptor = new JSONObject(content);
		JSONArray fields = descriptor.getJSONArray("fields");
		for (int i=0; i<fields.length(); i++) {
			JSONObject field = fields.getJSONObject(i);
			result.put(field.getString("name"), field.getString("id"));
		}
		System.err.println("Field map is: " + result);
		return result;
	}
}
