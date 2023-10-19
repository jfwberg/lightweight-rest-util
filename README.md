# Lightweight - REST Util
A lightweight Apex utility for executing (Salesforce) REST based APIs

## Description
This is very lightweight REST API utility designed to work with Salesforce and Data Cloud REST APIs, yet is flexible enough be used for any type of REST based API call.
It is focussed around OAuth 2.0 authenticated APIs with a Bearer token as authentication and should ideally be used in combination with a logging / retry library.

This utility handles the standard Salesforce API status codes 200, 201, 400, 401, 404, 405, 415 and 500 HTTP Response status codes and supports the Data Cloud specifc API status codes 202, 409, 422, 429 as well.

It will handle the error response codes by throwing an ```utl.RestUtilException``` with the error message(s) from the reponse that the consuming code can handle accordingly.

It's designed to work with method chaining so that full callouts can be performed in a single line without the need for verbose class construction on larger configurations.

## Dependency - Package Info
The following package need to be installed first before installing this package.
If you use the *managed package* you need to installed the managed package dependency and if you use the *unlocked version* you need to use the unlocked dependency.
| Info | Value |
|---|---|
|Name|Lightweight - Apex Unit Test Util v2|
|Version|2.2.0-2|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007Ez7IAE*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007F3xIAE*

## REST Util - Package info
| Info | Value |
|---|---|
|Name|Lightweight - Apex REST Util|
|Version|0.9.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007FOvIAM*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007FVNIA2*

## Default values
- Timeout     : 120,000ms
- HTTP Method : GET
- Endpoint    : ''
- API Version : 'v59.0' (Salesforce Constructor Only)
- Content-Type: 'application/json;charset=UTF-8'

