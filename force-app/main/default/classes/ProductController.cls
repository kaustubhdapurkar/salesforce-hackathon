public with sharing class ProductController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String family) {
        if (String.isBlank(family)) {
            // Fetch all products if no family is provided
            return [
                SELECT Id, Name, Family, DisplayUrl, Description, 
                       (SELECT UnitPrice FROM PricebookEntries WHERE IsActive = TRUE LIMIT 1)
                FROM Product2
            ];
        } else {
            // Fetch products filtered by the given family
            return [
                SELECT Id, Name, Family, DisplayUrl, Description, 
                       (SELECT UnitPrice FROM PricebookEntries WHERE IsActive = TRUE LIMIT 1)
                FROM Product2
                WHERE Family = :family
            ];
        }
    }
}