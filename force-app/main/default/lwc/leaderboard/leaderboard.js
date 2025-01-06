import { LightningElement, wire } from 'lwc';
import getLeaderboard from '@salesforce/apex/RewardPointsService.getLeaderboard';
export default class Leaderboard extends LightningElement {

    leaderboard = [];
    @wire(getLeaderboard, {limit: 5})
    createLeaderboard({error, data}) {
        if(data) {

            console.log('leaderboard', data);
            this.leaderboard = data.map((record, index) => ({
                rank: index + 1,
                name: record.Contact__r.Name,
                points: record.Available_Points__c
            }));
        } else if(error) {
            console.error('Error while fetching leaderboard', error);
        }
    }
}