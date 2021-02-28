import { isPositiveInteger } from './number';

// ******************************
// Tests:
// ******************************

describe('core', () => {
    describe('number', () => {
        it(`isPositiveInteger`, () => expect(isPositiveInteger(0)).toEqual(true));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(213)).toEqual(true));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-123)).toEqual(false));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-0)).toEqual(true));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(1.1234)).toEqual(false));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(999999.0)).toEqual(true));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-0.0000234)).toEqual(false));
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-1234.1234)).toEqual(false));
    });
});

// ******************************
