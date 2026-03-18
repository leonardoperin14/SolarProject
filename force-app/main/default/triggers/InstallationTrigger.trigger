trigger InstallationTrigger on Installation__c (before insert, before update) {
    InstallationHandler handler = new InstallationHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            handler.preventDuplicateInstallations(Trigger.new);
        }
    }
}
