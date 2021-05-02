@isTest
global class WFMAPI_SuccessRespMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.getBodyAsBlob();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"success":true,"secretKey":"a56555578888865"}');
        return response; 
    }
}