# Lightweight - REST Util
A lightweight Apex utility for executing (Salesforce) REST based APIs

## Description
This is very lightweight REST utility designed to work with Salesforce REST APIs yet flexible enough be used for any REST based API call.
It is focussed around OAuth authenticated APIs with a Bearer token for authentication and could be used in combination with other (logging) libraries as well.

This utility handles the standard Salesforce API error codes 200, 201, 400, 401, 404, 405, 415 and 500 HTTP Response status codes.
It will handle the JSON error responses and throw an ```utl.RestUtilException``` with the error message(s) from the reponse that the consuming code can handle accordingly.

It's designed to work with method chaining so that full callouts can be performed in a single line without the need for verbose class construction on larger configurations.

# Methods
## Default values
- Timeout     : 120,000ms
- HTTP Method : GET
- Endpoint    : '/'
- API Version : 'v58.0' (Salesforce Only)

## Base class construction
The basic setup is by constructing a ```util.Rst()``` object and chain methods to set it up, execute it and get the response

See the below [Constructor](#Constructors) section for more details

```java
// Example to call a token endpoint
utl.Rst rst = new utl.Rst()
    .setBaseUrl('https://api.buymoria.com')
    .setEndpoint('/oauth2/token')
    .setMethod('POST')
    .call();

System.debug(rst.getResponse().getBody());

// Example to call the Salesforce API on the Home Org with a custom API version (not required)
// a specific set*Sf*endpoint() method to generate a Salesforce enpoint
// All methods are chained together in a single line to get the response
String responseBody = new utl.Rst(true)
    .setApiVersion('v59.0')
    .setSfEndpoint('/sobjects/account/describe')
    .call()
    .getResponse()
    .getBody();

System.debug(responseBody);
```

## Setter methods
These are all the methods to setup the REST request
```java
// Ability to set a custom timeout value (defaults to 120,000)
setTimeout(Integer timeout)

// Set the HTTP Method, (defaults to GET)
setMethod(String method)

// Set the base URL  (i.e. https://mydomain.my.salesforce.com)
setBaseUrl(String baseUrl)

// Set the endpoint (i.e. /services/data/v58.0/sobjects/account/describe)
setEndpoint(String endpoint)

// Sets the value for the 'Authorization' Header to the value of 'Bearer bearerToken'
setBearerToken(String bearerToken)

// Set an additinal header (i.e. setHeader('X-PrettyPrint','1') )
// If you want to remove a header set the value to null
// Customer headers will override default headers
setHeader(String key,String value)

// Set the value of a PUT, POST or PATCH request
setBody(String body)

// Set a custom api version for a Salesforce API like 'v58.0'
setApiVersion(String apiVersion)

// This sets the base URL + /services/data/[API_VERSION]
setSfEndpoint(String endpoint)

// If this is set to true, the code will handle the API Response
// like a response that comes from a Salesforce API and will throw
// an exception on any known error responses
setHandleSfResponse(Boolean handleSfResponse)
```

## Support methods
These methods are run after you have set up your request using the setter methods. It will generate the request and/or execute the REST callout.
```java
// Set up the request, but do not call the endpoint
// Not required when you use the call() method, this is mainly used for debugging
// or if you want to handle the request using a different library
setupRequest()

// Executes the request. This method automatically runs setupRequest() so need need to
// call that method separately
call()
```

## Getter methods
These methods are used after you have executed your REST callout or you have setup your request.
```java
// Return the HttpRequest object, this can be used for debugging or custom execution / logging
HttpRequest getRequest()

// Return the HttpResponse object, this can be used for handling the response in whatever way required
HttpResponse getResponse()

// The number of milli seconds the callout took, for debugging / performance purposes
Integer getExecutionTime()
```


# Constructors
## Connecting to Salesforce APIs
The core of this library is to be able to connect to Salesforce APIs so there are a couple of way to do so with constructor based setups.

### Connect to Home Org
```java
// Base URL    : The current org (Home org) and the 
// BearerToken : The current logged in user's SessionId.(Through a VF page from Aura Context)
// SF Response handling: Enabled
global Rst(Boolean isSalesforce)

// Example
utl.Rst sfRst = new utl.Rst(true);
```

### Connect to any Org through a Named Credential
```java
// Base URL     : From Named Credential
// Bearer Token : From External Credential
// SF Response handling: Enabled
global Rst(String namedCredential, Boolean isSalesforce)

// Example
utl.Rst sfRst = new utl.Rst('Home_Org',true);
```

## Call to any OAuth enabled API
### Call API any using a named credential
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

## Call any API
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