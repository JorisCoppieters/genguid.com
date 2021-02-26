import { EntriesOptions } from './entries-options';

// ******************************
// Tests:
// ******************************

describe('shared', () => {
    describe('EntriesOptions', () => {
        it(`create empty`, () => {
            const options = new EntriesOptions();
            expect(options.keyField).toEqual('key');
            expect(options.valueField).toEqual('value');
        });
    });
});

// ******************************
