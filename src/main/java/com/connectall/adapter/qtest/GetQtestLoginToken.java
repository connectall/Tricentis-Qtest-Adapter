/**
 * Return the lokin token from the /oauth/token api call. The result of the api c all is:
 * {"access_token":"f26f5d8d-66a6-4d30-a5a4-eb2696eb207d","token_type":"bearer","scope":"read import administration create share baseline write delete execute export","agent":null}
 */
package com.connectall.adapter.qtest;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * @author doug
 *
 */
public class GetQtestLoginToken {

	/**
	 * @param args the json to convert
	 */
	public static void main(String[] args) {

		try {
			JSONObject records = new JSONObject(convertStreamToString(System.in));
			System.out.println(records.getString(args[0]));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	static String convertStreamToString(java.io.InputStream is) {
	    java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
	    return s.hasNext() ? s.next() : "";
	}
}
