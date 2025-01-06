trigger ContactTrigger on Contact (after insert) {

    Trigger_Bypass__c bypassTriggerSetting = Trigger_Bypass__c.getInstance(UserInfo.getUserId());
    Boolean bypassTrigger = bypassTriggerSetting?.ContactTrigger__c ?? false;

    if(bypassTrigger) {
        return;
    }

    ContactTriggerHandler handler = new ContactTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.newMap);
    }
}