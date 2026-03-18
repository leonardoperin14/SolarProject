trigger SolarPlantTrigger on Solar_Plant__c (before insert, before update) {
    SolarPlantHandler handler = new SolarPlantHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            handler.calculateEstimatedProduction(Trigger.new);
        }
    }
}
