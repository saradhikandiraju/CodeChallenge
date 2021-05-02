trigger CaseTrigger on Case(after update){
    
	//The below logic is executed for all case updates after commit
   
	If (Trigger.IsUpdate && Trigger.IsAfter){
		set<Id> closedCaseIds=new set<Id>();
		set<WorkforceTeamNotification__c> WFMRecordsUpsertList=new set<WorkforceTeamNotification__c>();
		//Extract all the closed cases from current transaction
		for (Case c:Trigger.New){
			 If (c.status == WFM_Constants.STATUS_CLOSED && 
				 c.status! = Trigger.oldMap.get(c.status) &&
				 String.isBlank(c.Secret_Key__c))
				 closedCaseIds.add(c.Id);
		
		}
		
		//Query the WorkForceTeamNotification table to verify if the closed entries are already exists 
		If (!closedCaseIds.isEmpty()){
			Map<Id,WorkforceTeamNotification__c> WFMNotifyMap=[Select Id,CaseId__c from WorkforceTeamNotification__c where CaseId__c=:closedCaseIds];
		}	
		//Build the list to make new entries into new table for closed cases
		for(Id caseId:closedCaseIds){
			
			If (WFMNotifyMap.containsKey(caseId))WFMNotifyNewRec.Id=WFMNotifyRecs[0].Id;
			WFMNotifyNewRec.CaseId__c=caseId;
			WFMNotifyNewRec.AgentId__c=UserInfo.getuserId();// This may be ownerId
			WFMNotifyNewRec.APINotificationStatus__c=WFM_Constants.STATUS_PENDING;
			WFMRecordsUpsertList.add(WFMNotifyNewRec);
		}
		//Perform DML upsert operation on WFM Record list
		Upsert WFMRecordsUpsertList;
			 
	}		
		
        
    
    
}  