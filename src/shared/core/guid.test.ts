import { generateGuid } from './guid';

// ******************************
// Tests:
// ******************************

describe('core', () => {
    describe('guid', () => {
        it(`generate`, () => expect(generateGuid()).toMatch(new RegExp(/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}/i)));
    });
});

// ******************************
