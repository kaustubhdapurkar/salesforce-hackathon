public with sharing class ReferralController {
    @AuraEnabled
    public static void validateReferralCode(String code , String userId) {
        try {
            // Fetch the Loyalty Profile for the entered referral code
            Loyalty_Profile__c loyaltyProfiles = LoyaltyProfileSelector.getLoyaltyProfileByReferralCode(code);
			
            // Check if the referral code exists
            if (loyaltyProfiles != null) {
                Loyalty_Profile__c referrer = loyaltyProfiles; // Get the matching loyalty profile
    			
                // Fetch the current user's Loyalty Profile
                User currentUser = UserSelector.getUserById(userId);
        		System.debug('Here2!');
                Loyalty_Profile__c currentUserProfile = LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId);
    
                // Create a Referral record
                Referral__c referral = new Referral__c(
                    Referrer__c = referrer.Id, // The user who owns the referral code
                    Referee__c = currentUserProfile.Id // The user who entered the referral code
                );
                Database.insert(referral);
                updatePopupDisplayedFlag(userId);            
            } else {
                throw new AuraHandledException('Invalid referral code. Please try again.');
            }
        } //catch (Exception ex) {
        //     throw new AuraHandledException('Error processing referral code: ' + ex.getMessage());
        //     //Use Logger mechanism to log the error
        // }
        catch (NullPointerException np) {
            throw new AuraHandledException('Error processing referral code: ' + np.getMessage());
        }
        catch (DmlException  dm) {
            throw new AuraHandledException('Error processing referral code: ' + dm.getMessage());
        }
        
    }

    @AuraEnabled
    public static void updatePopupDisplayedFlag(String userId) {
        try {
            User currentUser = UserSelector.getUserById(userId);

            Loyalty_Profile__c loyaltyProfile = LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId);
            
            // Update the was_popup_displayed field to true
            loyaltyProfile.Was_Referral_Popup_Displayed__c = true;

            // Update the record
            update loyaltyProfile; 
        } catch (Exception ex) {
            throw new AuraHandledException('Error updating the popup displayed flag: ' + ex.getMessage());
            //Use Logger mechanism to log the error
        }
    }

    @AuraEnabled
    public static Loyalty_Profile__c getLoyaltyProfile(String userId) {
        try {
            User currentUser = UserSelector.getUserById(userId);

            // Query the Customer Loyalty Profile for the current user
            Loyalty_Profile__c loyaltyProfile = LoyaltyProfileSelector.getLoyaltyProfileByContactId(currentUser.ContactId);

            return loyaltyProfile;
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching loyalty profile: ' + ex.getMessage());
            //Use Logger mechanism to log the error
        }
    }
}