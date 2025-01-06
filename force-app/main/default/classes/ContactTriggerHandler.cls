public without sharing class ContactTriggerHandler {
    
    public void onAfterInsert(Map<Id, Contact> newContactMap) {
        assignCustomerLoyaltyProgramPermissions(newContactMap);
        insertLoyaltyProfilesAsync(newContactMap.values());
    }

    /**
     * Assigns customer loyalty program permissions to new contacts.
     *
     * @param newContactMap A map of Contact Ids to Contact records representing the new contacts.
     */
    private static void assignCustomerLoyaltyProgramPermissions(Map<Id, Contact> newContactMap) {
        List<User> relatedUsers = new List<User>();
        PermissionSetGroup cLPPermissionSetGroup = new PermissionSetGroup();
        try {
            relatedUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN :newContactMap.keySet()];
            String permissionSetGroupName = System.Label.Customer_Loyalty_Program_Permission_Set_Group_Name;
            cLPPermissionSetGroup = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName  =: permissionSetGroupName LIMIT 1];
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>();
        for(User relatedUser : relatedUsers) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
            permissionSetAssignment.AssigneeId = relatedUser.Id;
            permissionSetAssignment.PermissionSetId = cLPPermissionSetGroup.Id;
            permissionAssignments.add(permissionSetAssignment);
        }

        try {
            if(!permissionAssignments.isEmpty()) {
                Database.insert(permissionAssignments, false);
            }
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    /**
     * Enqueues a Queueable job to insert Loyalty_Profile__c records for the given list of contacts.
     *
     * This method accepts a list of Contact records and enqueues a Queueable job that will create
     * corresponding Loyalty_Profile__c records for each contact. The job is processed asynchronously
     * to avoid the mixed DML error since we are also inserting PermissionSetAssignment records in the
     * same transaction.
     *
     * @param contacts List of Contact records for which Loyalty_Profile__c records need to be created.
     */
    private void insertLoyaltyProfilesAsync(List<Contact> contacts) {
        if (!contacts.isEmpty()) {
            System.enqueueJob(new InsertLoyaltyProfilesQueueable(contacts));
        }
    }
}