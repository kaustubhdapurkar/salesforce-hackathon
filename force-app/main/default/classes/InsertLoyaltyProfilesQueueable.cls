/*
 * Asynchronous logic to create Loyalty Profile records for new community contacts. 
 * Reason for keeping this asynchronous code is because when a new communmity contact is created,
 * we are assigning permission set group to the user in the same transaction. Creating Loyalty Profile
 * record in the same transaction will result in mixed DML error.
 * When user logs in for the first time and the their Loyalty Profile is not yet created, show user a
 * screen on the community to ask them to come back in some time while we are processing their registration.
 * As soon as their Loyalty Profile is created, we can send them an email notification.
 */
public without sharing class InsertLoyaltyProfilesQueueable implements Queueable {
    private List<Contact> contacts;

    public InsertLoyaltyProfilesQueueable(List<Contact> contacts) {
        this.contacts = contacts;
    }

    public void execute(QueueableContext context) {
        List<Loyalty_Profile__c> loyaltyProfiles = new List<Loyalty_Profile__c>();

        for (Contact contact : contacts) {
            Loyalty_Profile__c loyaltyProfile = new Loyalty_Profile__c();
            loyaltyProfile.Contact__c = contact.Id;
            loyaltyProfile.Referral_Code__c = CustomerLoyaltyProgramUtil.generateReferralCode();
            loyaltyProfiles.add(loyaltyProfile);
        }

        if (!loyaltyProfiles.isEmpty()) {
            try {
                Database.insert(loyaltyProfiles);
            } catch (Exception e) {
                System.debug('Error inserting Loyalty Profiles: ' + e.getMessage());
                // Use logger mechanism to log these errors - Nebula Logger, etc.
                // Didn't implement because of time constraints.
            }
        }
    }
}