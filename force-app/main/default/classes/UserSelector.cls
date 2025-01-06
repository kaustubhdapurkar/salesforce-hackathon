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
}