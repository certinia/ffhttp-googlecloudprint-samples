/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * GoogleCloudPrintAccountController
 *
 * Simple app controller to demonstrate printing an Account attachment using Google Cloud Print.
 */
public with sharing class GoogleCloudPrintAccountController 
{
	//statics
	public static final String GOOGLE_CLOUD_PRINT_DOCS_PRINTER = '__google__docs';
	
	//instance variables
 	private final Account acct;
    
    public Attachment[] attachments;
    public ConnectorService connectorService;
    public ffhttp_GoogleCloudPrint client;
    public Boolean validConnector { get; set; }
   
    /**
     * Constructor
     */
    public GoogleCloudPrintAccountController(ApexPages.StandardController stdController) 
    {
        this.acct = (Account)stdController.getRecord();
        this.connectorService = getConnectorService();
        
        if (connectorService != null)
        {
        	String msg = connectorService.validateConnector();
        	validConnector = String.isEmpty(msg);
        	if (!validConnector)
        	{
        		error(msg);
        	}
        }
        else
        {
        	error('Google Cloud Print connector not found.');
        }
    }
    
    /**
     * Gets a valid connector for Google requests.
     *
     * Note: for separation of concerns consider using a selector pattern.
	 * See https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
     */
    public ConnectorService getConnectorService()
    {
    	if (connectorService == null)
    	{	
    		try
    		{
	    		Connector__c c = 
	    		[
	    			SELECT 
	    				c.TokenType__c, c.RefreshToken__c, c.RefreshTokenRequested__c, c.Name, c.Id, c.AccessToken__c, 
					   	c.AccessTokenRequested__c, c.AccessTokenExpiry__c, c.Active__c, 
					   	ConnectorType__r.TokenEndpoint__c, ConnectorType__r.Scope__c, ConnectorType__r.ScopeRequired__c, 
					   	ConnectorType__r.RedirectUri__c, ConnectorType__r.Name, ConnectorType__r.Id, 
					   	ConnectorType__r.ExtraUrlParameters__c, ConnectorType__r.DeveloperName__c, 
					   	ConnectorType__r.ClientSecret__c, ConnectorType__r.ClientId__c, ConnectorType__r.CallbackURL__c, 
					   	ConnectorType__r.AuthorizationEndpoint__c
	    			FROM Connector__c c
	    			WHERE ConnectorType__r.Name =: GoogleCloudPrintConfigure.CLOUD_PRINT_TYPE_LABEL
	    			AND c.OwnerId =: UserInfo.getUserID()
	    			LIMIT 1
	    		];
	    		
	    		if (c != null)
	    		{
	    			connectorService = new ConnectorService(c);
	    		}
    		}
    		catch (Exception ex)
    		{
    		}
    	}
    	return connectorService;
    }
    
    /**
     * Gets the Google Cloud Print client
     */
    public ffhttp_GoogleCloudPrint getGoogleCloudPrintClient()
    {
    	if (client == null)
    	{
    		ffhttp_Client.Credentials credentials = new ffhttp_Client.Credentials(connectorService.connector.TokenType__c, connectorService.connector.AccessToken__c);
    		client = new ffhttp_GoogleCloudPrint(credentials);
    	}
    	return client;
    }
    
    /**
     * Gets all the attachments related to this Account.
     */
    public Attachment[] getAttachments()
    {
    	if (attachments == null)
    	{
    		attachments = 
    		[
    			SELECT a.Name, a.Body, a.ContentType
    			FROM Attachment a 
    			WHERE a.ParentId =: acct.Id
    		];
    	}
    	return attachments;
    }
 
 	/**
 	 * Print the selected attachment with Google Cloud Print
 	 */
 	public void printAttachment()
 	{
 		getGoogleCloudPrintClient();
 		
 		String msg = '';
		ApexPages.severity messageCode = ApexPages.severity.ERROR;
		
 		try
    	{
    		String accountId = String.valueOf(acct.Id);
    		
    		//Get the selected attachment.
	    	Integer selectedRow = getSelectedRowAttachment();
	    	
	    	Attachment selectedAttachment = attachments[selectedRow]; 	
	    	String attachmentName = selectedAttachment.Name;
	    	Blob attachmentContent = selectedAttachment.Body;
	    	String attachmentContentType = selectedAttachment.ContentType;
	    	
	    	//Print the attachment
	    	ffhttp_GoogleCloudPrint.SubmitRequest request = client.submitRequest(GOOGLE_CLOUD_PRINT_DOCS_PRINTER, attachmentName, attachmentContent, 
	    																	 	 attachmentContentType);
   			ffhttp_GoogleCloudPrint.CloudPrintResponse cloudPrintResponse = (ffhttp_GoogleCloudPrint.CloudPrintResponse)request.execute();
   			if (cloudPrintResponse != null
   			  && cloudPrintResponse.getMessage() != null)
			{ 
				msg += cloudPrintResponse.getMessage() + ' (' + attachmentName + ')';
				messageCode = ApexPages.severity.INFO;
			}
    	}
    	catch (ffhttp_AppException ex)
    	{
    		msg = 'API Exception calling Google Cloud Print. The attachment was not printed.';
    	}
    	
    	ApexPages.addMessage(new ApexPages.message(messageCode, msg));
 	}
 	
	/**
	 * Methods to work out which attachment has been selected on the VisualForce page.
	 */
    private Integer getSelectedRowAttachment()
    {
    	PageReference reference = ApexPages.currentPage();
		Map<String, String> referenceParameter = reference.getParameters();
		Object rowIndexObj = referenceParameter.get('attachmentRowNumber');
		return Integer.valueOf(rowIndexObj);
	}
 	
 	void info(String msg)
 	{
 		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, msg));
 	}
 	
 	void error(String msg)
 	{
 		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
 	}
}
