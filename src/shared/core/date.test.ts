import { curDateStamp, fromDateStamp, getDateStampRange, getDurationTimestamp, getLedgerDateTimestamp, getNiceDate, getNiceDateTimestamp, getNow, toDateStamp } from './date';

// ******************************
// Tests:
// ******************************

describe('core', () => {
    describe('date', () => {
        it('get now', async () => {
            const now = await getNow();
            expect(now).toBeDefined();
            expect(now).toBeGreaterThan(0);
        });

        it('get current date stamp', async () => {
            const dateStamp = await curDateStamp();
            expect(dateStamp).toBeDefined();
            expect(dateStamp.length).toBeGreaterThan(0);
            expect(dateStamp).toMatch(/2[0-9]{3}-[01][0-9]-[0-3][0-9]/);
        });

        it('get duration timestamp for 0 seconds', async () => {
            const timeStamp = await getDurationTimestamp(0);
            expect(timeStamp).toEqual('00:00:00');
        });

        it('get duration timestamp for 30 seconds', async () => {
            const timeStamp = await getDurationTimestamp(30);
            expect(timeStamp).toEqual('00:00:30');
        });

        it('get duration timestamp for 70 seconds', async () => {
            const timeStamp = await getDurationTimestamp(70);
            expect(timeStamp).toEqual('00:01:10');
        });

        it('get duration timestamp for 70 minutes', async () => {
            const timeStamp = await getDurationTimestamp(4200);
            expect(timeStamp).toEqual('01:10:00');
        });

        it('get nice date timestamp', async () => {
            const timestamp = await getNiceDateTimestamp();
            expect(timestamp).toMatch(/[0-9]{2}:[0-9]{2}:[0-9]{2} [0-3][0-9]\/[01][0-9]\/2[0-9]{3}/);
        });

        it('get nice date timestamp for specified', async () => {
            const timestamp = await getNiceDateTimestamp(new Date('01 Jan 2000 12:00:00'));
            expect(timestamp).toEqual('12:00:00 01/01/2000');
        });

        it('get ledger date datestamp', async () => {
            const dateStamp = await getLedgerDateTimestamp();
            expect(dateStamp).toMatch(/2[0-9]{3}-[01][0-9]-[0-3][0-9] [0-9]{2}:[0-9]{2}:[0-9]{2}/);
        });

        it('get ledger date datestamp for specified', async () => {
            const dateStamp = await getLedgerDateTimestamp(new Date('01 Jan 2000 12:00:00'));
            expect(dateStamp).toEqual('2000-01-01 12:00:00');
        });

        it('get nice date datestamp', async () => {
            const dateStamp = await getNiceDate();
            expect(dateStamp).toMatch(/[0-3][0-9]\/[01][0-9]\/2[0-9]{3}/);
        });

        it('get nice date datestamp for specified', async () => {
            const dateStamp = await getNiceDate(new Date('01 Jan 2000 12:00:00'));
            expect(dateStamp).toEqual('01/01/2000');
        });

        it('get date datestamp range for no days', async () => {
            const ranges = await getDateStampRange(0);
            expect(ranges.length).toEqual(365);
        });

        it('get date datestamp range for 15 days', async () => {
            const ranges = await getDateStampRange(15);
            expect(ranges.length).toEqual(15);
        });

        it('to datestamp', async () => {
            const dateStamp = await toDateStamp();
            expect(dateStamp).toMatch(/2[0-9]{3}-[01][0-9]-[0-3][0-9]/);
        });

        it('to datestamp for specified', async () => {
            const dateStamp = await toDateStamp(new Date('01 Jan 2000 12:00:00'));
            expect(dateStamp).toEqual('2000-01-01');
        });

        it('from datestamp', async () => {
            const date = await fromDateStamp();
            expect(date).toBeDefined();
        });

        it('from datestamp for specified', async () => {
            const date = await fromDateStamp('2000-01-20T12:00:00.000Z');
            expect(date).toEqual(new Date('2000-01-20T12:00:00.000Z'));
        });
    });
});

// ******************************
