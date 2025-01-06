public inherited sharing class PointLedgerSelector {
    public static List<Point_Ledger__c> getPointLedgerByLoyaltyProfileId(String loyaltyProfileId) {
        return [
            SELECT
                Id,
                Transaction_Type__c,
                CreatedDate,
                Total_Points__c
            FROM
                Point_Ledger__c
            WHERE
                Loyalty_Profile__c = :loyaltyProfileId
            AND
                Transaction_Type__c = 'Redemption'
            AND 
                Total_Points__c > 0
            ORDER BY
                CreatedDate
            DESC 
        ];
    }

    public static Point_Ledger__c getLatestExpiringPointLedger(String loyaltyProfileId) {
        return [
            SELECT
                Id,
                Total_Points__c,
                Expiry_Date__c
            FROM
                Point_Ledger__c
            WHERE
                Expiry_Date__c > Today
            AND
                Transaction_Type__c = 'Accrual'
            AND
                Loyalty_Profile__c = :loyaltyProfileId
            ORDER BY
                Expiry_Date__c ASC
            LIMIT 1
        ] ?? null;
    }
}