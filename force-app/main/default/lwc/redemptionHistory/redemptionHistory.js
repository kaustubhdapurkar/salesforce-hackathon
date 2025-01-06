import { LightningElement, wire } from 'lwc';
import getRedemptionHistory from '@salesforce/apex/RewardPointsService.getRedemptionHistory';

export default class RedemptionHistory extends LightningElement {

    redemptionHistory = [];
    @wire(getRedemptionHistory)
    generateRedemptionHistory({error, data}) {
        if(data) {
            this.redemptionHistory = data.map(record => ({
                ...record,
                FormattedCreatedDate: new Date(record.CreatedDate).toLocaleString()
            }));
        } else if(error) {
            console.error('Error while fetching redemption history', error);
        }
    }
}