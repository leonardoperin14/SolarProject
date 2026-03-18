public with sharing class SolarPlantHandler {
    
    /**
     * Calcula a Produção Estimada com base na Capacidade, Número de Painéis e um Fator de Eficiência (1.2).
     */
    public void calculateEstimatedProduction(List<Solar_Plant__c> plants) {
        Decimal efficiencyFactor = 1.2;

        for (Solar_Plant__c plant : plants) {
            if (plant.Capacity_kWp__c != null && plant.Number_of_Panels__c != null) {
                // Lógica: Produção = Capacidade * Número de Painéis * Fator de Eficiência
                plant.Estimated_Production__c = plant.Capacity_kWp__c * plant.Number_of_Panels__c * efficiencyFactor;
            } else {
                plant.Estimated_Production__c = 0;
            }
        }
    }
}
