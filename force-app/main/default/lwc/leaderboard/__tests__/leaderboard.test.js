import { createElement } from 'lwc';
import Leaderboard from 'c/leaderboard';
import getLeaderboard from '@salesforce/apex/RewardPointsService.getLeaderboard';

const mockGetLeaderboard = require('./data/getLeaderboard.json');

jest.mock(
    '@salesforce/apex/RewardPointsService.getLeaderboard',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-leaderboard', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('renders leaderboard data', () => {
        const element = createElement('c-leaderboard', {
            is: Leaderboard
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getLeaderboard.emit(mockGetLeaderboard);

        return Promise.resolve().then(() => {
            const rows = element.shadowRoot.querySelectorAll('tr');
            expect(rows.length).toBe(mockGetLeaderboard.length + 1); // Including header row
        });
    });

    it('renders error panel when there is an error', () => {
        const element = createElement('c-leaderboard', {
            is: Leaderboard
        });
        document.body.appendChild(element);

        // Emit error from @wire
        getLeaderboard.error();

        return Promise.resolve().then(() => {
            const errorPanel = element.shadowRoot.querySelector('.error');
            expect(errorPanel).not.toBeNull();
        });
    });

    it('renders no data message when no data is returned', () => {
        const element = createElement('c-leaderboard', {
            is: Leaderboard
        });
        document.body.appendChild(element);

        // Emit empty data from @wire
        getLeaderboard.emit([]);

        return Promise.resolve().then(() => {
            const noDataMessage = element.shadowRoot.querySelector('.no-data');
            expect(noDataMessage).not.toBeNull();
        });
    });
});