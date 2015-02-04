Google Cloud Print Sample Apps
==============================

<a href="https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=ffhttp-googlecloudprint-samples">
    <img alt="Deploy to Salesforce"
        src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Summary
-------
This app (or collection of apps) has been built to demonstrate the use of the [Google Cloud Print](https://github.com/financialforcedev/ffhttp-googlecloudprint) and [Core](https://github.com/financialforcedev/ffhttp-core) libraries. 

It consists of two components:
1. A test harness that provides a UI for performing all of the Google Cloud Print API calls.
2. An implementation of the library that allows Account attachments to be printed to the Google Drive printer via Google Cloud Print.

**Note:** Currently, no test coverage for the sample apps has been provided.

Key Features
------------
+ Demonstrates each of the API calls found at https://developers.google.com/cloud-print/docs/appInterfaces.
+ Demonstrates the use of the [\submit](https://developers.google.com/cloud-print/docs/appInterfaces#submit) API call to print an attachment to the Google Drive printer on Cloud Print.

Configuration
-------------

This section explains how to configure the Google Cloud Print Sample Apps.

1. Deploy the [Core](https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=ffhttp-core) package to your Salesforce organisation.
2. Deploy the [OAuth Sample App](https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=ffhttp-core-samples).
3. Deploy the [Google Cloud Print](https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=ffhttp-googlecloudprint) package. 
4. Deploy the [Google Cloud Print Sample App](https://githubsfdeploy.herokuapp.com?owner=financialforcedev&repo=ffhttp-googlecloudprint-samples).
5. Go to **Setup** > **Manage Users** > **Users**.
6. Select your user.
7. Select **Edit Assignments** in the **Permission Set Assignments** section.
8. Add the **OAuth Sample App Permissions** and **Google Cloud Print Sample App Permissions** permission sets and **Save**.
9. Select the **Google Cloud Print Sample App** from the app menu. 
    + The **Test Harness**, **Opportunities**, **Connector Types** and **Connectors** tabs should be displayed.
10. Create a Google App following the steps in the **Create an app in Google** section below.
11. Follow the **Create a Google Cloud Print Connector in Salesforce** steps below.
12. Go to **Setup** > **Customize** > **Accounts** > **Page Layouts**.
13. Select **Edit** on the **Account Layout**.
14. Select the **Buttons** section.
15. Add the **Print Attachments** button to the **Custom Buttons** section.
16. Save the layout.
17. Select an account from the **Accounts** tab.
    + The **Print attachments** button should be displayed.

###Create an app in Google

1. Log in to your Google account.
2. Go to https://console.developers.google.com/project and select **Create Project**.
3. Enter a project name and ok the dialog.
4. Select the hyperlink for the project name that you just created.
5. Select **Credentials**.
6. Select **Create new Client ID**.
7. Select **Web application**.
8. Set the **Authorized Javascript Origins** url to the URL of the Salesforce organisation e.g. https://eu3.salesforce.com.
9. Set the **Authorized Redirect URIs** to the same as above with *apex/connector* appended: e.g. https://eu3.salesforce.com/apex/connector.
10. Make sure you know the **Client Id** and **Client Secret** as they will be needed later.
11. Select the **Consent screen**.
12. Enter a **Product Name** and save.

###Create a Google Cloud Print Connector in Salesforce
1. Log in to your Salesforce organisation.
2. Go to the **Developer Console** and select **Debug** > **Open Execute Anonymous Window**.
3. Run the following code changing the parameters to the appropriate values:

    ```
    GoogleCloudPrintConfigure.configure(<Google App Client Id>, <Google App Client Secret>, <Salesforce domain>);
    ```

4. Check that the connector has been created and activate it.

Use
---

Once the project is configured:

###Test Harness
1. Select the **Test Harness** tab.
2. Check that you get a message starting with 'Successful authentication'. If you do not, check that all the configuration steps have been peformed correctly.
3. Expand any section to display the API calls, then select **Submit** to test the call.

###Account Print Attachment Sample App
1. Select the **Account** tab and select an account.
2. Create a new attachment. Attach a file.
3. Select **Print Attachments**.
4. Select the **Print** button next to the attachment.
5. The attachment should be printed to Google Drive via Google Cloud Print.

Reporting Issues & Enhancements
-------------------------------

Please report any issues using the github [issues](https://github.com/financialforcedev/ffhttp-googlecloudprint-samples/issues) feature. Suggestions / bug reports are welcome as are extensions containing additional functionality.
