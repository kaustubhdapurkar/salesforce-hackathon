public with sharing class RewardPointsService {
    
    @AuraEnabled(cacheable=true)
    public static MyPointsWrapper getCurrentUserRewardPointsData() {
        User currentUser = UserSelector.getUserById(UserInfo.getUserId());
        Loyalty_Profile__c loyaltyProfile = LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId);
        MyPointsWrapper wrapper = new MyPointsWrapper();
        wrapper.expiringPoints = getLatestExpiringPoints(loyaltyProfile);
        wrapper.loyaltyProfile = loyaltyProfile;
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<Loyalty_Profile__c> getLeaderboard() {
        List<Loyalty_Profile__c> loyaltyProfiles = LoyaltyProfileSelector.getTopProfilesByRewarPoints(5);
        return loyaltyProfiles;
    }

    @AuraEnabled(cacheable=true)
    public static List<Point_Ledger__c> getRedemptionHistory() {
        User currentUser = UserSelector.getUserById(UserInfo.getUserId());
        Loyalty_Profile__c loyaltyProfile = LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId);
        List<Point_Ledger__c> pointLedger = PointLedgerSelector.getPointLedgerByLoyaltyProfileId(loyaltyProfile.Id);
        return pointLedger;
    }

    private static Point_Ledger__c getLatestExpiringPoints(Loyalty_Profile__c loyaltyProfile) {
        Point_Ledger__c pointLedger = PointLedgerSelector.getLatestExpiringPointLedger(loyaltyProfile.Id);
        return pointLedger;
    }

    public class MyPointsWrapper {
        @AuraEnabled
        public Loyalty_Profile__c loyaltyProfile {get; set;}
        @AuraEnabled
        public Point_Ledger__c expiringPoints {get; set;}
    }
}