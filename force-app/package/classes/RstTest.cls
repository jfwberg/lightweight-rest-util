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
    // Package permission set name
    private static final String PERMISSION_SET_NAME = 'Lightweight_REST_Util';

    // Create a test user
    private static final User TST_USER = utl.Tst.createRunAsUser(
        utl.Tst.MINIMUM_ACCESS_PROFILE,
        PERMISSION_SET_NAME
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
            URL.getOrgDomainUrl().toExternalForm() + '/services/data/v58.0',
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
            .setApiVersion('v58.0')
            .setupRequest();
        }
        Test.stopTest();

        // Validate endpoint URL
        Assert.areEqual(
            'callout:ncName/services/data/v58.0',
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
            callout.getExecutionTime() != null && callout.getExecutionTime() > 0,
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
}