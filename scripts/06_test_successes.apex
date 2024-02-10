/**
 * Example 01:  Call a Salesforce API with a Named Credential
 *              - SF Error responses are handled by the utility
 *              - The base URL is managed by the named credential
 *              - The endpoint base url is set automatically (/services/data/[apiversion])
 *              - Authorization header is managed by the named credential
 */
try{
    // Constructor with Named Credential Name and a Boolean indicator, it is a Salesforce Org
    // The named credential can point to the home org as well.
    utl.Rst callout = new utl.Rst('namedCredentialName', true)
    	.setEndpoint('/sobjects/account/describe')
    	.setMethod('GET')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}


/**
 * Example 02:  Call a Salesforce API on the Home Org
 *              - SF Error responses are handled by the utility
 *              - The base URL is set to the current org's my domain url
 *              - The endpoint base url is set automatically (/services/data/[apiversion])
 *              - Authorization header is set to the session Id taken from the logged in user
 */
try{
    // Constructor with the Boolean indicator it is the Salesforce Home Org
    // Optionally we set the API version to a custom version
    utl.Rst callout = new utl.Rst(true)
    	.setEndpoint('/sobjects/account/describe')
        .setApiVersion('v60.0')
        .setHeader('X-PrettyPrint', '1')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();
    
}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}


/**
 * Example 03:  Call ANY api without anything configured
 *              - No response handling
 *              - Base URL needs to be set manually
 *              - Authorization header needs to be set manually
 */
try{
    // Constructor without any parameters
    utl.Rst callout = new utl.Rst()
        .setBaseUrl('https://prod.pineapple.tools')
        .setEndpoint('/oauth2/token')
        .setBearerToken('token_goes_here')
    	.setMethod('POST')
        .setBody('{"apiKey" : "api_key_goes_here"}')
        .setHeader('debug', '1')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}


/**
 * Example 04:  Call ANY api using a named credential
 *              - No response handling
 *              - Base URL is managed by the named credential
 *              - Authorization header is managed by the named credential
 */
try{
    // Constructor with the Boolean indicator it is the Salesforce Home Org
    utl.Rst callout = new utl.Rst('namedCredentialName')
        .setEndpoint('/api/echo')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}


/**
 * Example 05:  Call ANY api with an OAuth authrization
 *              - No response handling
 *              - Base URL is set through the input variable
 *              - Authorization header is set through the input variable
 */
try{
    // Constructor with the baseURl and bearerToken variables to connect to any enpoinnt that requires a token
    utl.Rst callout = new utl.Rst(URL.getOrgDomainUrl().toExternalForm(),UserInfo.getSessionId())
        .setEndpoint('/services/data/v60.0/sobjects/accounts/describe')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}



/**
 * Example 06:  Call Salesforce API without error handling and without API prefix
 *              - SF Error responses need to be handle manually
 *              - The endpoint needs to be set fully by the user, this allows for calling an OAuth endpoint
 */
try{
    
    utl.Rst callout = new utl.Rst(true)
        .setHandleSfEndpoint(false) // Disable the salesforce base endpoint
        .setHandleSfResponse(false) // Disable any error handling
    	.setEndpoint('/services/data/v60.0/sobjects/account/describe')
    	.setMethod('GET')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(Exception e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}