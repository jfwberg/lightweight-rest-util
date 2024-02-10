/**
 * @description A lightweight Apex utility for executing (Salesforce) REST based APIs
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        September 2023
 * @license     See License file in the project root
 * @test        The Rst class (94%)
 */
@IsTest
private with sharing class RstTest {

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Create a test user
    private static final User TST_USER = utl.Tst.createRunAsUser(
        utl.Tst.MINIMUM_ACCESS_PROFILE,
        Rst.PERMISSION_SET_NAME
    );


    /** **************************************************************************************************** **
     **                                      CONSTRUCTOR TEST METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test a blank constructor
     */
     @IsTest
    static void testBlankConstructor(){
        // Rst Instance for testing
        Rst callout;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst().setupRequest();
        }
        Test.stopTest();

        // Validate endpoint URL
        Assert.areEqual(
            true,
            String.isBlank(callout.getRequest().getEndpoint()),
            'Unexpected endpoint value'
        );

        // Validate bearer token value
        Assert.areEqual(
            null,
            callout.getRequest().getHeader(Rst.AUTH_HEADER),
            'Unexpected bearerToken value'
        );

        // Validate Handle handleSfEndpoint Status
        Assert.areEqual(
            false,
            callout.handleSfEndpoint,
            'Unexpected handleSfEndpoint value'
        );

        // Validate Handle handleSfResponse Status
        Assert.areEqual(
            false,
            callout.handleSfResponse,
            'Unexpected handleSfResponse value'
        );
    }


    @IsTest
    static void testNamedCredentialConstructor(){
        // Rst Instance for testing
        Rst callout;
        
        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst('ncName').setupRequest();
        }
        Test.stopTest();

         // Validate endpoint URL
        Assert.areEqual(
            'callout:ncName',
            callout.getRequest().getEndpoint(),
            'Unexpected endpoint value'
        );

        // Validate bearer token value
        Assert.areEqual(
            null,
            callout.getRequest().getHeader(Rst.AUTH_HEADER),
            'Unexpected bearerToken value'
        );

        // Validate Handle handleSfEndpoint Status
        Assert.areEqual(
            false,
            callout.handleSfEndpoint,
            'Unexpected handleSfEndpoint value'
        );

        // Validate Handle handleSfResponse Status
        Assert.areEqual(
            false,
            callout.handleSfResponse,
            'Unexpected handleSfResponse value'
        );
    }


    @IsTest
    static void testBaseUrlBearerTokenConstructor(){
        // Rst Instance for testing
        Rst callout;
        
        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst(Rst.TEST_MY_DOMAIN, Rst.TEST_SESSION_ID).setupRequest();
        }
        Test.stopTest();

        // Validate endpoint URL
        Assert.areEqual(
            Rst.TEST_MY_DOMAIN,
            callout.getRequest().getEndpoint(),
            'Unexpected endpoint value'
        );

        // Validate bearer token value
        Assert.areEqual(
            'Bearer ' + Rst.TEST_SESSION_ID,
            callout.getRequest().getHeader(Rst.AUTH_HEADER),
            'Unexpected bearerToken value'
        );

        // Validate Handle handleSfEndpoint Status
        Assert.areEqual(
            false,
            callout.handleSfEndpoint,
            'Unexpected handleSfEndpoint value'
        );

        // Validate Handle handleSfResponse Status
        Assert.areEqual(
            false,
            callout.handleSfResponse,
            'Unexpected handleSfResponse value'
        );
    }


    /** **************************************************************************************************** **
     **                                SALESFORCE CONSTRUCTOR TEST METHODS                                   **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test a constructor that connects to a Salesforce home org
     */
    @IsTest
    static void testSalesforceHomeOrgConstructor(){
        // Rst Instance for testing
        Rst callout;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst(true).setupRequest();
        }
        Test.stopTest();

        // Validate endpoint URL
        Assert.areEqual(
            URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0',
            callout.getRequest().getEndpoint(),
            'Unexpected endpoint value'
        );

        // Validate bearer token value
        Assert.areEqual(
            'Bearer ' + Rst.TEST_SESSION_ID,
            callout.getRequest().getHeader(Rst.AUTH_HEADER),
            'Unexpected bearerToken value'
        );

        // Validate Handle handleSfEndpoint Status
        Assert.areEqual(
            true,
            callout.handleSfEndpoint,
            'Unexpected handleSfEndpoint value'
        );

        // Validate Handle handleSfResponse Status
        Assert.areEqual(
            true,
            callout.handleSfResponse,
            'Unexpected handleSfResponse value'
        );
    }


    @IsTest
    static void testSalesforceNamedCredentialConstructor(){
        // Rst Instance for testing
        Rst callout;
        
        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst('ncName',true)
            .setApiVersion('v60.0')
            .setupRequest();
        }
        Test.stopTest();

        // Validate endpoint URL
        Assert.areEqual(
            'callout:ncName/services/data/v60.0',
            callout.getRequest().getEndpoint(),
            'Unexpected endpoint value'
        );

        // Validate bearer token value
        Assert.areEqual(
            null,
            callout.getRequest().getHeader(Rst.AUTH_HEADER),
            'Unexpected bearerToken value'
        );

        // Validate Handle handleSfEndpoint Status
        Assert.areEqual(
            true,
            callout.handleSfEndpoint,
            'Unexpected handleSfEndpoint value'
        );

        // Validate Handle handleSfResponse Status
        Assert.areEqual(
            true,
            callout.handleSfResponse,
            'Unexpected handleSfResponse value'
        );
    }


    /** **************************************************************************************************** **
     **                                        SETTER TEST METHODS                                           **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test the setter methods
     */
    @IsTest
    static void testSetters(){
        
        // Rst Instance for testing
        Rst callout;

        // Add a response to prevent any errors and test the mock response identifier
        utl.Mck.addResponse('MyMockResponseIdentifier', 400, 'SUCCESS');
        
        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst()
                .setBaseUrl(Rst.TEST_MY_DOMAIN)
                .setBearerToken(Rst.TEST_SESSION_ID)
                .setApiVersion(Rst.TEST_API_VERSION)
                .setEndpoint(Rst.TEST_ENDPOINT)
                .setHandleSfEndpoint(true)
                .setHandleSfResponse(true)
                .setMethod('POST')
                .setTimeout(60000)
                .setBody('{"success" : true}')
                .setHeader('debug', '1')
                .setHeader('debug', null)
                .setRequestIdHeader('requestId')
                .setCorrelationIdHeader('correlationId')
                .setPrettyPrintHeader(true)
                .setContentTypeHeaderToXml()
                .setMockResponseIdentifier('MyMockResponseIdentifier')
                .setupRequest();
        }
        Test.stopTest();

        // Assert endpoint
        Assert.areEqual(
            Rst.TEST_MY_DOMAIN + '/services/data/' + Rst.TEST_API_VERSION + Rst.TEST_ENDPOINT ,
            callout.getRequest().getEndpoint(),
            'Unexpected endpoint'
        );

        // Assert method
        Assert.areEqual(
            'POST' ,
            callout.getRequest().getMethod(),
            'Unexpected HTTP Method'
        );

        // Assert content Type
        Assert.areEqual(
            '18' ,
            callout.getRequest().getHeader('Content-Length'),
            'Unexpected HTTP Method'
        );

        // Assert Body
        Assert.areEqual(
            '{"success" : true}' ,
            callout.getRequest().getBody(),
            'Unexpected HTTP Method'
        );

        // Assert responseId
        Assert.areEqual(
            'requestId' ,
            callout.getRequestId(),
            'Unexpected requestId'
        );

        // Assert correlationId
        Assert.areEqual(
            'correlationId' ,
            callout.getCorrelationId(),
            'Unexpected correlationId'
        );

        // Assert correlationId
        Assert.areEqual(
            'text/xml; charset=UTF-8;' ,
            callout.getRequest().getHeader('Content-Type'),
            'Unexpected content type'
        ); 

        // Assert Mock response set through the utility
        Assert.areEqual(
            'SUCCESS' ,
            utl.Mck.getInstance().respond(null).getBody(),
            'Unexpected test mock body'
        );

        // Assert Mock status code set through the utility
         Assert.areEqual(
            400,
            utl.Mck.getInstance().respond(null).getStatusCode(),
            'Unexpected test mock status code'
        );
    }


    /**
     * @description Method to test the setter methods
     */
    @IsTest
    static void testUrlEncodedForm(){
        // Rst Instance for testing
        Rst callout;
            
        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            callout = new Rst()
                .setEndpoint(Rst.TEST_ENDPOINT)
                .setHandleSfEndpoint(true)
                .setHandleSfResponse(true)
                .setContentTypeHeaderToFormUrlEncoded(new Map<String,String>{'query' => 'SELECT Id FROM Account'})
                .setupRequest();
        }
        Test.stopTest();

        // Assert method
        Assert.areEqual(
            'POST' ,
            callout.getRequest().getMethod(),
            'Unexpected HTTP Method'
        );

        // Assert correlationId
        Assert.areEqual(
            'application/x-www-form-urlencoded' ,
            callout.getRequest().getHeader('Content-Type'),
            'Unexpected content type'
        );

        // Assert responseId
        Assert.areEqual(
            'query=SELECT+Id+FROM+Account' ,
            callout.getRequest().getBody(),
            'Unexpected requestId'
        );
    }


    /** **************************************************************************************************** **
     **                                          CALLOUT METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test a successful callout
     */
    @IsTest
    static void testSuccessCallout(){
        // Rst Instance for testing
        Rst callout;
        
        // The response
        String response = '{"success" : true}';

        // Method and overloads to set a SINGLE Mock response
        utl.Mck.setResponse(response);

        // Set the mock for the test
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run test
        Test.startTest();
        
        // Execute the test
        System.runAs(TST_USER){
            callout = new Rst(true).call();
        }
        Test.stopTest();

        // Assert execution time
        Assert.areEqual(
            true,
            callout.getExecutionTime() != null,
            'Expected execution time to exist'
        );

        // Assert response body
        Assert.areEqual(
            response,
            callout.getResponse().getBody(),
            'Unexpected HTTP Method'
        );
    }


    @IsTest
    static void testFailedCalloutErrorObject(){
        // Rst Instance for testing
        Rst callout;

        // Object to hold the exception
        Exception testExecption;

        // The response
        String response = '{"error" : "Test Error", "error_description" : "Test Error Description"}';
        
        // Method and overloads to set a SINGLE Mock response
        utl.Mck.setResponse(
            401,
            response
        );

        // Set the mock for the test
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run test
        Test.startTest();
        
        // Execute the test
        System.runAs(TST_USER){
            try{
                callout = new Rst(true).call();
                
                // This fails the test if reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testExecption = e;
            }
        }
        Test.stopTest();

        // Assert execution time
        Assert.areEqual(
            'Test Error' + Rst.SINGLE_ERROR_MESSAGE_DELIMITER + 'Test Error Description',
            testExecption.getMessage(),
            'Unexpected exception message'
        );
    }


    @IsTest
    static void testFailedCalloutErrorObjectForDataCloud(){
        // Rst Instance for testing
        Rst callout;

        // Object to hold the exception
        Exception testExecption;

        // The response
        String response = '{"timestamp":"2023-10-05T08:20:14.535Z","error":"Method Not Allowed","message":"Request method \'POST\' not supported","path":"uri=/query/v1/metadata","tenantId":"a360/prod3/bea0e43df00943bf8ab7fe09baadc182","internalErrorCode":"COMMON_ERROR_HTTP_REQUEST_METHOD_NOT_SUPPORTED","details":{}}';
        
        // Method and overloads to set a SINGLE Mock response
        utl.Mck.setResponse(
            415,
            response
        );

        // Set the mock for the test
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run test
        Test.startTest();
        
        // Execute the test
        System.runAs(TST_USER){
            try{
                callout = new Rst(true).call();
                
                // This fails the test if reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testExecption = e;
            }
        }
        Test.stopTest();

        // Assert execution time
        Assert.areEqual(
            'Method Not Allowed' + Rst.SINGLE_ERROR_MESSAGE_DELIMITER + 'Request method \'POST\' not supported',
            testExecption.getMessage(),
            'Unexpected exception message'
        );
    }


    @IsTest
    static void testFailedCalloutErrorObjectWithDetailsForDataCloud(){
        // Rst Instance for testing
        Rst callout;

        // Object to hold the exception
        Exception testExecption;

        // The response
        String response = '{ "timestamp": "2021-08-20T16:34:26.047666Z", "error": "Bad Request", "message": "Bad Request: JSON is properly formatted but has a mismatch with Schema.", "path": "uri=/api/v1/ingest/sources/ecomm/Orders/actions/test", "tenantId": "{tenantId}", "internalErrorCode": "COMMON_ERROR_GENERIC", "details": { "validationReport": [ { "record": { "contact_name": "Joe Smith", "total": 77506, "tax_exempt": false, "id": "f19cae7e-5cdb-41ce-92ba-539afea04f9d", "created_date": "2021-07-22T08:57:08.118Z", "ship_address": "9818 Main", "modified_date": "2021-07-05T09:31:44.457Z", "tax_rate": 84 }, "causingExceptions": [ "#/id: expected type: Number, found: String" ] }, { "record": { "contact_name": "Tina Smith", "total": 16986, "tax_exempt": false, "id": "48c8b6a6-8179-4a15-ba19-ec5c8206ce28", "created_date": "2021-07-08T22:57:02.008Z", "ship_address": "245 Main", "modified_date": "2021-07-03T06:20:52.886Z", "tax_rate": 61 }, "causingExceptions": [ "#/id: expected type: Number, found: String" ] } ] } }';
        
        // Method and overloads to set a SINGLE Mock response
        utl.Mck.setResponse(
            429,
            response
        );

        // Set the mock for the test
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run test
        Test.startTest();
        
        // Execute the test
        System.runAs(TST_USER){
            try{
                callout = new Rst(true).call();
                
                // This fails the test if reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testExecption = e;
            }
        }
        Test.stopTest();

        // A joyful join :-)
        String expected = 
            'Bad Request' + 
            Rst.SINGLE_ERROR_MESSAGE_DELIMITER + 
            'Bad Request: JSON is properly formatted but has a mismatch with Schema.' + 
            Rst.SINGLE_ERROR_MESSAGE_DELIMITER + '{validationReport=({causingExceptions=(#/id: expected type: Number, found: String), record={contact_name=Joe Smith, created_date=2021-07-22T08:57:08.118Z, id=f19cae7e-5cdb-41ce-92ba-539afea04f9d, modified_date=2021-07-05T09:31:44.457Z, ship_address=9818 Main, tax_exempt=false, tax_rate=84, total=77506}}, {causingExceptions=(#/id: expected type: Number, found: String), record={contact_name=Tina Smith, created_date=2021-07-08T22:57:02.008Z, id=48c8b6a6-8179-4a15-ba19-ec5c8206ce28, modified_date=2021-07-03T06:20:52.886Z, ship_address=245 Main, tax_exempt=false, tax_rate=61, total=16986}})}';

        // Assert execution time
        Assert.areEqual(
            expected,
            testExecption.getMessage(),
            'Unexpected exception message'
        );
    }


    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testFailedCalloutErrorList(){
        // Rst Instance for testing
        Rst callout;

        // Object to hold the exception
        Exception testExecption;

        // The response
        String response = '[{"errorCode" : "ec1", "message" : "a"}, {"errorCode" : "ec2", "message" : "b"}]';
        
        // Method and overloads to set a SINGLE Mock response
        utl.Mck.setResponse(
            400,
            response
        );

        // Set the mock for the test
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run test
        Test.startTest();
        
        // Execute the test
        System.runAs(TST_USER){
            try{
                callout = new Rst(true).call();
                
                // This fails the test if reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testExecption = e;
            }
        }
        Test.stopTest();

        // Assert message
        utl.Tst.assertExceptionMessage(
            'ec1' + Rst.SINGLE_ERROR_MESSAGE_DELIMITER + 'a' + Rst.ERROR_DELIMITER + 'ec2' + Rst.SINGLE_ERROR_MESSAGE_DELIMITER + 'b',
            testExecption
        );
    }



    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testFailedCalloutUnknownResponse(){
        // Rst Instance for testing
        Rst callout;

        // Object to hold the exception
        Exception testExecption;
        
        // The response
        String response = '<html>Error Page in here</html>';
        
        // Method and overloads to set a SINGLE Mock response
        utl.Mck.setResponse(400,response);

        // Set the mock for the test
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run test
        Test.startTest();
        
        // Execute the test
        System.runAs(TST_USER){
            try{
                callout = new Rst(true).call();
                
                // This fails the test if reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testExecption = e;
            }
        }
        Test.stopTest();

        // Assert the exception message   
        utl.Tst.assertExceptionMessage(Rst.UNKNOWN_API_RESPONSE_MSG, response, testExecption);
    }


    /** **************************************************************************************************** **
     **                                        GLOBAL UTILITY METHODS                                        **
     ** **************************************************************************************************** **/
    @IsTest
    static void testValidateNamedCredentials(){
    
        // Test with null value will work during test
        Rst.validateNamedCredentials(new Set<String>());

        try{
            // Test with an invalid exception
            Rst.validateNamedCredentials(new Set<String>{'Invalid'});

            // This fails the test if reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(Exception e){
            // Assert the exception message   
            utl.Tst.assertExceptionMessage(Rst.INVALID_NAMED_CREDENTIAL_MSG, 'Invalid', e);
        }
    }


    @IsTest
    static void testBase64UrlEncode(){
        Assert.areEqual(
            'YWI_X2Fi',
            Rst.base64UrlEncode(Blob.valueOf('ab?_ab')),
            'Unexpected B64 URL encoding'
        );
    }

}