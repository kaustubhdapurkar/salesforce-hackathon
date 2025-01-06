import { LightningElement, wire } from 'lwc';
import getCurrentUserRewardPointsData from '@salesforce/apex/RewardPointsService.getCurrentUserRewardPointsData';

export default class MyPoints extends LightningElement {

    rewardPoints;
    expiringPoints;
    expiryDate;
    @wire(getCurrentUserRewardPointsData)
    getRewardPoints({ error, data }) {
        if (data) {
            console.log('dataasdfa', data);
            this.rewardPoints = data?.loyaltyProfile?.Available_Points__c;
            this.expiringPoints = data?.expiringPoints?.Total_Points__c;
            let expiryDate = data?.expiringPoints?.Expiry_Date__c;
            const options = { day: 'numeric', month: 'short', year: '2-digit' };
            this.expiryDate = new Date(expiryDate).toLocaleDateString('en-GB', options).replace(/ /g, ' ').replace(/(\d{1,2}) (\w{3}) (\d{2})/, '$1 $2\'$3');
        } else if (error) {
            console.error('Error while fetching reward points', error);
        }
    }
}