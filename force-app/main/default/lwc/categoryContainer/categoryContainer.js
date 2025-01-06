import { LightningElement } from 'lwc';

export default class CategoryContainer extends LightningElement {
    selectedFamily;

    connectedCallback(){
        this.selectedFamily = '';
    }

    handleFamilySelection(event) {
        this.selectedFamily = event.detail.family;
    }
}