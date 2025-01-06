import { LightningElement, wire } from 'lwc';
import { getRecords } from 'lightning/uiRecordApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';

export default class ProductCatalog extends LightningElement {
    products;
    error;

    @wire(getRecords, { objectApiName: PRODUCT_OBJECT })
    wiredProducts({ error, data }) {
        if (data) {
            console.log('here');
            // Filter the data if needed, e.g., only show products of type 'Watch'
            this.products = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.products = undefined;
        }
    }
}