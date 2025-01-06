public class InsertLoyaltyProfilesBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        // Query to select all contacts
        return Database.getQueryLocator([SELECT Id, FirstName, LastName, Email FROM Contact]);
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
        List<Loyalty_Profile__c> loyaltyProfiles = new List<Loyalty_Profile__c>();

        for (Contact contact : scope) {
            Loyalty_Profile__c loyaltyProfile = new Loyalty_Profile__c();
            loyaltyProfile.Contact__c = contact.Id;
            loyaltyProfile.Referral_Code__c = generateReferralCode();
            loyaltyProfiles.add(loyaltyProfile);
        }

        if (!loyaltyProfiles.isEmpty()) {
            try {
                Database.insert(loyaltyProfiles);
            } catch (Exception e) {
                System.debug('Error inserting Loyalty Profiles: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Batch job finished.');
    }

    /**
     * Generates a random unique 8-character alphanumeric referral code.
     *
     * @return A random unique 8-character alphanumeric string.
     */
    private String generateReferralCode() {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String referralCode = '';
        Integer length = 8;
        for (Integer i = 0; i < length; i++) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            referralCode += chars.substring(idx, idx + 1);
        }
        return referralCode;
    }
}