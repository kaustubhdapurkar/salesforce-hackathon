trigger OrderTrigger on Order (after insert) {

    Trigger_Bypass__c bypassTriggerSetting = Trigger_Bypass__c.getInstance(UserInfo.getUserId());
    Boolean bypassTrigger = bypassTriggerSetting?.OrderTrigger__c ?? false;

    if(bypassTrigger) {
        return;
    }

    OrderTriggerHandler handler = new OrderTriggerHandler();
    
    if(Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new);
    }
}