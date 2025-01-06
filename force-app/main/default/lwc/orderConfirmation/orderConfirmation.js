import { LightningElement, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class OrderConfirmation extends LightningElement {
    @track orderId;

    connectedCallback() {
        // Extract the orderId from the URL
        const urlParams = new URLSearchParams(window.location.search);
        this.orderId = urlParams.get('orderId');
    }

    navigateToHome() {
        // Redirect to the home page
        window.location.href = '/s/';
    }

    navigateToOrders() {
        // Redirect to the orders page
        window.location.href = '/s/my-orders';
    }
}