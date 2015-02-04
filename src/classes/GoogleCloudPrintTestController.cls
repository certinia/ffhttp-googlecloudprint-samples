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
 * GoogleCloudPrintTestController
 * 
 * Controller class for testing all the Google Cloud Print API calls.
 */
public with sharing class GoogleCloudPrintTestController
{
	//statics
	
	//Instance variables
	public ConnectorService connectorService;
	public Boolean validConnector { get; set; }
 
	//Request variables
	public String gcloudprintSubmitRequestPrinterId { get; set; }
	public String gcloudprintSubmitRequestTitle { get; set; }
	public String gcloudprintSubmitRequestContentType { get; set; }

	public transient Blob gcloudprintSubmitRequestFileBody { get; set; }

	public String gcloudprintDeleteJobRequestJobId { get; set; }

	public String gcloudprintJobsRequestPrinterId { get; set; }
	public String gcloudprintJobsRequestOwner { get; set; }
	public String gcloudprintJobsRequestStatus { get; set; }
	public String gcloudprintJobsRequestQ { get; set; }
	public String gcloudprintJobsRequestOffset { get; set; }
	public String gcloudprintJobsRequestLimit { get; set; }
	public String gcloudprintJobsRequestSortOrder { get; set; }

	public String gcloudprintPrinterRequestPrinterId { get; set; }
	public Boolean gcloudprintPrinterRequestUseCdd { get; set; }
	public String gcloudprintPrinterRequestExtraFields { get; set; }

	public String gcloudprintSearchRequestQ { get; set; }
	public String gcloudprintSearchRequestType { get; set; }
	public String gcloudprintSearchRequestConnectionStatus { get; set; }
	public Boolean gcloudprintSearchRequestUseCdd { get; set; }
	public String gcloudprintSearchRequestExtraFields { get; set; }
	
	/**
	 * Constructors
  	 */
	public GoogleCloudPrintTestController()
	{
		this.connectorService = getConnectorService();
        this.init();
    }
    
    private void init()
   	{
        if (connectorService != null)
        {
        	String msg = connectorService.validateConnector();
        	validConnector = String.isEmpty(msg);
        	if (!validConnector)
        	{
        		error(msg);
        	}
        	else
        	{
        		info('Successful authentication. The \'' + connectorService.Connector.Name + '\' connector is being used for authentication.');
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
     * Submitting print job requests
     */
    public void gcloudprintSubmitRequest()
    {
    	ffhttp_GoogleCloudPrint cp = createGoogleCloudPrint();
    	if (cp == null
    	  || stringValueNotSet('Submit', 'Printer Id', gcloudprintSubmitRequestPrinterId)
    	  || stringValueNotSet('Submit', 'Title', gcloudprintSubmitRequestTitle)
    	  || blobValueNotSet('Submit', 'File', gcloudprintSubmitRequestFileBody))
    	{
    		return;
    	}
    	
    	ffhttp_GoogleCloudPrint.SubmitRequest request = cp.submitRequest(gcloudprintSubmitRequestPrinterId, gcloudprintSubmitRequestTitle, 
    					 												 gcloudprintSubmitRequestFileBody, gcloudprintSubmitRequestContentType);
   		execute(request);
    }
  	
  	public void gcloudprintDeleteJobRequest()
  	{
  		ffhttp_GoogleCloudPrint cp = createGoogleCloudPrint();
    	if (cp == null
    	  || stringValueNotSet('Delete Job', 'Job Id', gcloudprintDeleteJobRequestJobId))
    	{
    		return;
    	}
    	
    	ffhttp_GoogleCloudPrint.DeleteJobRequest request = cp.deleteJobRequest(gcloudprintDeleteJobRequestJobId);
    	execute(request);
  	}
  	
  	public void gcloudprintJobsRequest()
  	{
  		ffhttp_GoogleCloudPrint cp = createGoogleCloudPrint();
    	if (cp == null)
    	{
    		return;
    	}
    	
    	ffhttp_GoogleCloudPrint.JobsRequest request = cp.jobsRequest();
    	
    	if (!String.isEmpty(gcloudprintJobsRequestPrinterId))
    	{
    		request.setPrinterId(gcloudprintJobsRequestPrinterId);	
    	}
    	
    	if (!String.isEmpty(gcloudprintJobsRequestOwner))
    	{
    		request.setOwner(gcloudprintJobsRequestOwner);	
    	}
    	
    	if (!String.isEmpty(gcloudprintJobsRequestStatus))
    	{
    		request.setStatus(gcloudprintJobsRequestStatus);	
    	}
    	
    	if (!String.isEmpty(gcloudprintJobsRequestQ))
    	{
    		request.setQ(gcloudprintJobsRequestQ);	
    	}
    	
    	if (!String.isEmpty(gcloudprintJobsRequestOffset))
    	{
    		request.setOffset(gcloudprintJobsRequestOffset);	
    	}
    	
    	if (!String.isEmpty(gcloudprintJobsRequestLimit))
    	{
    		request.setLimit(gcloudprintJobsRequestLimit);	
    	}
    	
    	if (!String.isEmpty(gcloudprintJobsRequestSortOrder))
    	{
    		request.setSortOrder(gcloudprintJobsRequestSortOrder);	
    	}
    	
    	execute(request);
  	}
  	
  	public void gcloudprintPrinterRequest()
  	{
  		ffhttp_GoogleCloudPrint cp = createGoogleCloudPrint();
    	if (cp == null
    	  || stringValueNotSet('Printer', 'Printer Id', gcloudprintPrinterRequestPrinterId))
    	{
    		return;
    	}
    	
    	ffhttp_GoogleCloudPrint.PrinterRequest request = cp.printerRequest(gcloudprintPrinterRequestPrinterId);
    	
    	if (gcloudprintPrinterRequestUseCdd != null)
   		{
   			request.setUseCdd(gcloudprintPrinterRequestUseCdd);
   		}
   		
   		if (!String.isEmpty(gcloudprintPrinterRequestExtraFields))
   		{
   			request.setExtraFields(gcloudprintPrinterRequestExtraFields);
   		}
    	
    	execute(request);
  	}
  	
  	public void gcloudprintSearchRequest()
  	{
  		ffhttp_GoogleCloudPrint cp = createGoogleCloudPrint();
    	if (cp == null)
    	{
    		return;
    	}
    	
    	ffhttp_GoogleCloudPrint.SearchRequest request = cp.searchRequest();
    	
    	if (!String.isEmpty(gcloudprintSearchRequestQ))
    	{
    		request.setQ(gcloudprintSearchRequestQ);	
    	}
    	
    	if (!String.isEmpty(gcloudprintSearchRequestType))
    	{
    		request.setType(gcloudprintSearchRequestType);
   	 	}
   
   		if (!String.isEmpty(gcloudprintSearchRequestConnectionStatus))
   		{
   			request.setConnectionStatus(gcloudprintSearchRequestConnectionStatus);
   		}
   		
   		if (gcloudprintSearchRequestUseCdd != null)
   		{
   			request.setUseCdd(gcloudprintSearchRequestUseCdd);
   		}
   		
   		if (!String.isEmpty(gcloudprintSearchRequestExtraFields))
   		{
   			request.setExtraFields(gcloudprintSearchRequestExtraFields);
   		}
    	
    	execute(request);
  	}
  	
  	private ffhttp_GoogleCloudPrint createGoogleCloudPrint()
  	{
  		if (!checkAuthorized())
    	{
    		return null;
    	}
    	
    	String tokenType = connectorService.connector.TokenType__c;
    	String accessToken = connectorService.connector.AccessToken__c;
    	
        ffhttp_Client.Credentials credentials = new ffhttp_Client.Credentials(tokenType, accessToken);
        return new ffhttp_GoogleCloudPrint(credentials);
  	}
  	
    /**
     * Helper methods
     */
    private void error(String message) 
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }
    
    private void info(String message) 
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
    
    private void execute(ffhttp_Client.AbstractClientRequest request) 
    {
    	try
        {
            HttpRequest httpRequest = request.buildHttpRequest();
            
            String body = httpRequest.getBody();
            Blob b = httpRequest.getBodyAsBlob();
            if (b != null)
            {
            	body = 'Body consists of blob data';
            }
            
            request.buildHttpRequest();
            
            info('Request: Endpoint: ' + httpRequest.getEndpoint() + ' Body: ' + body);
        
            HttpResponse response = request.executeUnparsed();
            info('Response: Status: ' + response.getStatus() + ' Body: ' + response.getBody());
            
            ffhttp_GoogleCloudPrint.CloudPrintResponse cloudPrintResponse = (ffhttp_GoogleCloudPrint.CloudPrintResponse)request.parse(response);
    		if (cloudPrintResponse != null)
    		{
    			String msg = 'Success: ' + cloudPrintResponse.getSuccess();
    			if (cloudPrintResponse.getMessage() != null)
    			{ 
    				msg += ', Message: ' + cloudPrintResponse.getMessage();
    			}
    			
    			if (cloudPrintResponse.getJob() != null)
    			{
    				msg += ', Job: ' + cloudPrintResponse.getJob();
    			}
    			
    			if (cloudPrintResponse.getJobs() != null)
    			{
    				msg += ', Jobs: ' + cloudPrintResponse.getJobs();
    			}
    			
    			if (cloudPrintResponse.getPrinters() != null)
    			{
    				msg += ', Printers: ' + cloudPrintResponse.getPrinters();
    			}
    			
    			info(msg);
    		}
        }
        catch (Exception ex)
        {
            error('Error whilst processing request: ' + ex.getMessage());
        }
    }
    
   	private Boolean checkAuthorized()
	{
		if (connectorService == null)
		{
			return false;
		}
		
		String validConnector = connectorService.validateConnector();
		if (!String.isEmpty(validConnector))
		{
			error(validConnector);
		}
		
		return String.isEmpty(validConnector);
	}
	
	private Boolean blobValueNotSet(String calloutSection, String name, Blob value)
	{
		if (value == null)
		{
			error(calloutSection + ': ' + name + ' must be set.');
			return true;
		}
		return false;
	}
	
	private Boolean stringValueNotSet(String calloutSection, String name, String value)
	{
		if (String.isEmpty(value))
		{
			error(calloutSection + ': ' + name + ' must be set.');
			return true;
		}
		return false;
	}
	
	private Boolean numberValueNotSet(String calloutSection, String name, Integer value)
	{
		if (value == null || value <= 0)
		{
			error(calloutSection + ': ' + name + ' must be set.');
			return true;
		}
		return false;
	}
	
	 /**
     * List methods
     */
    public List<SelectOption> getPrinterTypes() 
    {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_GOOGLE, 'Google'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_HP, 'HP'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_DOCS, 'Docs'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_DRIVE, 'Drive'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_FEDEX, 'Fedex'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_ANDROID_CHROME_SNAPSHOT, 'Android Chrome Snapshot'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.PRINTER_TYPE_IOS_CHROME_SNAPSHOT, 'iOS Chrome Snapshot'));
        return options;
   	}
    
    public List<SelectOption> getConnectionStatuses() 
    {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.CONNECTION_STATUS_ONLINE, 'Online'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.CONNECTION_STATUS_UNKNOWN, 'Unknown'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.CONNECTION_STATUS_OFFLINE, 'Offline'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.CONNECTION_STATUS_DORMANT, 'Dormant'));
        return options;
   	}
	
	public List<SelectOption> getJobStatuses() 
    {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_STATUS_QUEUED, 'Queued'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_STATUS_IN_PROGRESS, 'In Progress'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_STATUS_DONE, 'Done'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_STATUS_ERROR, 'Error'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_STATUS_SUBMITTED, 'Submitted'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_STATUS_HELD, 'Held'));
        return options;
   	}
   	
   	public List<SelectOption> getJobSortOrders()
	{
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_SORT_ORDER_CREATE_TIME, 'Create Time'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_SORT_ORDER_CREATE_TIME_DESC, 'Create Time Desc'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_SORT_ORDER_STATUS, 'Status'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_SORT_ORDER_STATUS_DESC, 'Status Desc'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_SORT_ORDER_TITLE, 'Title'));
        options.add(new SelectOption(ffhttp_GoogleCloudPrint.JOB_SORT_ORDER_TITLE_DESC, 'Title Desc'));
        return options;
    }
}
