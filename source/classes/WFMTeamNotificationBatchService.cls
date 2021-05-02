public with sharing class WFMTeamNotificationBatchService implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    //variables and constants declaration
    private static final String STATUS='Pending';
    private String query;

    //Constructor -Build the SQL queryfor the closed cases with status 'Pending' from WorkforcePlanningTeamNotification table
    public WFMTeamNotificationBatchService(){
        query='select Id,CaseId__c,AgentId__c,APINotificationStatus__c,ErrorMessage__c from WorkforceTeamNotification__c Where APINotificationStatus__c =:STATUS';
    }

    //Add additional predicate with 5 min delay from thier created date
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime currTimeMinusFive = Datetime.now().addMinutes(-5);         
        if( !Test.isRunningTest() )  query += ' AND CreatedDate <= :currTimeMinusFive ';
        return Database.getQueryLocator(query);
    }

    //Invoke service for each closed case, Execute method is called once for each case from the above query(i.e scope has 1 record) allowing more time to complete the API successfully.  
    public void execute(Database.BatchableContext BC, List<WorkforceTeamNotification__c> scope) {

        Savepoint sp = Database.setSavepoint();
        try{
            for(WorkforceTeamNotification__c WFMNoticationInpRec:scope){
                WFMTeamNotificationServiceHelper.initiateServiceCall(WFMNoticationInpRec);
            } 
        }
        catch(Exception ex) { 
            Database.rollback(sp);
            for(WorkforceTeamNotification__c wftn : scope) {
                wftn.ErrorMessage__c = ex.getMessage() + ' ' + ex.getStackTraceString();
                wftn.APINotificationStatus__c = WFM_Constants.STATUS_ERROR;
            }
            update scope;
        }       
    }
    public void finish(Database.BatchableContext BC) {

    }
}