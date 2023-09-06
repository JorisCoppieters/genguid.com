import { bankersRound, dollarRound, isPositiveInteger } from './number';

// ******************************
// Tests:
// ******************************

describe('core', () => {
    describe('number', () => {
        it(`isPositiveInteger`, () => expect(isPositiveInteger(0)).toBeTruthy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(213)).toBeTruthy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-123)).toBeFalsy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-0)).toBeTruthy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(1.1234)).toBeFalsy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(999999.0)).toBeTruthy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-0.0000234)).toBeFalsy());
        it(`isPositiveInteger`, () => expect(isPositiveInteger(-1234.1234)).toBeFalsy());

        // it(`isPositiveReal`, () => expect(isPositiveReal(0)).toBeTruthy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(213)).toBeTruthy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(-123)).toBeFalsy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(-0)).toBeTruthy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(1.1234)).toBeTruthy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(999999.0)).toBeTruthy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(-0.0000234)).toBeFalsy());
        // it(`isPositiveReal`, () => expect(isPositiveReal(-1234.1234)).toBeFalsy());

        describe('bankersRound', () => {
            it(`0`, () => expect(bankersRound(0)).toEqual(0));
            it(`0.01`, () => expect(bankersRound(0.01)).toEqual(0.01));
            it(`0.001`, () => expect(bankersRound(0.001)).toEqual(0));
            it(`0.009`, () => expect(bankersRound(0.009)).toEqual(0.01));
            it(`1000.123`, () => expect(bankersRound(1000.123)).toEqual(1000.12));
            it(`-40.40`, () => expect(bankersRound(-40.4)).toEqual(-40.4));
            it(`-23.401`, () => expect(bankersRound(-23.401)).toEqual(-23.4));
            it(`-23.409`, () => expect(bankersRound(-23.409)).toEqual(-23.41));
            it(`1.525`, () => expect(bankersRound(1.525)).toEqual(1.52));
            it(`1.535`, () => expect(bankersRound(1.535)).toEqual(1.54));
            it(`12.245`, () => expect(bankersRound(12.245)).toEqual(12.24));
            it(`12.255`, () => expect(bankersRound(12.255)).toEqual(12.26));
        });

        describe('dollarRound', () => {
            it(`0`, () => expect(dollarRound(0)).toEqual(0));
            it(`0.01`, () => expect(dollarRound(0.01)).toEqual(0));
            it(`0.994`, () => expect(dollarRound(0.994)).toEqual(0));
            it(`0.995`, () => expect(dollarRound(0.995)).toEqual(1));
            it(`0.999`, () => expect(dollarRound(0.999)).toEqual(1));
            it(`-0.994`, () => expect(dollarRound(-0.994)).toEqual(0));
            it(`-0.995`, () => expect(dollarRound(-0.995)).toEqual(-1));
            it(`-0.999`, () => expect(dollarRound(-0.999)).toEqual(-1));
            it(`1000.123`, () => expect(dollarRound(1000.123)).toEqual(1000));
            it(`-40.40`, () => expect(dollarRound(-40.4)).toEqual(-40));
            it(`1.525`, () => expect(dollarRound(1.525)).toEqual(1));
            it(`12.245`, () => expect(dollarRound(12.245)).toEqual(12));
            it(`12.999`, () => expect(dollarRound(12.999)).toEqual(13));
        });

        // describe('bankersDiff', () => {
        //     it(`0, 0`, () => expect(bankersDiff(0, 0)).toEqual(0));
        //     it(`0, 0.01`, () => expect(bankersDiff(0, 0.01)).toEqual(0.01));
        //     it(`0, 0.001`, () => expect(bankersDiff(0, 0.001)).toEqual(0));
        //     it(`0, 0.994`, () => expect(bankersDiff(0, 0.994)).toEqual(0.99));
        //     it(`0, 0.995`, () => expect(bankersDiff(0, 0.995)).toEqual(1));
        //     it(`0, 0.999`, () => expect(bankersDiff(0, 0.999)).toEqual(1));
        //     it(`0, -0.994`, () => expect(bankersDiff(0, -0.994)).toEqual(-0.99));
        //     it(`0, -0.995`, () => expect(bankersDiff(0, -0.995)).toEqual(-1));
        //     it(`0, -0.999`, () => expect(bankersDiff(0, -0.999)).toEqual(-1));
        //     it(`0, 1000.123`, () => expect(bankersDiff(0, 1000.123)).toEqual(1000.12));
        //     it(`0, -40.40`, () => expect(bankersDiff(0, -40.4)).toEqual(-40.4));
        //     it(`0, 1.525`, () => expect(bankersDiff(0, 1.525)).toEqual(1.52));
        //     it(`0, 12.245`, () => expect(bankersDiff(0, 12.245)).toEqual(12.24));
        //     it(`0, 12.999`, () => expect(bankersDiff(0, 12.999)).toEqual(13));
        // });
    });
});

// ******************************
