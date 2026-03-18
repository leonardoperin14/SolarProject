public with sharing class InstallationHandler {
    
    public void validateInstallations(List<Installation__c> newInstallations) {
        Set<Id> solarPlantIds = new Set<Id>();
        Set<Date> installationDates = new Set<Date>();
        Set<String> technicianNames = new Set<String>();

        for (Installation__c inst : newInstallations) {
            // 1. Validação de Data Retroativa
            if (inst.Installation_Date__c != null && inst.Installation_Date__c < Date.today()) {
                inst.addError('Não é possível agendar uma instalação para uma data no passado.');
            }

            if (inst.Solar_Plant__c != null && inst.Installation_Date__c != null) {
                solarPlantIds.add(inst.Solar_Plant__c);
                installationDates.add(inst.Installation_Date__c);
                if (inst.Technician__c != null) technicianNames.add(inst.Technician__c);
            }
        }

        if (solarPlantIds.isEmpty()) return;

        // Query para verificar conflitos existentes
        List<Installation__c> existingInstallations = [
            SELECT Id, Solar_Plant__c, Installation_Date__c, Technician__c 
            FROM Installation__c 
            WHERE Installation_Date__c IN :installationDates
            AND (Solar_Plant__c IN :solarPlantIds OR Technician__c IN :technicianNames)
        ];

        // Mapas para busca rápida
        Map<String, Id> plantDateMap = new Map<String, Id>();
        Map<String, Id> techDateMap = new Map<String, Id>();

        for (Installation__c existing : existingInstallations) {
            String plantKey = (String)existing.Solar_Plant__c + existing.Installation_Date__c;
            String techKey = existing.Technician__c + existing.Installation_Date__c;
            
            plantDateMap.put(plantKey, existing.Id);
            if (existing.Technician__c != null) techDateMap.put(techKey, existing.Id);
        }

        // 2. Validação de Duplicatas e Conflito de Técnicos
        for (Installation__c inst : newInstallations) {
            String plantKey = (String)inst.Solar_Plant__c + inst.Installation_Date__c;
            String techKey = inst.Technician__c + inst.Installation_Date__c;

            // Evitar erro se o registro encontrado for o próprio registro que está sendo editado
            if (plantDateMap.containsKey(plantKey) && plantDateMap.get(plantKey) != inst.Id) {
                inst.addError('Já existe uma instalação agendada para esta Planta Solar nesta data.');
            }

            if (inst.Technician__c != null && techDateMap.containsKey(techKey) && techDateMap.get(techKey) != inst.Id) {
                inst.addError('O técnico ' + inst.Technician__c + ' já possui outra instalação agendada para este dia.');
            }
        }
    }

    /**
     * Mantemos o método anterior chamando a nova validação centralizada.
     */
    public void preventDuplicateInstallations(List<Installation__c> newInstallations) {
        validateInstallations(newInstallations);
    }
}
