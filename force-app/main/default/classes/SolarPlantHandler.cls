public with sharing class SolarPlantHandler {
    
    /**
     * Calcula a Produção Estimada automaticamente.
     * Agora, o usuário não precisa digitar a produção; ela é baseada na capacidade e número de painéis.
     * Fórmula: Capacidade (kWp) * Número de Painéis * 150 (Fator de produtividade média mensal).
     */
    public void calculateEstimatedProduction(List<Solar_Plant__c> plants) {
        Decimal monthlyFactor = 150.0; // Fator médio de produção em kWh por kWp

        for (Solar_Plant__c plant : plants) {
            if (plant.Capacity_kWp__c != null && plant.Number_of_Panels__c != null) {
                // Cálculo automático: Capacidade individual do painel * Quantidade * Fator mensal
                plant.Estimated_Production__c = plant.Capacity_kWp__c * plant.Number_of_Panels__c * monthlyFactor;
            } else {
                plant.Estimated_Production__c = 0;
            }
        }
    }
}
