import { LightningElement, track } from 'lwc';
import getProductDetails from '@salesforce/apex/CheckoutController.getProductDetails';
import getLoyaltyPoints from '@salesforce/apex/CheckoutController.getLoyaltyPoints';
import applyVoucherCode from '@salesforce/apex/CheckoutController.applyVoucherCode';
import createOrderRecord from '@salesforce/apex/CheckoutController.createOrder';

export default class CheckoutPage extends LightningElement {
    @track product = {};
    @track loyaltyPoints = 0;
    @track pointsToRedeem = 0;
    @track voucherCode = '';
    @track discountFromVoucher = 0;
    @track discountFromPoints = 0;
    @track voucherMessage = '';
    @track pointsMessage = '';
    @track deliveryAddress = '';
    @track finalPrice;

    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const productId = urlParams.get('productId');

        // Fetch product details
        getProductDetails({ productId })
            .then((result) => {
                this.product = {
                    ...result,
                    price: result.PricebookEntries[0]?.UnitPrice || 'N/A',
                };
                this.finalPrice = this.product.price;
            })
            .catch((error) => console.error('Error fetching product details:', error));

        // Fetch loyalty points
        getLoyaltyPoints()
            .then((points) => {
                this.loyaltyPoints = points;
            })
            .catch((error) => console.error('Error fetching loyalty points:', error));
    }

    handleVoucherChange(event) {
        this.voucherCode = event.target.value;
    }

    applyVoucher() {
        applyVoucherCode({ voucherCode: this.voucherCode })
            .then((discount) => {
                this.discountFromVoucher = discount;
                this.updateFinalPrice();
                this.voucherMessage = `Voucher applied! You saved $${discount}.`;
            })
            .catch((error) => {
                this.voucherMessage = 'Invalid voucher code.';
                console.error('Error applying voucher:', error);
            });
    }

    handlePointsChange(event) {
        this.pointsToRedeem = event.target.value;
    }

    redeemPoints() {
        if (this.pointsToRedeem > this.loyaltyPoints) {
            this.pointsMessage = 'You cannot redeem more points than you have!';
        } else {
            this.discountFromPoints = this.pointsToRedeem * 0.1; // Assume each point is worth $0.10
            this.updateFinalPrice();
            this.pointsMessage = `You redeemed ${this.pointsToRedeem} points for a discount of $${this.discountFromPoints.toFixed(
                2
            )}.`;
        }
    }

    updateFinalPrice() {
        this.finalPrice =
            this.product.price - this.discountFromVoucher - this.discountFromPoints;
    }

    handleAddressChange(event) {
        this.deliveryAddress = event.target.value;
    }

    createOrder() {
        console.log('his.pointsToRedeem--->'+this.pointsToRedeem);
        let orderData = {
            productId: this.product.Id,
            price: this.finalPrice,
            deliveryAddress: this.deliveryAddress,
            voucherCode: this.voucherCode,
            totalDiscount: this.discountFromVoucher + this.discountFromPoints,
        };
        if (this.pointsToRedeem) {
            orderData.redeemedPoints = this.pointsToRedeem;
        }
        createOrderRecord({ orderData })
            .then((orderId) => {
                window.location.href = `/s/orderconfirmation?orderId=${orderId}`;
            })
            .catch((error) => console.error('Error creating order:', error));
    }
}