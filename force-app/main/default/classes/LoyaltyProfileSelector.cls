public inherited sharing class LoyaltyProfileSelector {
   public static Loyalty_Profile__c getLoyaltyProfileByContactId(
     String contactId
   ) {
     return [
         SELECT
            Id,
            Name,
            Contact__c,
            Available_Points__c,
            Reward_Points_Expiry_Date__c,
            Was_Referral_Popup_Displayed__c
         FROM
            Loyalty_Profile__c
         WHERE
            Contact__c = :contactId
         LIMIT 1
     ];
   }

   public static List<Loyalty_Profile__c> getLoyaltyProfilesByIds(
     Set<Id> loyaltyProfileIds
   ) {
     return [
         SELECT
            Id,
            Reward_Points_Expiry_Date__c,
            Contact__c
         FROM
            Loyalty_Profile__c
         WHERE
            Id IN :loyaltyProfileIds
     ];
   }

   public static List<Loyalty_Profile__c> getTopProfilesByRewarPoints(
     Integer recordLimit
   ) {
     return [
         SELECT
            Id,
            Name,
            Contact__c,
            Contact__r.Name,
            Available_Points__c
         FROM
            Loyalty_Profile__c
         ORDER BY
            Available_Points__c DESC
         LIMIT :recordLimit
     ];
   }

   public static Loyalty_Profile__c getLoyaltyProfileByReferralCode(
     String referralCode
   ) {
     return [
      SELECT 
         Id, 
         Referral_Code__c 
      FROM 
         Loyalty_Profile__c 
      WHERE 
         Referral_Code__c = :referralCode
      LIMIT 1
     ];
   }

 }