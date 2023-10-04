/**
 * Example 01:  Force a salesforce Error Object response, by calling the token endpoint
 *              This returns a 400 with an OAuth2 error response object
 */
try{
    utl.Rst callout = new utl.Rst(true)
        .setHandleSfEndpoint(false) // We do not want set the base URL in this case
        .setEndpoint('/services/oauth2/token')
        .call();
}catch(Exception e){
    // unsupported_grant_type :: grant type not supported
    System.debug(e.getMessage());
}



/**
 * Example 02:  Force a salesforce Error Object List response, by calling an invalid sObject
 */
try{
    utl.Rst callout = new utl.Rst(true)
        .setEndpoint('/sobjects/InvalidSObject')
        .call();
}catch(Exception e){
    // NOT_FOUND :: The requested resource does not exist
    System.debug(e.getMessage());
}


/**
 * Example 03:  Force a non-JSON Salesforce response
 *              This returns a 404 with an HTML page as an example
 */
try{
    utl.Rst callout = new utl.Rst(true)
        .setHandleSfEndpoint(false) // We do not want set the base URL in this case
        .setEndpoint('/htmlerrorpage')
        .call();
}catch(Exception e){
    // Unexpected character ('<' (code 60)): expected a valid value
    System.debug((e.getMessage().length() > 100) ? (e.getMessage().substring(0,100) + '[...]') : e.getMessage());
}