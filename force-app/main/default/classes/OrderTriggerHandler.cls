public without sharing class OrderTriggerHandler {
    public void onAfterInsert(List<Order> newOrders) {
        createPointLedgerRecords(newOrders);
    }

    public static void createPointLedgerRecords(List<Order> newOrders) {
        List<Point_Ledger__c> pointLedgerRecords = new List<Point_Ledger__c>();
        for(Order order : newOrders) {
            if(order.Points_Redeemed__c > 0) {
                Point_Ledger__c pointLedgerRecord = new Point_Ledger__c();
                pointLedgerRecord.Loyalty_Profile__c = order.Loyalty_Profile__c;
                pointLedgerRecord.Source__c = 'Order';
                pointLedgerRecord.Total_Points__c = order.Points_Redeemed__c;
                pointLedgerRecord.Transaction_Type__c = 'Redemption';
                pointLedgerRecords.add(pointLedgerRecord);
            }
            Point_Ledger__c pointLedgerRecord = new Point_Ledger__c();
            pointLedgerRecord.Loyalty_Profile__c = order.Loyalty_Profile__c;
            pointLedgerRecord.Source__c = 'Order';
            pointLedgerRecord.Total_Points__c = Decimal.valueOf(System.Label.Points_Accrual_Factor) * order.TotalAmount;
            pointLedgerRecord.Transaction_Type__c = 'Accrual';
            pointLedgerRecords.add(pointLedgerRecord);
        }

        try {
            Database.insert(pointLedgerRecords);
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            //Use Logger mechanism to log the error
        }
    }
}