## Note on Unit tests
You cannot execute the ```Test.setMock()``` class for http callouts in namespaced packages.
To test your callouts made though this utility you need to leverage the ```utl.Mck``` [class and methods](https://github.com/jfwberg/lightweight-apex-unit-test-util-v2).

Example implementation in your *TEST method*:
```java
// Setup the mock response
utl.Mck.setResponse(200, '{"SUCCESS": true}');
```

# Constructors
The basic setup is by constructing a ```util.Rst()``` object and chain methods to set it up, execute it and get the response.
There are several options for calling Salesforce APIs specifically.

### Connect to Home Org
```java
// Base URL    : The current org (Home org) and the 
// BearerToken : The current logged in user's SessionId.(Through a VF page from Aura Context)
// SF Response handling: Enabled
global Rst(Boolean isSalesforce)

// Example
utl.Rst callout = new utl.Rst(true);
```

### Connect to any Org through a Named Credential
```java
// Base URL     : From Named Credential
// Bearer Token : From External Credential
// SF Response handling: Enabled
global Rst(String namedCredential, Boolean isSalesforce)

// Example
utl.Rst callout = new utl.Rst('Home_Org', true);
```

### Call to any OAuth enabled API Using a named credential
```java
// Base URL     : From Named Credential
// Bearer Token : From External Credential
// SF Response handling: Disabled
global Rst(String namedCredential)

// Example
utl.Rst rst = new utl.Rst('namedCredentialName');
```

### Call any API (or Org) using a base URL with OAuth Bearer Token
```java
// Base URL     : From baseUrl variable
// Bearer Token : From bearerToken variable
// SF Response handling: Disabled
global Rst(String baseUrl, String bearerToken)

// Example
utl.Rst rst = new utl.Rst('https://mydomain.my.salesforce.com','[SESSION_ID_VALUE]');
```

### Call any API
```java
// Base URL     : Not set
// Bearer Token : Not set
// SF Response handling: Disabled
global Rst()

// Example
utl.Rst rst = new utl.Rst()
    .setBaseUrl('https://prod.pineapple.tools')
    .setEndpoint('/oauth2/token')
    .setMethod('POST')
    .call();
```


# Methods
## Setter methods
These are all the methods to setup the REST request
```java
// Set the base URL  (i.e. https://mydomain.my.salesforce.com)
setBaseUrl(String baseUrl)

// Sets the value for the 'Authorization' Header to the value of 'Bearer bearerToken'
setBearerToken(String bearerToken)

// When true the endpoint value will prefixed with /services/data/[API_VERSION]
setHandleSfEndpoint(Boolean handleSfEndpoint)

// If this is set to true, the code will handle the API Response
// like a response that comes from a Salesforce API and will throw
// an exception on any known error responses
setHandleSfResponse(Boolean handleSfResponse)

// Set the HTTP Method, (defaults to GET)
setMethod(String method)

// Set a custom api version for a Salesforce API like 'v59.0'
setApiVersion(String apiVersion)

// Set the endpoint (i.e. /services/data/v59.0/sobjects/account/describe)
setEndpoint(String endpoint)

// Ability to set a custom timeout value (defaults to 120,000)
setTimeout(Integer timeout)

// Set the value of a PUT, POST or PATCH request type
setBody(String body)

// If you want to remove a header set the value to null
// Customer headers will override default headers
setHeader(String key, String value)

// Method to set a mockResponseIdentifier so you can specify what utl.Mck instance is returned
// This is option for Apex testing and required when you work with multiple calls in the same logic
// Match mockResponseIdentifier in the utl.Mck.addResponse(mockResponseIdentifier,200,payload)
setMockResponseIdentifier(String mockResponseIdentifier)

// Sets the X-PrettyPrint header to value to '1' or '0'
// Should be turned off in production, but can be used for 
setPrettyPrintHeader(Boolean prettyPrint)

// Method to set an X-Request-ID header, set to NULL to auto generate a GUID
setRequestIdHeader(String requestId)

// Method to set an X-Correlation-ID header, set to NULL to auto generate a GUID
setCorrelationIdHeader(String correlationId)

// Sets the content type to 'text/xml; charset=UTF-8;' for the use with the SOAP API
setContentTypeHeaderToXml()

// Sets the content type to 'application/x-www-form-urlencoded'
// Sets the method to 'POST'
// Sets the body to a URL Encoded query String based on the parameter value map input
setContentTypeHeaderToFormUrlEncoded(Map<String,String> parameterValueMap)
```


## Support methods
These methods are run after you have set up your request using the setter methods. It will generate the request and/or execute the REST callout.
```java
// Set up the request, but do not call the endpoint
// Not required when you use the call() method, this is mainly used for debugging
// or if you want to handle the request using a different library
setupRequest()

// Executes the HTTP Request. This method automatically runs setupRequest() so no need to
// call that method separately
call()
```


## Getter methods
These methods are used AFTER you have executed your REST callout or you have setup your request.
```java
// Returns the HttpRequest object, this can be used for debugging or custom execution / logging
HttpRequest getRequest()

// Returns the HttpResponse object, this can be used for handling the response in whatever way required
HttpResponse getResponse()

String getRequestId()

String getCorrelationId()

// The number of milli-seconds the callout took, for debugging / performance purposes
Integer getExecutionTime()

// Method to get a VF API enabled session Id for local session.
// Calls a VF page and extracts the session Id, this is quite a hack but allowed in AppExchange reviews
// It is required for lightning components to communicate with the Salesforce API directy
// Ideally you would always use a Named credential for each connection, even to the local (home) org
String getApiEnabledSessionId()
```


## Utility methods
These methods are static methods that have nothing to do with the Rst Object instance it self.
These are truly utility methods that can be used for custom REST related set ups.
```java


// Method for encoding a Blob into a Base64 URL encoded String
// Mainly used for generating a JWS
String utl.Rst.base64UrlEncode(Blob input)

// Method to validate named credential(s) exists in the metadata.
// Throws an utl.Rst.NamedCredentialException in case a NC does not exist
void utl.Rst.validateNamedCredentials(Set<String> developerNames)

// Method to generate a GUID that is compliant with the standards
String utl.Rst.guid() 

// Method to convert a key/value map into a URL encoded parameter query string that
// can be used with url-encoded forms or get queries
String utl.Rst.urlParameterQueryString(Map<String,String> parameterValueMap)
```


# Examples
## Success Examples
```java
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

}catch(utl.Rst.RestUtilException e){
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
        .setApiVersion('v59.0')
        .setHeader('X-PrettyPrint', '1')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();
    
}catch(utl.Rst.RestUtilException e){
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

}catch(utl.Rst.RestUtilException e){
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

}catch(utl.Rst.RestUtilException e){
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
        .setEndpoint('/services/data/v59.0/sobjects/accounts/describe')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(utl.Rst.RestUtilException e){
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
    	.setEndpoint('/services/data/v59.0/sobjects/account/describe')
    	.setMethod('GET')
    	.call();
    
    String  responseBody  = callout.getResponse().getBody();
    Integer executionTime = callout.getExecutionTime();

}catch(utl.Rst.RestUtilException e){
    System.debug('\n\n' + e.getMessage() + '\n\n');
}
```

## Error Examples
```java
/**
 * Example 01:  Force a salesforce Error Object response, by calling the token endpoint
 *              This returns a 400 with an OAuth2 error response object
 */
try{
    utl.Rst callout = new utl.Rst(true)
        .setHandleSfEndpoint(false) // We do not want set the base URL in this case
        .setEndpoint('/services/oauth2/token')
        .call();
}catch(utl.Rst.RestUtilException e){
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
}catch(utl.Rst.RestUtilException e){
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
}catch(utl.Rst.RestUtilException e){
    // Unexpected character ('<' (code 60)): expected a valid value
    System.debug((e.getMessage().length() > 100) ? (e.getMessage().substring(0,100) + '[...]') : e.getMessage());
}
```

## Data Cloud Examples
```java
    /**
     * Example 01:  Call the data cloud ingestion api through a named credential
     *              with Salesforce error handling enabled, endpoint comes from Named credential
     */
    // Execute the call out for a specific named credential
    utl.Rst callout = new utl.Rst('[NAMED_CREDENTIAL_NAME]')
    .setHandleSfResponse(true) // Handle the response automatically
    .setEndpoint('/api/v1/ingest/sources/ingestionConnectorName/objectName')
    .setMethod('POST')
    .setBody('{... payload ...}')
    .call();


    /**
     * Example 02:  Call the data cloud query api through a named credential
     *              with Salesforce error handling enabled, endpoint comes from Named credential     
     */
    // Execute the call out for a specific named credential
    utl.Rst callout = new utl.Rst('[NAMED_CREDENTIAL_NAME]')
    .setHandleSfResponse(true) // Handle the response automatically
    .setEndpoint('/api/v2/query')
    .setMethod('POST')
    .setBody('{"sql" : "select 1"}')
    .call();

```