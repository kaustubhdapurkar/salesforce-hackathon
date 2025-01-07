import { LightningElement, api, wire } from 'lwc';
import getProductReviews from '@salesforce/apex/ProductReviewController.getProductReviews';

export default class ProductReview extends LightningElement {

    @api productId
    isLoading = true;
    reviews = [];
    @wire(getProductReviews, { productId: '$productId' })
    getReviews({ data, error }) {
        if (data) {
            this.reviews = data.map(review => ({
                id: review.Id,
                title: review.Review_Title__c,
                description: review.Description__c,
                reviewer: review.Loyalty_Profile__r.Contact__r.Name
            }));
        } else if(error){
            console.error('Error fetching reviews:', error);
        }
        this.isLoading = false;
    }

}