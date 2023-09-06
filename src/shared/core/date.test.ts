import { getNow, getNowTime, isValidDate, setNow, toDateStamp, toDateTimeStamp, unsetNow } from './date';

// ******************************
// Tests:
// ******************************

describe('core', () => {
    describe('date', () => {
        it('get now', async () => {
            const now = await getNow();
            expect(now).toBeDefined();
            expect(now.getTime()).toBeGreaterThan(new Date(1990, 1, 1).getTime());
            expect(isValidDate(now)).toBeTruthy();
            // expect(extractValidDate(now, null)).not.toBeNull();
        });

        it('get now time', async () => {
            const nowTime = await getNowTime();
            expect(nowTime).toBeDefined();
            expect(nowTime).toBeGreaterThan(new Date(1990, 1, 1).getTime());
        });

        it('is valid', async () => {
            const date = new Date('asd');
            expect(date).toBeDefined();
            expect(isValidDate(date)).toBeFalsy();
            // expect(extractValidDate(date, null)).toBeNull();
        });

        it('set now', async () => {
            setNow(new Date(2000, 0, 1));
            const now = await getNow();
            expect(now).toBeDefined();
            expect(now.getTime()).toEqual(new Date(2000, 0, 1).getTime());
            expect(isValidDate(now)).toBeTruthy();
            unsetNow();
            const now2 = await getNow();
            expect(now2).toBeDefined();
            expect(now2.getTime()).toBeGreaterThan(new Date(2000, 0, 1).getTime());
            expect(isValidDate(now2)).toBeTruthy();
        });

        // it('get start of week for current date', async () => {
        //     const date = await startOfWeek();
        //     expect(date).toBeDefined();
        //     expect(date.getDay()).toEqual(1);
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 12/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('12 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 11/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('11 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 10/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('10 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 09/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('9 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 08/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('8 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 07/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('7 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 06/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('06 Jan 2020Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Jan 06 2020');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get start of week for 05/01/2020 date', async () => {
        //     const date = await startOfWeek(new Date('5 Jan 2020 12:00:00Z'));
        //     expect(date).toBeDefined();
        //     expect(date.toDateString()).toEqual('Mon Dec 30 2019');
        //     expect(isValidDate(date)).toBeTruthy();
        // });

        // it('get nice date datestamp', async () => {
        //     const dateStamp = await getNiceDate();
        //     expect(dateStamp).toMatch(/[0-3][0-9]\/[01][0-9]\/2[0-9]{3}/);
        // });

        // it('get nice date datestamp for specified', async () => {
        //     const dateStamp = await getNiceDate(new Date('01 Jan 2000 12:00:00Z'));
        //     expect(dateStamp).toEqual('01/01/2000');
        // });

        // it('get nice short year date datestamp', async () => {
        //     const dateStamp = await getNiceDate(undefined, true);
        //     expect(dateStamp).toMatch(/[0-3][0-9]\/[01][0-9]\/[0-9]{2}/);
        // });

        // it('get nice short year date datestamp for specified', async () => {
        //     const dateStamp = await getNiceDate(new Date('01 Jan 2000 12:00:00Z'), true);
        //     expect(dateStamp).toEqual('01/01/00');
        // });

        it('to dateStamp', async () => {
            const dateStamp = await toDateStamp();
            expect(dateStamp).toMatch(/2[0-9]{3}-[01][0-9]-[0-3][0-9]/);
        });

        it('to dateStamp for specified', async () => {
            const dateStamp = await toDateStamp(new Date('01 Jan 2000 12:00:00Z'));
            expect(dateStamp).toEqual('2000-01-01');
        });

        it('to datetimeStamp', async () => {
            const dateStamp = await toDateTimeStamp();
            expect(dateStamp).toMatch(/2[0-9]{3}-[01][0-9]-[0-3][0-9] [0-9]{2}:[0-9]{2}:[0-9]{2}/);
        });

        it('to datetimeStamp for specified', async () => {
            const dateStamp = await toDateTimeStamp(new Date('01 Jan 2000 12:00:00Z'));
            expect(dateStamp).toEqual('2000-01-01 12:00:00');
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
