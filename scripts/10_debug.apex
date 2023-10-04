try{
    HttpRequest request = new HttpRequest();
	request.setEndPoint('callout:HomeOrg/services/a360/token');
	//request.setEndPoint('callout:Debug/api/echo');
	request.setMethod('POST');
	request.setHeader('Content-Type','application/x-www-form-urlencoded');
	
	
	String body = urlParameterQueryString(new Map<String,String>{
		'grant_type'		 => 'urn:salesforce:grant-type:external:cdp',
		'subject_token' 	 => '__TOKEN__',
		'subject_token_type' => 'urn:ietf:params:oauth:token-type:access_token'
	});
	body = body.replace('__TOKEN__','{!$Credential.OAuthToken}'); 
	
		
		
	request.setBody(body);
 
	System.debug(new HTTP().send(request).getBody());
	
	
	/*
	// Constructor with Named Credential Name and a Boolean indicator, it is a Salesforce Org
    // The named credential can point to the home org as well.
    utl.Rst callout = new utl.Rst('HomeOrg', true)
		.setHandleSfEndpoint(false)
    	.setEndpoint('/services/a360/token')
		.setHeader('Content-Type','x-www-form-urlencoded')
    	.setMethod('POST')
		.setBody(EncodingUtil.urlEncode('grant_type=urn:salesforce:grant-type:external:cdp&subject_token={!$Credential.OAuthToken}&subject_token_type=urn:ietf:params:oauth:token-type:access_token','UTF-8'))
		.call();
    
	String  responseBody  = callout.getResponse().getBody();
    System.debug(responseBody);
*/
}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}


	/**
     * @description Method to convert a key/value map into a URL encoded parameter query string that
     *              can be used with url-encoded forms or get queries
     * @param       parameterValueMap A key/value map that contains the parameter name and the
     *                                parameter value
     * @return      a url encoded parameter string formatted like "?key1=value1&key2=value2"
     */
    private String urlParameterQueryString(Map<String,String> parameterValueMap){
        
        // Return an emtpy string if the input is null
        if(parameterValueMap == null || parameterValueMap.isEmpty()){
            return '';
        }

        // Start the query string
        String queryString ='';

        // Parameter string format
        final String parameterTemplate = '{0}{1}={2}';

        // Add parameter if the parameter has a value
        for(String parameter : parameterValueMap.keySet()){
            if(String.isNotBlank(parameterValueMap.get(parameter))){
                queryString += String.format(parameterTemplate, new String[]{
                    ((String.isBlank(queryString)) ? '' : '&'),
                    parameter,
                    EncodingUtil.urlEncode(parameterValueMap.get(parameter), 'UTF-8')
                });
            }
        }
        // Return the query string
        return queryString;
    }