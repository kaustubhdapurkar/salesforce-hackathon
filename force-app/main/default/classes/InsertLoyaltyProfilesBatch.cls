/**
 * batch to create Loyalty Profile records for existing community contacts whose loyalty profile records don't exist.
 */

public without sharing class InsertLoyaltyProfilesBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id FROM Contact WHERE Id NOT IN (SELECT Contact__c FROM Loyalty_Profile__c)]);
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
        List<Loyalty_Profile__c> loyaltyProfiles = new List<Loyalty_Profile__c>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, User> contactIdToUserMap = new Map<Id, User>();
        for(Contact contactRecord : scope) {
            contactIds.add(contactRecord.Id);
        }

        for(User relatedUser : UserSelector.getCommunityUsersByContactIds(contactIds)) {
            contactIdToUserMap.put(relatedUser.ContactId, relatedUser);
        }

        for (Contact contact : scope) {
            if(!contactIdToUserMap.containsKey(contact.Id)) {
                continue;
            }
            Loyalty_Profile__c loyaltyProfile = new Loyalty_Profile__c();
            loyaltyProfile.Contact__c = contact.Id;
            loyaltyProfile.Referral_Code__c = CustomerLoyaltyProgramUtil.generateReferralCode();
            loyaltyProfiles.add(loyaltyProfile);
        }

        if (!loyaltyProfiles.isEmpty()) {
            try {
                Database.insert(loyaltyProfiles, false);
            } catch (Exception e) {
                System.debug('Error inserting Loyalty Profiles: ' + e.getMessage());
                // Use logger mechanism to log these errors - Nebula Logger, etc.
                // Didn't implement because of time constraints.
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Batch job finished.');
        // Send an email notification to the admin if needed
        // Also can use Database.SaveResult to log records that failed to insert
        // Didn't implement because of time constraints.
    }
}