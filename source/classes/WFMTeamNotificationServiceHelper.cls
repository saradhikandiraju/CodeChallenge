public with sharing class WFMTeamNotificationServiceHelper {
    


    public static void initiateServiceCall(WorkforceTeamNotification__c WFMNoticationInpRec) {
        
		HttpRequest request = buildRequestForServiceCall(WFMNoticationInpRec.CaseId__c, WFMNoticationInpRec.AgentId__c);
		HttpResponse response = invokeServiceRequest(request);
		processServiceResponse(response, WFMNoticationInpRec.Id,WFMNoticationInpRec.CaseId__c);
          
    }


    private static HttpRequest buildRequestForServiceCall(String caseId, String agentId) {
       
        HttpRequest request = HttpUtilityClass.buildHttpRequest(WFM_Constants.WFN_NAMED_CREDENTIAL, 'POST', 60000);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncode(new Map<String, String>{'id' => caseId, 'agentid' => agentId}));
        return request;
    }

    private static HttpResponse invokeServiceRequest(HttpRequest request) {
                  
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    private static void processServiceResponse(HttpResponse response, String WFMNotificationInpRecId,String caseId ) {
        
        if(response!=null) {
            WFMTeamNotifcationServiceResponse  resp = (WFMTeamNotifcationServiceResponse ) JSON.deserialize(response.getBody(), WFMTeamNotifcationServiceResponse .class);
            
            if(resp!=null && String.isNotBlank(resp.success)) {
                if(resp.success.equalsIgnoreCase('true')) {
                    //update WorkforceNotification Table with status 'completed'
                    update (new WorkforceTeamNotification__c(Id=WFMNotificationInpRecId,APINotificationStatus__c=WFM_Constants.STATUS_COMPLETED)); 
                    //update secret Key on Case
                    Case updateSecretKeyCase=[select Id,Secret_Key__c from case where Id=:caseId ];
                    updateSecretKeyCase.Secret_Key__c=resp.secretKey;
                    update updateSecretKeyCase;
                }
                else if(resp.success.equalsIgnoreCase('false')) {
                    //update WorkforceNotification Table with status 'error'
                    update (new WorkforceTeamNotification__c(Id=WFMNotificationInpRecId,APINotificationStatus__c=WFM_Constants.STATUS_ERROR,ErrorMessage__c=resp.error)); 
                }
            }
            
        } else{

            //update WorkforceNotification Table with status 'error' and Error message with 'No Message'
            update (new WorkforceTeamNotification__c(Id=WFMNotificationInpRecId,APINotificationStatus__c=WFM_Constants.STATUS_ERROR,ErrorMessage__c=WFM_Constants.NO_MESSAGE_RECEIVED));

        }
    }
    
    public static String urlEncode(Map<String, String> contentMap) {
        String resultStr = '';
        for(String IdStr : contentMap.keySet()) {
            resultStr += EncodingUtil.urlEncode(IdStr, 'UTF-8') + '=' + EncodingUtil.urlEncode(contentMap.get(IdStr), 'UTF-8') + '&';
        }
        return resultStr.removeEnd('&');    
    }
}