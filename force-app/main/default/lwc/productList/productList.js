import { LightningElement, api, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';

export default class ProductList extends LightningElement {
    @api selectedFamily;
    @track products;

    @wire(getProducts, { family: '$selectedFamily' })
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data.map(product => ({
                ...product,
                DisplayUrl: product.DisplayUrl || '/sfc/servlet.shepherd/version/download/defaultImageId', 
                Description: product.Description || 'No description available',
                price: product.PricebookEntries.length > 0
                    ? product.PricebookEntries[0].UnitPrice
                    : 'Contact for Pricing'
            }));
        } else if (error) {
            console.error('Error fetching products:', error);
        }
    }

    handleBuyNow(event) {
        const productId = event.target.dataset.id;
        console.log('Redirecting to product:', productId);
        // Redirect to the checkout page with the productId in the URL parameter
        window.location.href = `/s/checkout?productId=${productId}`;
    }
}