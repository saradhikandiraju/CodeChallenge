@isTest
private class WFMTeamNotificationServiceTest {
    @TestSetup
    static void createData(){
        insert TestDataFactory.createCases(200);
    }

    @isTest static void successWFMResponseTest() {

        List<Case> cases  = new List<Case>();
        for (Case c : [SELECT status FROM Case]) {
            c.Status = 'Closed';
            cases.add(c);
        }
        Update cases;

        Test.setMock(HttpCalloutMock.class,  new WFMAPI_SuccessRespMock());
        Test.startTest();
        Id batchProcessId = Database.executeBatch(new WFMTeamNotificationBatchService(), 1);
        Test.stopTest();
        

    }

    @isTest static void failedWFMResponseTest() {
        List<Case> cases  = new List<Case>();
        for (Case c : [SELECT status FROM Case]) {
            c.Status = 'Closed';
           
            cases.add(c);
        }
        Update cases;

       Test.setMock(HttpCalloutMock.class,  new WFMAPI_FailedRespMock());
       Test.startTest();
       Id batchProcessId = Database.executeBatch(new WFMTeamNotificationBatchService(), 1);
       Test.stopTest();
    }
}