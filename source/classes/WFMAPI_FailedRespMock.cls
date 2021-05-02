@isTest
global class WFMAPI_FailedRespMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.getBodyAsBlob();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"success":false, "error": "Case does not exists"}');
        return response; 
    }
}