public without sharing class PointLedgerTriggerHandler {

    private static final List<String> emailTemplateNames = new List<String> {
        System.Label.Order_Reward_Points_Credit_Email_Template,
        System.Label.Review_Submitted_Email_Template,
        System.Label.Successful_Referral_Email_Template
    };

    private static final Map<String, String> POINT_SOURCE_TO_EMAIL_TEMPLATE_MAP = new Map<String, String> {
        'Order' => System.Label.Order_Reward_Points_Credit_Email_Template,
        'Review' => System.Label.Review_Submitted_Email_Template,
        'Referral' => System.Label.Successful_Referral_Email_Template
    };
    
    public void onAfterInsert(List<Point_Ledger__c> newPointLedgers, Map<Id, Point_Ledger__c> newPointLedgersMap) {
        updatePointExpiryDateOnLoyaltyProfile(newPointLedgers);
        sendEmailNotification(newPointLedgers);
    }

    private static void updatePointExpiryDateOnLoyaltyProfile(List<Point_Ledger__c> newPointLedgers) {
        Set<Id> loyaltyProfileIds = new Set<Id>();
        for (Point_Ledger__c pointLedger : newPointLedgers) {
            if(pointLedger.Transaction_Type__c == 'Accrual') {
                loyaltyProfileIds.add(pointLedger.Loyalty_Profile__c);
            }
        }

        List<Loyalty_Profile__c> loyaltyProfiles = new List<Loyalty_Profile__c>();
        try {
            loyaltyProfiles = LoyaltyProfileSelector.getLoyaltyProfilesByIds(loyaltyProfileIds);
        } catch(QueryException e) {
            System.debug('Error: ' + e.getMessage());
        }


        for (Loyalty_Profile__c loyaltyProfile : loyaltyProfiles) {
            loyaltyProfile.Reward_Points_Expiry_Date__c = Date.today().addMonths(6);
        }

        try {
            if(!loyaltyProfiles.isEmpty()) {
                Database.update(loyaltyProfiles);
            }
        } catch(DmlException e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

    public static void sendEmailNotification(List<Point_Ledger__c> newPointLedgers) {
        Map<Id, String> loyaltyProfileIdToPointSourceMap = new Map<Id, String>();
        Map<Id, String> contactIdToPointSourceMap = new Map<Id, String>();
        Map<String, Id> sourceToEmailTemplateMap = new Map<String, Id>();
        for(Point_Ledger__c pointLedger : newPointLedgers) {
            if(pointLedger.Transaction_Type__c == 'Accrual') {
                loyaltyProfileIdToPointSourceMap.put(pointLedger.Loyalty_Profile__c, pointLedger.Source__c);
            }
        }

        List<Loyalty_Profile__c> loyaltyProfiles = LoyaltyProfileSelector.getLoyaltyProfilesByIds(loyaltyProfileIdToPointSourceMap.keySet());
        for(Loyalty_Profile__c loyaltyProfile : loyaltyProfiles) {
            contactIdToPointSourceMap.put(loyaltyProfile.Contact__c, loyaltyProfileIdToPointSourceMap.get(loyaltyProfile.Id));
        }

        for(EmailTemplate template : EmailTemplateSelector.getEmailTemplatesByNames(emailTemplateNames)) {
            sourceToEmailTemplateMap.put(template.Name, template.Id);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(String contactId : contactIdToPointSourceMap.keySet()) {
            String source = contactIdToPointSourceMap.get(contactId);
            String emailTemplateName = POINT_SOURCE_TO_EMAIL_TEMPLATE_MAP.get(source);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(sourceToEmailTemplateMap.get(emailTemplateName));
            email.setTargetObjectId(contactId); // Sending emails to contacts doesn't consume the daily Single Email Message limit
            email.setSaveAsActivity(false);
            emails.add(email);
        }

        try {
            if(!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        } catch (EmailException e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}