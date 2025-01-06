public with sharing class ReferralController {
    @AuraEnabled
    public static void validateReferralCode(String code , String userId) {
        try {
            // Fetch the Loyalty Profile for the entered referral code
            List<Loyalty_Profile__c> loyaltyProfiles = [
                SELECT Id, Referral_Code__c 
                FROM Loyalty_Profile__c 
                WHERE Referral_Code__c = :code
                LIMIT 1
            ];
    
            // Check if the referral code exists
            if (!loyaltyProfiles.isEmpty()) {
                Loyalty_Profile__c referrer = loyaltyProfiles[0]; // Get the matching loyalty profile
    
                // Fetch the current user's Loyalty Profile
                User currentUser = [
                    SELECT Id, ContactId 
                    FROM User 
                    WHERE Id = :userId
                    LIMIT 1
                ];
    
                Loyalty_Profile__c currentUserProfile = [
                    SELECT Id 
                    FROM Loyalty_Profile__c 
                    WHERE Contact__c = :currentUser.ContactId
                    LIMIT 1
                ];
    
                // Create a Referral record
                Referral__c referral = new Referral__c(
                    Referrer__c = referrer.Id, // The user who owns the referral code
                    Referee__c = currentUserProfile.Id // The user who entered the referral code
                    //Referral_Code__c = code
                );
                insert referral;
                updatePopupDisplayedFlag(userId);            
            } else {
                throw new AuraHandledException('Invalid referral code. Please try again.');
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error processing referral code: ' + ex.getMessage());
        }
        
    }

    @AuraEnabled
    public static void updatePopupDisplayedFlag(String userId) {
        try {
            User currentUser = [
                SELECT Id, contactId 
                FROM User 
                WHERE Id = :userId 
                LIMIT 1
            ];
            // Query the Customer Loyalty Profile for the current user

            Loyalty_Profile__c loyaltyProfile = [
                SELECT Id, Was_Referral_Popup_Displayed__c 
                FROM Loyalty_Profile__c 
                WHERE Contact__c = :currentUser.contactId
                LIMIT 1
            ];
            
            // Update the was_popup_displayed field to true
            loyaltyProfile.Was_Referral_Popup_Displayed__c = true;

            // Update the record
            update loyaltyProfile; 
        } catch (Exception ex) {
            throw new AuraHandledException('Error updating the popup displayed flag: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static Loyalty_Profile__c getLoyaltyProfile(String userId) {
        try {
            User currentUser = [
                SELECT Id, ContactId 
                FROM User 
                WHERE Id = :userId 
                LIMIT 1
            ];

            // Query the Customer Loyalty Profile for the current user
            Loyalty_Profile__c loyaltyProfile = [
                SELECT Id, Was_Referral_Popup_Displayed__c 
                FROM Loyalty_Profile__c 
                WHERE Contact__c = :currentUser.ContactId 
                LIMIT 1
            ];

            return loyaltyProfile;
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching loyalty profile: ' + ex.getMessage());
        }
    }
}