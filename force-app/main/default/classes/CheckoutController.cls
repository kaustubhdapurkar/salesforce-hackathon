public with sharing class CheckoutController {
    @AuraEnabled(cacheable=true)
    public static Product2 getProductDetails(String productId) {
        return [
            SELECT Id, Name, Description, DisplayUrl,
                   (SELECT UnitPrice FROM PricebookEntries WHERE IsActive = TRUE LIMIT 1)
            FROM Product2
            WHERE Id = :productId
        ];
    }

    @AuraEnabled
    public static Decimal applyVoucherCode(String voucherCode) {
        List<Voucher__c> voucherList = [SELECT Code__c,Discount__c,Discount_Type__c
        FROM Voucher__c 
        WHERE Code__c = :voucherCode AND Active__c = true LIMIT 1];
        if (!voucherList.isEmpty()) {
            return voucherList[0].Discount__c;
        } else {
            throw new AuraHandledException('Invalid voucher code.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getLoyaltyPoints() {
        // Fetch the user's loyalty points from the LoyaltyProfile__c object
        User currentUser = UserSelector.getUserById(UserInfo.getUserId());
    List<Loyalty_Profile__c> profiles = new List<Loyalty_Profile__c>{LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId)};
    /*
    List<Loyalty_Profile__c> profiles = [
            SELECT Available_Points__c FROM Loyalty_Profile__c WHERE OwnerId = :UserInfo.getUserId() LIMIT 1
        ];
        */
        if (profiles.isEmpty()) {
            return 0;
        }

        return profiles[0].Available_Points__c;
    }

    @AuraEnabled
public static Id createOrder(Map<String, Object> orderData) {
    String productId = (String) orderData.get('productId');
    List<PricebookEntry> pricebookEntries = [
        SELECT Id ,Pricebook2Id
        FROM PricebookEntry 
        WHERE Product2Id = :productId AND IsActive = TRUE 
        LIMIT 1
    ];

    if (pricebookEntries.isEmpty()) {
        throw new AuraHandledException('No active PricebookEntry found for the selected product.');
    }

    Id pricebookEntryId = pricebookEntries[0].Id;

    User currentUser = UserSelector.getUserById(UserInfo.getUserId());
    Loyalty_Profile__c profile = LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId);
    
    String voucherCode = (String) orderData.get('voucherCode');
    List<Voucher__c> voucherList = [SELECT Code__c,Discount__c,Discount_Type__c
        FROM Voucher__c 
        WHERE Code__c = :voucherCode AND Active__c = true LIMIT 1];

    // Create Order
    Order order = new Order(
        AccountId = '001dM00002FjVMIQA3',//UserInfo.getUserId(), 
        EffectiveDate = Date.today(),
        Status = 'Draft',
        BillingStreet = (String)orderData.get('deliveryAddress'),
        Pricebook2Id = pricebookEntries[0].Pricebook2Id, // Associate the Pricebook
        Loyalty_Profile__c = profile.Id,
        Voucher__c = !voucherList.isEmpty() ? voucherList[0].Id : null
    );
    insert order;

    // Create OrderItem
    OrderItem item = new OrderItem(
        OrderId = order.Id,
        PricebookEntryId = pricebookEntryId,
        Quantity = 1,
        Product2id = productId,
        UnitPrice = (Decimal)orderData.get('price')
        //ListPrice = (Decimal)orderData.get('price')
    );
    insert item;

    List<Point_Ledger__c> ledgerList = new List<Point_Ledger__c>();
    Decimal redeemedPoints = 0;
    if(orderData.get('redeemedPoints') != null) {
        redeemedPoints = Decimal.valueOf((String)orderData.get('redeemedPoints'));
    }
    Decimal price = (Decimal)orderData.get('price');
    if (redeemedPoints > 0) {
        /*
        Loyalty_Profile__c profile = [
            SELECT Available_Points__c FROM Loyalty_Profile__c WHERE OwnerId = :UserInfo.getUserId() LIMIT 1
        ];
        */
        Point_Ledger__c redemptionLedger = new Point_Ledger__c(
            Loyalty_Profile__c = profile.Id,
            Total_Points__c = redeemedPoints,//(Decimal)orderData.get('redeemedPoints'),
            Transaction_Type__c = 'Redemption',
            Source__c = 'Order'
        );
        ledgerList.add(redemptionLedger);
        //insert ledger;
    } 

    Decimal accrualFactor = Decimal.valueOf(System.Label.Points_Accrual_Factor);

    Point_Ledger__c accrualLedger = new Point_Ledger__c(
            Loyalty_Profile__c = profile.Id,
            Total_Points__c = Integer.valueOf(price*accrualFactor),//(Decimal)orderData.get('redeemedPoints'),
            Transaction_Type__c = 'Accrual',
            Source__c = 'Order'
        );
        ledgerList.add(accrualLedger);

    if (ledgerList.size() > 0) {
        insert ledgerList;
    }

    return order.Id;
}
}