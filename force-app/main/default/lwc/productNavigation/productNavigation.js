import { LightningElement, wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';
import FAMILY_FIELD from '@salesforce/schema/Product2.Family';

export default class ProductNavigation extends LightningElement {
    @track productFamilies;
    selectedItem;

    // Get object metadata to retrieve the default RecordTypeId
    @wire(getObjectInfo, { objectApiName: PRODUCT2_OBJECT })
    product2Metadata;

    // Fetch picklist values for the Family field
    @wire(getPicklistValues, { 
        recordTypeId: '$product2Metadata.data.defaultRecordTypeId', 
        fieldApiName: FAMILY_FIELD 
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.productFamilies = data.values; // List of picklist values
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    handleSelection(event) {
        this.selectedItem = event.target.name;
        // Dispatch the selected family to the parent
        this.dispatchEvent(new CustomEvent('familyselect', {
            detail: { family: this.selectedItem }
        }));
    }
}