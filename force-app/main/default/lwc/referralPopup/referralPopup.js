import { LightningElement, track } from 'lwc';
import getLoyaltyProfile from '@salesforce/apex/ReferralController.getLoyaltyProfile'; // New method to fetch loyalty profile
import validateReferralCode from '@salesforce/apex/ReferralController.validateReferralCode';
import updatePopupDisplayedFlag from '@salesforce/apex/ReferralController.updatePopupDisplayedFlag'; // Import Apex method to update the flag
import USER_ID from '@salesforce/user/Id';

export default class ReferralPopup extends LightningElement {
    @track showModal = '';// Controls the visibility of the modal
    @track referralCode = '';
    @track message = '';
    @track success = false;
    userId = USER_ID;

    connectedCallback() {
        // Check if the popup has already been displayed
        getLoyaltyProfile({ userId: this.userId })
            .then((result) => {
                console.log(
                    'Loyalty Profile: ' + JSON.stringify(result));
                if (result && !result.Was_Referral_Popup_Displayed__c) {
                    this.showModal = true; // Show the modal only if the flag is false
                }
            })
            .catch((error) => {
                console.error('Error fetching loyalty profile:', error);
            });
    }

    handleInputChange(event) {
        this.referralCode = event.target.value;
    }

    handleSubmit() {
        if (!this.referralCode) {
            alert('Please enter a referral code.');
            return;
        }
        console.log('Output :' +this.referralCode );
        // Call the Apex method to validate the referral code
        validateReferralCode({ code: this.referralCode , userId: this.userId})
            // .then((result) => {
            //     // Check if the referral code was valid and if the pop-up was already displayed
            //     if (result.success) {
            //         this.message = result.message;
            //         this.success = true; // Indicate success
            //         // Close the modal after successful referral
            //         this.showModal = false;
            //     } else {
            //         this.message = result.message;
            //         this.success = false; // Indicate failure
            //     }
            // })
            // .catch((error) => {
            //     console.error('Error:', error);
            //     this.message = 'An error occurred while processing your referral code.';
            //     this.success = false;
            // });
            .then((result) => {
                console.log('Referral Record is Created Successfully.');
                this.showModal = false;
            })
            .catch((error) => {
                console.error('Error while creating Referral Record.', error);
            });
    }

    closeModal() {
        this.showModal = false; // Close the modal when "Cancel" or "Close" is clicked
        updatePopupDisplayedFlag({ userId: this.userId })
            .then(() => {
                console.log('Popup displayed flag updated successfully');
            })
            .catch((error) => {
                console.error('Error updating popup displayed flag:', error);
            });
    }
    
}