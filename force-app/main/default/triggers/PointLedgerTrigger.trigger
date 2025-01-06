trigger PointLedgerTrigger on Point_Ledger__c (after insert) {

    Trigger_Bypass__c bypassTriggerSetting = Trigger_Bypass__c.getInstance(UserInfo.getUserId());
    Boolean bypassTrigger = bypassTriggerSetting?.PointLedgerTrigger__c ?? false;

    if(bypassTrigger) {
        return;
    }

    PointLedgerTriggerHandler handler = new PointLedgerTriggerHandler();

    if(Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new, Trigger.newMap);
    }
}