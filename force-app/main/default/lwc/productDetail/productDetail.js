import { LightningElement, track } from 'lwc';
import getProductDetails from '@salesforce/apex/CheckoutController.getProductDetails';
import getCustomerReviewDetails from '@salesforce/apex/ProductDetailController.getCustomerReviewDetails';
import { createRecord } from 'lightning/uiRecordApi';
import REVIEW_OBJECT from "@salesforce/schema/Customer_Review__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Customer_Review__c.Description__c";
import REVIEW_TITLE_FIELD from "@salesforce/schema/Customer_Review__c.Review_Title__c";
import LOYALTY_PROFILE_FIELD from "@salesforce/schema/Customer_Review__c.Loyalty_Profile__c";
import getLoyaltyProfileId from '@salesforce/apex/ProductDetailController.getLoyaltyProfileId';
import PRODUCT_FIELD from "@salesforce/schema/Customer_Review__c.Product__c";

export default class ProductDetail extends LightningElement {

    reviewTitle = '';
    reviewDescription = '';
    hasUserAlreadyReviewed = true;
    finalPrice;
    reviewSubmissionError = false;
    @track product = {};
    isVerifiedBuyer = false;

    get canTheUserSubmitReview() {
        console.log(
            'hasUserAlreadyReviewed: ' + this.hasUserAlreadyReviewed + ', isVerifiedBuyer:' + this.isVerifiedBuyer)
        return !this.hasUserAlreadyReviewed && this.isVerifiedBuyer;
    }

    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const productId = urlParams.get('productId');

        getProductDetails({ productId })
            .then((result) => {
                this.product = {
                    ...result,
                    price: result.PricebookEntries[0]?.UnitPrice || 'N/A',
                };
                this.finalPrice = this.product.price;
            })
            .catch((error) => console.error('Error fetching product details:', error));

        getCustomerReviewDetails({ productId })
            .then((result) => {
                this.isVerifiedBuyer = result.isUserVerifiedBuyer;
                this.hasUserAlreadyReviewed = result.hasUserAlreadyReviewed;
            })
            .catch((error) => console.error('Error fetching is verified buyer:', error));
    }

    async submitReview() {
        let loyaltyProfileId = await getLoyaltyProfileId();
        this.reviewSubmissionError = this.reviewTitle == '' || this.reviewDescription == '';
        if(this.reviewSubmissionError) {
            return;
        }
        const fields = {};
        fields[DESCRIPTION_FIELD.fieldApiName] = this.reviewDescription;
        fields[REVIEW_TITLE_FIELD.fieldApiName] = this.reviewTitle;
        fields[LOYALTY_PROFILE_FIELD.fieldApiName] = loyaltyProfileId;
        fields[PRODUCT_FIELD.fieldApiName] = this.product.Id
        const recordInput = { apiName: REVIEW_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                console.log('successss');
            })
            .catch(error => {
                console.error('Error creating review:', error);
                this.reviewSubmissionError = true;

            });
    }

    handleReviewChange(event) {
        if(event.target.dataset.field === 'title') {
            this.reviewTitle = event.target.value;
            console.log(this.reviewTitle);
        } else if(event.target.dataset.field === 'description') {
            this.reviewDescription = event.target.value;
            console.log(this.reviewDescription);
        }

        console.log(this.reviewTitle);
        console.log(this.reviewDescription);
    }
}