public with sharing class HTTPUtilityClass {

    public static HttpRequest buildHttpRequest(String WFMNameCredential,String method,Integer timeout){

        Httprequest request = new HttpRequest();
        request.setEndpoint('callout:/'+WFMNameCredential);
        request.setMethod(method);
        request.setTimeout(timeout);
        return request;


    }
}