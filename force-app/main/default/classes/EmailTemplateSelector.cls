public inherited sharing class EmailTemplateSelector {
    public static List<EmailTemplate> getEmailTemplatesByNames(List<String> emailTemplateNames) {
        return [
            SELECT
                Id,
                Name
            FROM
                EmailTemplate
            WHERE
                Name IN :emailTemplateNames
        ];
    }
}