/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description A lightweight Apex utility for executing (Salesforce) REST based APIs
 * @note The bearerToken is transient so it won't be exposed when serialized
 *       This should never happen due to the JsonAccess, but just in case we
 *       should handle secrets securely. The value is also cleared after the callout
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ApexSuggestUsingNamedCred, PMD.EmptyStatementBlock, PMD.CyclomaticComplexity')
@JsonAccess(serializable='never' deserializable='never')
global with sharing class Rst {

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // The named credential API name
    private String namedCredential;

    // Base URL (My domain URL for Salesforce API)
    private String baseUrl;

    // The Bearer token (Session Id for Salesforce API)
    private transient String bearerToken;

    // Default API Configuration
    private String  apiVersion = 'v60.0';
    private String  endpoint   = '';
    private Integer	timeout	   = 120000;
    private String  method     = 'GET';
    private String  body       = '';
    
    // The (optional) request and correlation Id
    private String requestId;
    private String correlationId;

    // Create an empty header map
    private Map<String,String> headers = new Map<String,String>();

    // An optional identifier that can be added to call a specific Callout Mock Template
    // This leverages the utl.Mck class from the test package 
    private String mockResponseIdentifier;

    // Variable holding the request and response of the last execution, accessible for debug reasons
    private HttpRequest  request  = new HttpRequest();
    private HttpResponse response = new HttpResponse();

    // Variable to hold the execution time of the last API call
    private Integer executionTime;

    // Indicator if the Salesforce API endpoint is setup automatically
    // When true the endpoint will be set to /services/data/[API_VERSION]
    @TestVisible private Boolean handleSfEndpoint = false;

    // Indicator if you want this class to handle the response or simply execute
    // The point of this library is to have it taken care of everythign so by default this is true
    // When true it will throw an Exception with the salesforce error handling or unknow errors handling
    @TestVisible private Boolean handleSfResponse = false;


    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Values
	@TestVisible private static final String AUTH_HEADER = 'Authorization';
    @TestVisible private static final String AUTH_HEADER_HIDDEN_MESSAGE = '[BEARER_TOKEN_HIDDEN]';
    @TestVisible private static final String LIGHTNING_UI_DISPLAY_THEME = 'Theme4d';
    
    // Test related constants
    @TestVisible private static final String TEST_SESSION_ID  = '[SESSION_ID]';
    @TestVisible private static final String TEST_ENDPOINT    = '/sobjects/account/describe';
    @TestVisible private static final String TEST_MY_DOMAIN   = 'https://mydomain.my.salesforce.com';
    @TestVisible private static final String TEST_API_VERSION = 'v60.0';

    // Http methods that require a post body
    @TestVisible private static final Set<String> METHODS_REQUIRING_BODY = new Set<String>{'POST','PUT','PATCH','DELETE'};

    // Error messages
    @TestVisible private static final String UNKNOWN_API_RESPONSE_MSG     = 'Unknown API  Response body: {0}';
    @TestVisible private static final String INVALID_NAMED_CREDENTIAL_MSG = 'No NamedCredential record with the DeveloperName "{0}" found in the metadata.';


    /** **************************************************************************************************** **
     **                                          GLOBAL CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Package permission set name
    global static final String PERMISSION_SET_NAME = 'Lightweight_REST_Util';

    // Error delimiters are global so they can be safely tested in an external class
    global static final String ERROR_DELIMITER = ', ';
    global static final String SINGLE_ERROR_MESSAGE_DELIMITER = ' :: ';


    /** **************************************************************************************************** **
     **                                         GLOBAL CONSTRUCTORS                                          **
     ** **************************************************************************************************** **/
    /**
     * @description Constructor that configures nothing
     */
    global Rst(){}


    /**
     * @description Constructor with a named credential as a parameter.
     * @param namedCredential String containing the name of the named credential to be used for authentication.
     */
    global Rst(String namedCredential){
        this.namedCredential = namedCredential;
    }


    /**
     * @description Constructor to set the my domain url and the Session Id manually
     * @param baseUrl     The base URL used to make the API call.
     * @param bearerToken The bearer token used to authenticate the API call.
     */
    global Rst(String baseUrl, String bearerToken){
        this.baseUrl= baseUrl;
        this.bearerToken  = bearerToken;
    }


    /** **************************************************************************************************** **
     **                                     SALESFORCE API CONSTRUCTORS                                      **
     ** **************************************************************************************************** **/
    /**
     * @description Constructor to set the base URL to the current org and the session Id
     *              to the session Id of the currently logged in User
     * @param isSalesforce    Set to true to enable standard Salesforce error handling
     */
    global Rst(Boolean isSalesforce){
        this.baseUrl          = URL.getOrgDomainUrl().toExternalForm();
        this.bearerToken      = this.getApiEnabledSessionId();
        this.handleSfEndpoint = true;
        this.handleSfResponse = true;
    }


    /**
     * @description Constructor to set the connection to a named credential and the indicator
     *              this is a named credential referencing a Salesforce org
     * @param namedCredential String containing the name of the named credential to be used for authentication.
     * @param isSalesforce    Set to true to enable standard Salesforce error handling
     */
    global Rst(String namedCredential, Boolean isSalesforce){
        this.namedCredential  = namedCredential;
        this.handleSfEndpoint = true;
        this.handleSfResponse = true;
    }


    /** **************************************************************************************************** **
     **                                            GLOBAL SETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description The API base URL (i.e. https://mydomain.my.salesforce.com)
     * @param baseUrl The value to assign
     * @return this
     */
    global Rst setBaseUrl(String baseUrl){
        this.baseUrl = baseUrl;
        return this;
    }


    /**
     * @description The bearer token that will be added in the Authorization header
     * @param bearerToken The value to assign
     * @return this
     */
    global Rst setBearerToken(String bearerToken){
        this.bearerToken = bearerToken;
        return this;
    }


    /**
     * @description When true the endpoint value will prefixed with /services/data/[API_VERSION]
     * @param handleSfEndpoint The value to assign
     * @return this
     */
    global Rst setHandleSfEndpoint(Boolean handleSfEndpoint){
        this.handleSfEndpoint = handleSfEndpoint;
        return this;
    }


    /**
     * @description Set this to true if you want the utility to handle Salesforce API responses
     * @param handleSfResponse The value to assign
     * @return this
     */
    global Rst setHandleSfResponse(Boolean handleSfResponse){
        this.handleSfResponse = handleSfResponse;
        return this;
    }


    /**
     * @description The HTTP Method, i.e. GET, POST, PUT etc.
     * @param method The value to assign
     * @return this
     */
    global Rst setMethod(String method){
        this.method = method;
        return this;
    }


    /**
     * @description The API version in full format i.e. v60.0
     * @param apiVersion The value to assign
     * @return this
     */
    global Rst setApiVersion(String apiVersion){
        this.apiVersion = apiVersion;
        return this;
    }


    /**
     * @description The endpoint that comes after the base url i.e. /services/data/v60.0/sobjects/accounts/describe
     * @param endpoint The value to assign
     * @return this
     */
    global Rst setEndpoint(String endpoint){
        this.endpoint = endpoint;
        return this;
    }


    /**
     * @description The REST callout time out value
     * @param timeout The value to assign
     * @return this
     */
    global Rst setTimeout(Integer timeout){
        this.timeout = timeout;
        return this;
    }


    /**
     * @description The callout body required for PUT, POST and PATCH methods
     * @param body  The value to assign
     * @return this
     */
    global Rst setBody(String body){
        this.body = body;
        return this;
    }


    /**
     * @description Method to set a header key/value pair
     * @param key   The value for the key
     * @param value The value for the value
     * @return this
     */
    global Rst setHeader(String key,String value){
        if(String.isBlank(value)){
            this.headers.remove(key);
        }else{
            this.headers.put(key,value);
        }
        return this;
    }


    /**
     * @description Method to set a mockResponseIdentifier so you can specify what utl.Mck is returned
                    response is returned during an Apex Unit Test.
     * @param mockResponseIdentifier   The value for the mockResponseIdentifier
     * @return this
     */
    global Rst setMockResponseIdentifier(String mockResponseIdentifier){
        this.mockResponseIdentifier = mockResponseIdentifier;
        return this;
    }


    /**
     * @description Method to set the X-PrettyPrint header to value '1'
     * @param prettyPrint The value for the value
     * @return this
     */
    global Rst setPrettyPrintHeader(Boolean prettyPrint){
        this.setHeader('X-PrettyPrint', prettyPrint ? '1' : '0');
        return this;
    }


    /**
     * @description Method to set an X-Request-ID header
     * @return this
     */
    global Rst setRequestIdHeader(String requestId){
        
        this.requestId = String.isNotBlank(requestId) ? requestId : Rst.guid();
        this.setHeader('X-Request-ID', this.requestId);
        return this;
    }


    /**
     * @description Method to set an X-Correlation-ID header
     * @param value The value for the correlation Id, set to NULL to generate one
     * @return this
     */
    global Rst setCorrelationIdHeader(String correlationId){
        this.correlationId = String.isNotBlank(correlationId) ? correlationId : Rst.guid();
        this.setHeader('X-Correlation-ID', this.correlationId);
        return this;
    }


    /**
     * @description Method to set the content type to 'text/xml; charset=UTF-8;'
     * @return this
     */
    global Rst setContentTypeHeaderToXml(){
        this.setHeader('Content-Type', 'text/xml; charset=UTF-8;');
        return this;
    }
    

    /**
     * @description Method to set a request for a
     * @param parameterValueMap Key value map for generating the url query string
     * @return this
     */
    global Rst setContentTypeHeaderToFormUrlEncoded(Map<String,String> parameterValueMap){
        this.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        this.setBody(Rst.urlParameterQueryString(parameterValueMap));
        this.setMethod('POST');
        return this;
    }


    /** **************************************************************************************************** **
     **                                            GLOBAL GETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description Method to get the HttpRequest related to the current rest callout
     * @return      The current HttpRequest object
     */
    global HttpRequest getRequest(){
        return this.request;
    }


    /**
     * @description Method to get the HttpResponse related to the current rest callout
     *              Use this after the callout has been executed
     * @return      The current HttpResponse object
     */
    global HttpResponse getResponse(){
        return this.response;
    }


    /**
     * @description Method to get the (generated) X-Request-ID value
     * @return      the request id
     */
    global String getRequestId(){
        return this.requestId;
    }


    /**
     * @description Method to get the (generated) X-Correlation-ID value
     * @return      the request id
     */
    global String getCorrelationId(){
        return this.correlationId;
    }


    /**
     * @description Method to execute the REST Call
     * @return      The number of milliseconds it took to execute the request
     */
    global Integer getExecutionTime(){
        return this.executionTime;
    }


    /**
     * @description Method to get a VF API enabled session Id for local session.
     *              Calls a VF page and extracts the session Id, this is quite a hack but allowed in AppExchange reviews
     *              It is required for lightning components to communicate with the Salesforce API directy
     *              Ideally you would always use a Named credential for each connection, even to the local org
     * @return      An API enabled Session Id
     */
    global String getApiEnabledSessionId(){
        return
            (Test.isRunningTest()) ?
                Rst.TEST_SESSION_ID :
                (System.Request.getCurrent().getQuiddity() == Quiddity.AURA || UserInfo.getUiThemeDisplayed() == LIGHTNING_UI_DISPLAY_THEME) ?
                    Page.getSessionId.getContent().toString().trim() :
                    UserInfo.getSessionId();
    }    


    /** **************************************************************************************************** **
     **                                        GLOBAL SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method to setup the request before sending it.
     *              This separates the setup of the request before sending it so it can be
     *              easily debugged, tested or executed through  a custom Http Utility / loging Utility
     * @return this
     */
    global Rst setupRequest(){

        // Set the basic request parameters
        this.request.setTimeout(this.timeout);
        this.request.setMethod(this.method);
        this.request.setEndpoint(this.generateFullEndpoint());
        this.generateHeaders();

        // Check if the request has a specific mock response identifier
        if(!String.isBlank(this.mockResponseIdentifier)){
            utl.Mck.setResponseIdentifier(this.mockResponseIdentifier);
        }

        // Set the body and Content-Length header for put, post, patch calls
        if(String.isNotBlank(this.body) && Rst.METHODS_REQUIRING_BODY.contains(method)){
           
            // Set he request body parameter
            this.request.setBody(this.body);
            
            // If no named credential is used add the content length automatically
            // If you set this using a named credential you'll get a "Script-Thrown Exception" message
            if(String.isBlank(this.namedCredential)){
                this.request.setHeader('Content-Length', String.ValueOf(this.body.length()));
            }
        }
        return this;
    }


    /**
     * @description Method to execute the REST Call
     * @return this
     */
    global Rst call(){
        try{
            // Setup the request before it is called
            this.setupRequest();

            // Set start date
            Integer startDateTime = Integer.valueOf(Datetime.now().millisecond());

            // Send the request or send a Mock Response whilst running an apex test
            this.response = (!Test.isRunningTest()) ? new Http().send(this.request) : utl.Mck.getInstance().respond(this.request);

            // Calculate call duration in milliseconds
            this.executionTime = (Integer.valueOf(Datetime.now().millisecond()) - startDateTime);

            // Remove the bearerToken and authorization header to prevent data leakage when outputting the class
            if(String.isNotBlank(this.bearerToken)){
                this.bearerToken = Rst.AUTH_HEADER_HIDDEN_MESSAGE;
            }

            // Remove the authorization header to prevent data leakage when outputting the class
            if(String.isNotBlank(this.request.getHeader(Rst.AUTH_HEADER))){
                this.request.setHeader(Rst.AUTH_HEADER, Rst.AUTH_HEADER_HIDDEN_MESSAGE);
            }

            // Execute response handling logic
            return handleSfResponse();

        }catch(Exception e){
            throw new RestUtilException(e.getMessage());
        }
    }

    
    /** **************************************************************************************************** **
     **                                        GLOBAL UTILITY METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method for encoding a Blob into a Base64 URL encoded String.
     *              This is required for generating the JWS
     * @param       input The input Blob to convert to a Base64Url Encoded String
     * @return      Base64 Url Encoded String
     */
    global static String base64UrlEncode(Blob input){
        return EncodingUtil.base64Encode(input).replace('+', '-').replace('/', '_');
    }


    /**
     * @description Method to validate a named credential exists
     * @note        Utility does not really belong in here, but it is closely
     *              related and it saves having another package to manage
     * @param  developerNames           A set of Named Credentials
     * @throws NamedCredentialException If a Named credential does not exist 
     * 
     */
    global static void validateNamedCredentials(Set<String> developerNames){
        
        // Query the named credentials, maxed out at 1000, but you should never need that many
        NamedCredential[] namedCredentials = [  SELECT DeveloperName FROM NamedCredential
                                                WHERE DeveloperName IN :developerNames 
                                                WITH USER_MODE LIMIT 1000];

        // For testing purposes create a  named credential list with a blank Named Credential
        if(Test.isRunningTest()){
            namedCredentials = new NamedCredential[]{new NamedCredential()};
        }

        // Map for referencing named credential info
        Map<String, NamedCredential> namedCredentialMap = new Map<String, NamedCredential>();

        // Populate the named credentials map so it can be referenced later after checking it
        for(Integer i=0,max=namedCredentials.size();i<max;i++){
            namedCredentialMap.put(namedCredentials[i].DeveloperName, namedCredentials[i]);
        }

        // Check the named credentials exist, prevent this during Apex test as there migh not be any named credentials in the target org
        for(String developerName : developerNames){
            if(!namedCredentialMap.containsKey(developerName)){
                throw new NamedCredentialException(String.format(INVALID_NAMED_CREDENTIAL_MSG, new String[]{developerName}));
            }
        }
    }


    /**
     * description Method to generate a GUID, upgraded to the standard Salesforce method
     * @return a GUID string
     */
    global static String guid() {        
        return UUID.randomUUID().toString();
    }


    /**
     * @description Method to convert a key/value map into a URL encoded parameter query string that
     *              can be used with url-encoded forms or get queries
     * @param       parameterValueMap A key/value map that contains the parameter name and the
     *                                parameter value
     * @return      a url encoded parameter string formatted like "?key1=value1&key2=value2"
     */
    global static String urlParameterQueryString(Map<String,String> parameterValueMap){
        
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


    /** **************************************************************************************************** **
     **                                        PRIVATE SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method to generate the endpoint URL based on named credential,
     *              base url and endpoint
     * @return      The full endpoint consisting of the base URL, Salesforce options and the endpoint
     */
    private String generateFullEndpoint(){
        return
        (this.handleSfEndpoint) ?
            String.format('{0}/services/data/{1}{2}',
                new String[]{
                    String.isNotBlank(this.namedCredential) ? ('callout:' + this.namedCredential) : this.baseUrl,
                    this.apiVersion,
                    this.endpoint
                }
            ) :
            String.format('{0}{1}',
                new String[]{
                    String.isNotBlank(this.namedCredential) ? ('callout:' + this.namedCredential) : (String.isNotBlank(this.baseUrl)) ? this.baseUrl : '',
                    this.endpoint
                }
            );
    }


    /**
     * @description Method that generates the default and custom headers into the
     *              HttpRequest. Custom headers will override the default headers
     */
    private void generateHeaders(){

        // If there is no content type set, override it with a default content type
        if(!this.headers.containsKey('Content-Type')){
            this.request.setHeader(  'Content-Type', 'application/json;charset=UTF-8');
        }

        // When there is no named credential, populate the Session Id as the bearer token
        if(String.isBlank(this.namedCredential) && String.isNotBlank(bearerToken)){
            this.request.setHeader(Rst.AUTH_HEADER,'Bearer ' + this.bearerToken);
        }

        // Add the additional headers, default headers will be overwritten if present
        for(String headerKey : this.headers.keySet()){
            if(String.isNotBlank(headerKey)){
                this.request.setHeader(headerKey, this.headers.get(headerKey));
            }
        }
    }


    /** **************************************************************************************************** **
     **                                  PRIVATE RESPONSE HANDLING METHODS                                   **
     ** **************************************************************************************************** **/
    /**
     * @description Method to handle what happens to the API response based on the status code
     * @return this
     */
    private Rst handleSfResponse(){

        // If true handle the response; If false, do nothing but execute and let the user handle it
        if(this.handleSfResponse){
            switch on this.response.getStatusCode() {
                // Success responses
                when 200, 201, 202, 204 {
                    return this;
                }

                // Handle error responses
                when 400, 401, 404, 405, 409, 415, 422, 429, 500 {
                   try{
                        // Try to deserialize a JSON response, if this fails throw an exception
                        Object errorResponse = JSON.deserializeUntyped(this.response?.getBody());

                        // Handle either an error Object response or an error list response
                        if(errorResponse instanceOf Map<String,Object>){
                            this.handleSfErrorObject(errorResponse);
                        }else if(errorResponse instanceOf Object[]){
                            this.handleSfErrorObjectList(errorResponse);
                        }
                    }catch(System.JSONException e){
                        this.handleUnknownSfResponse();
                    }
                }
                when else{
                    this.handleUnknownSfResponse();
                }
            }
        }
        return this;
    }


    /**
     * @description Method to throw an exception containing the Salesforce API Error Message Object
     *             This error type is usually only thrown by a 401 having an OAuth related error
     * @param errorResponse The error Object from the parsed JSON response
     */
    private void handleSfErrorObject(Object errorResponse){

        // Typecast into an error object
        Map<String,Object> errorObject = (Map<String,Object>) errorResponse;

        // Validate the error object has the correct format
        if(errorObject.containsKey('error') && errorObject.containsKey('error_description')){
            throw new RestUtilException(
                errorObject.get('error') + Rst.SINGLE_ERROR_MESSAGE_DELIMITER + errorObject.get('error_description')
            );

        // Handle Data Cloud API errors gracefully
        }else if(errorObject.containsKey('error') && errorObject.containsKey('message')){

            // Get additional details for the data cloud API errors
            String details = (errorObject.containsKey('details')) ? String.valueOf(errorObject.get('details')) : '';

            // Throw the detailed exception message
            throw new RestUtilException(
                errorObject.get('error') + 
                Rst.SINGLE_ERROR_MESSAGE_DELIMITER + 
                errorObject.get('message') + 
                ((String.isNotBlank(details) && details != '{}') ? Rst.SINGLE_ERROR_MESSAGE_DELIMITER + details : '')
            );
        }else{
            this.handleUnknownSfResponse();
        }
    }


    /**
     * @description Method to throw an exception containing the Salesforce API Error Message Object List
     *              These types of errors are thrown by the common rest APIs
     * @param errorResponse The error Object from the parsed JSON response
     */
    private void handleSfErrorObjectList(Object errorResponse){

        // List of error messages
        String[] errorMessages = new String[]{};

        // Iterate the error messages
        for(Object error : (Object[]) errorResponse){

            // Typecast into an error object
            Map<String,Object> errorObject = (Map<String,Object>) error;

            // Validate the error object has the correct format
            if(errorObject.containsKey('errorCode') && errorObject.containsKey('message')){
                errorMessages.add(
                    errorObject.get('errorCode') + Rst.SINGLE_ERROR_MESSAGE_DELIMITER + errorObject.get('message')
                );
            }else{
                this.handleUnknownSfResponse();
            }
        }

        // Collect the error messages and throw a RestUtilException
        throw new RestUtilException(String.join(errorMessages, Rst.ERROR_DELIMITER));
    }


    /**
     * @description Method to throw an exception containing the Salesforce API Error response that
     *              is not recognised by the standard response format
     */
    private void handleUnknownSfResponse(){
        throw new RestUtilException(String.format(Rst.UNKNOWN_API_RESPONSE_MSG, new String[]{this.response?.getBody()}));
    }


    /** **************************************************************************************************** **
     **                                          EXCEPTION CLASSES                                           **
     ** **************************************************************************************************** **/
    /**
     * @description Class representing an exception thrown by the utility
     */
    global with sharing class RestUtilException extends Exception{}


    /**
     * @description Class representing an exception related to a named credential issue
     */
    global class NamedCredentialException extends Exception{}
}