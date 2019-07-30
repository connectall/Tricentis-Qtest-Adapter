# Tricentis-Qtest-Adapter
This repository contains the source and binaries for a basic adapter that allows synchronization with the Tricentis qTest product, and any other applications that ConnectAll integrates with.

To get started, download this repository into a local folder on your linux system. Then follow the following steps:
* Request a license from sales@connectall.com
* Set the qtest_setup.sh file setting the url's, etc. for your integration
* Create a login.json file that has your login to the qtest server, eg, username=[username&password=[password]&grant_type=password
* Edit the qTestCustomAdapterDescriptor.json, setting the fields:
  * type, ie, the name of the application you provided to sales above, eg, "ABC Company".
  * project name and id. This will be displayed in the ConnectALL entity mapping screen.
  * fields - add the fields for your project. The easy way to do this is run the get_schema.sh script and insert this output into the qTestCustomAdapterDescriptor.json file inside the fields tag. You can use the download json as an example but of course your field id's may be different. Also, edit the json changeing "label" to "name", and "data_type" to "datatype".
* Import the json into your ConnectAll system using the Configuration/Install Custom Adapter" menu option. Then import your license file.

Now you're all ready to create an application link, just like you did for your other application. This example assumes that qTest is mapped on the right side. Also remember to set the "sync type" to "push", not "poll".

To sync the data from qTest to your other endpoint, run the update_other.sh script, providing the application link name and qtest project id as arguments, eg, ./update_other.sh Jama2qTest 86769.

To sync data from the other endpoint to qTest, run the update_qtest.sh script, providing the application link name and qtest project id as arguments, eg, ./update_qtest.sh Jama2qTest 86769.

If you would like the sync to occur automatically you can schedule the scripts as cron jobs.
