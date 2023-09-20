import { LightningElement , wire ,api, track} from 'lwc';
import getCases from '@salesforce/apex/CasesController.getCases';
import { subscribe} from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const columns = [
    { label: 'Subject', fieldName: 'Subject' },
    { label: 'Status', fieldName: 'Status' },
    { label: 'Contact Email', fieldName: 'contactemail' },
    {label: 'ContactTo',
            fieldName: 'contactlink',
            type: 'url',
            typeAttributes: {label: { fieldName: 'contactname' }, 
            target: '_blank'}
    },          
    {
        type: "button", label: 'View', initialWidth: 100, typeAttributes: {
            label: 'View',
            name: 'View',
            title: 'View',
            disabled: false,
            value: 'view',
            iconPosition: 'left',
            iconName:'utility:preview',
            variant:'Brand'
        }
    }    
];

export default class CasesTab extends LightningElement {
    columns = columns;
    @track data = [];
    caseId;
    openDetailView = false;
    subscription = {};
    @track wireResult =[];
    @api channelName = '/event/NewCaseEvent__e';

    connectedCallback() {        
        this.handleSubscribe();
        console.log('callback: ');
    }
    handleSubscribe() {
        const self = this;
        const messageCallback = function (response) {
                        
            var obj = JSON.parse(JSON.stringify(response));
            
            refreshApex(this.wireResult);            
            
        };
 
        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
    @wire(getCases)
    wiredCases(result) {
        this.wireResult = result;
        if (result.data) {
            this.data = JSON.parse(JSON.stringify(result.data));
            this.data.forEach(element => {
                
                element.contactlink = element.ContactId != null ? '/'+element.ContactId : '';
                element.contactname = element.Contact.Name;
                element.contactemail = element.Contact.Email;               
            });           
        } else if (result.error) {
            this.error = result.error;
        }
    }
    callRowAction(event) {
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;        
        this.caseId = recId;
        this.openDetailView = true;
    }
    handleClose(event){
        this.openDetailView = false;
    }
}