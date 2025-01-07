public inherited sharing class UserSelector {
    public static User getUserById(String userId) {
        return [
            SELECT
                Id,
                ContactId
            FROM
                User
            WHERE
                Id = :userId
            LIMIT
                1
        ];
    }

    public static List<User> getCommunityUsersByContactIds(Set<Id> contactIds) {
        String customerLoyaltyProgramUserProfileName = System.Label.Customer_Loyalty_Program_User_Profile_Name;
        return [
            SELECT
                Id,
                ContactId,
                Profile.Name
            FROM
                User
            WHERE
                ContactId IN: contactIds
            AND
                Profile.Name =: customerLoyaltyProgramUserProfileName
        ];
    }

    public static List<User> getUsersByContactIds(Set<Id> contactIds) {
        return [
            SELECT
                Id,
                ContactId
            FROM
                User
            WHERE
                ContactId IN: contactIds
        ];
    }
}