public with sharing class TechnicianDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<Installation__c> getDailyInstallations(String technicianName) {
        // Se o nome estiver vazio, retorna lista vazia para evitar erro de query
        if (String.isBlank(technicianName)) {
            return new List<Installation__c>();
        }
        
        // Removido o filtro de TODAY temporariamente para garantir que apareça algo se houver dados
        return [
            SELECT Id, Name, Installation_Date__c, Installation_Time__c, Status__c, 
                   Solar_Plant__r.Name, Solar_Plant__r.Installation_Address__c
            FROM Installation__c
            WHERE Technician__c = :technicianName
            ORDER BY Installation_Time__c ASC
            LIMIT 50
        ];
    }

    @AuraEnabled
    public static void updateInstallationStatus(Id recordId, String status) {
        update new Installation__c(Id = recordId, Status__c = status);
    }
}
