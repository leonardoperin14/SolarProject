import { LightningElement, wire, track } from 'lwc';
import getDailyInstallations from '@salesforce/apex/TechnicianDashboardController.getDailyInstallations';
import updateInstallationStatus from '@salesforce/apex/TechnicianDashboardController.updateInstallationStatus';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TechnicianDailyDashboard extends LightningElement {
    @track technicianName = '';
    
    @track processedInstallations;
    @track error;
    wiredInstallationsResult;
    
    @wire(getDailyInstallations, { technicianName: '$technicianName' })
    wiredInstallations(result) {
        this.wiredInstallationsResult = result;
        if (result.data) {
            this.processedInstallations = result.data.map(inst => {
                return {
                    ...inst,
                    isCompleted: inst.Status__c === 'Concluído',
                    statusClass: inst.Status__c === 'Concluído' ? 'slds-badge slds-theme_success' : 
                                 inst.Status__c === 'Em Andamento' ? 'slds-badge slds-theme_warning' : 'slds-badge'
                };
            });
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.processedInstallations = undefined;
        }
    }

    handleNameChange(event) {
        this.technicianName = event.target.value;
    }

    get hasInstallations() {
        return this.processedInstallations && this.processedInstallations.length > 0;
    }

    handleStatusUpdate(event) {
        const recordId = event.target.dataset.id;
        const newStatus = event.target.dataset.status;

        updateInstallationStatus({ recordId: recordId, status: newStatus })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: 'Status atualizado para ' + newStatus,
                        variant: 'success'
                    })
                );
                return refreshApex(this.wiredInstallationsResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro ao atualizar status',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
