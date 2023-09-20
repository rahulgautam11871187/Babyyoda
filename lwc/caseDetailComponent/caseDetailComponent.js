import { LightningElement , api, wire , track } from 'lwc';
import getCaseFieldset from '@salesforce/apex/CasesController.getCaseFieldset';
import checkStatus from '@salesforce/apex/BabyYodaLocationIntegration.getLocation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CaseDetailComponent extends LightningElement {
    @api recordId;
    lstFields = [];
    
    connectedCallback() {
        this.handleLoad();
    }
    handleLoad() {
        getCaseFieldset({caseId:this.recordId})
        .then((result) => {
            console.log("result=="+JSON.stringify(result));
            this.lstFields = result;            
            
        })
        .catch((error) => {
            console.log("error=="+JSON.stringify(error));
            this.error = error;
        });
    }
    hideModalBox(){
        this.dispatchEvent(new CustomEvent("closeevent"));
    }
    handleScanClick(){
        checkStatus({caseId:this.recordId})
        .then((result) => {            
            let title = result.success ? 'Success' : 'Error';
            let variant = result.success ? 'success' : 'error';            
            this.showNotification(title,result.message,variant);                                             
        })
        .catch((error) => {
            console.log("error=="+JSON.stringify(error));
            this.error = error;
        });
    }
    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        });
        this.dispatchEvent(evt);
  }
}