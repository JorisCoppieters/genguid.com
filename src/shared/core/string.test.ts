import { centerPad, fromCurrencyString, fromPercentageString, leftPad, rightPad, toCamelCase, toKebabCase, toPascalCase, toTitleCase, trimObject } from './string';

// ******************************
// Tests:
// ******************************

describe('core', () => {
    describe('string', () => {
        it(`toTitleCase`, () => expect(toTitleCase('')).toEqual(''));
        it(`toTitleCase`, () => expect(toTitleCase('abc')).toEqual('Abc'));
        it(`toTitleCase`, () => expect(toTitleCase('abc-def')).toEqual('Abc Def'));
        it(`toTitleCase`, () => expect(toTitleCase('a-b-c')).toEqual('A B C'));
        it(`toTitleCase`, () => expect(toTitleCase('Abc')).toEqual('Abc'));
        it(`toTitleCase`, () => expect(toTitleCase('AbcDef')).toEqual('Abc Def'));
        it(`toTitleCase`, () => expect(toTitleCase('ABC')).toEqual('A B C'));

        it(`toPascalCase`, () => expect(toPascalCase('')).toEqual(''));
        it(`toPascalCase`, () => expect(toPascalCase('abc')).toEqual('Abc'));
        it(`toPascalCase`, () => expect(toPascalCase('abc-def')).toEqual('AbcDef'));
        it(`toPascalCase`, () => expect(toPascalCase('a-b-c')).toEqual('ABC'));
        it(`toPascalCase`, () => expect(toPascalCase('Abc')).toEqual('Abc'));
        it(`toPascalCase`, () => expect(toPascalCase('AbcDef')).toEqual('AbcDef'));
        it(`toPascalCase`, () => expect(toPascalCase('ABC')).toEqual('ABC'));

        it(`toCamelCase`, () => expect(toCamelCase('')).toEqual(''));
        it(`toCamelCase`, () => expect(toCamelCase('abc')).toEqual('abc'));
        it(`toCamelCase`, () => expect(toCamelCase('abc-def')).toEqual('abcDef'));
        it(`toCamelCase`, () => expect(toCamelCase('a-b-c')).toEqual('aBC'));
        it(`toCamelCase`, () => expect(toCamelCase('Abc')).toEqual('abc'));
        it(`toCamelCase`, () => expect(toCamelCase('AbcDef')).toEqual('abcDef'));
        it(`toCamelCase`, () => expect(toCamelCase('ABC')).toEqual('aBC'));

        it(`toKebabCase`, () => expect(toKebabCase('')).toEqual(''));
        it(`toKebabCase`, () => expect(toKebabCase('abc')).toEqual('abc'));
        it(`toKebabCase`, () => expect(toKebabCase('abc-def')).toEqual('abc-def'));
        it(`toKebabCase`, () => expect(toKebabCase('a-b-c')).toEqual('a-b-c'));
        it(`toKebabCase`, () => expect(toKebabCase('Abc')).toEqual('abc'));
        it(`toKebabCase`, () => expect(toKebabCase('AbcDef')).toEqual('abc-def'));
        it(`toKebabCase`, () => expect(toKebabCase('ABC')).toEqual('a-b-c'));

        it(`leftPad`, () => expect(leftPad('', '', 0)).toEqual(''));
        it(`leftPad`, () => expect(leftPad('abc', '', 0)).toEqual('abc'));
        it(`leftPad`, () => expect(leftPad('abc', 'x', 0)).toEqual('abc'));
        it(`leftPad`, () => expect(leftPad('abc', 'x', 1)).toEqual('abc'));
        it(`leftPad`, () => expect(leftPad('abc', 'x', 5)).toEqual('xxabc'));
        it(`leftPad`, () => expect(() => leftPad('abc', '==', 5)).toThrowError('Pad should be one character'));
        it(`leftPad`, () => expect(leftPad('', 'x', 5)).toEqual('xxxxx'));

        it(`rightPad`, () => expect(rightPad('', '', 0)).toEqual(''));
        it(`rightPad`, () => expect(rightPad('abc', '', 0)).toEqual('abc'));
        it(`rightPad`, () => expect(rightPad('abc', 'x', 0)).toEqual('abc'));
        it(`rightPad`, () => expect(rightPad('abc', 'x', 1)).toEqual('abc'));
        it(`rightPad`, () => expect(rightPad('abc', 'x', 5)).toEqual('abcxx'));
        it(`rightPad`, () => expect(() => rightPad('abc', '==', 5)).toThrowError('Pad should be one character'));
        it(`rightPad`, () => expect(rightPad('', 'x', 5)).toEqual('xxxxx'));

        it(`centerPad`, () => expect(centerPad('', '', 0)).toEqual(''));
        it(`centerPad`, () => expect(centerPad('abc', '', 0)).toEqual('abc'));
        it(`centerPad`, () => expect(centerPad('abc', 'x', 0)).toEqual('abc'));
        it(`centerPad`, () => expect(centerPad('abc', 'x', 1)).toEqual('abc'));
        it(`centerPad`, () => expect(centerPad('abc', 'x', 5)).toEqual('xabcx'));
        it(`centerPad`, () => expect(() => centerPad('abc', '==', 7)).toThrowError('Pad should be one character'));
        it(`centerPad`, () => expect(centerPad('', 'x', 5)).toEqual('xxxxx'));

        it(`trimObject`, () => expect(trimObject('')).toEqual(''));
        it(`trimObject`, () => expect(trimObject(123)).toEqual(123));
        it(`trimObject`, () => expect(trimObject(new Date('1 January 2020'))).toEqual(new Date('1 January 2020').toString()));
        it(`trimObject`, () => expect(trimObject([])).toEqual([]));
        it(`trimObject`, () => expect(trimObject({})).toEqual({}));
        it(`trimObject`, () => expect(trimObject(['a', 'b', 'c'])).toEqual(['a', 'b', 'c']));

        it(`trimObject`, () => expect(trimObject(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k'])).toEqual(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', '(1 more...)']));

        it(`trimObject`, () =>
            expect(trimObject({ a: 'a', b: 'b', c: 'c', d: 'd', e: 'e', f: 'f', g: 'g', h: 'h', i: 'i', j: 'j', k: 'k', l: 'l' })).toEqual({
                a: 'a',
                b: 'b',
                c: 'c',
                d: 'd',
                e: 'e',
                f: 'f',
                g: 'g',
                h: 'h',
                i: 'i',
                j: 'j',
                k: 'k',
                l: 'l',
            }));

        it(`trimObject`, () =>
            expect(trimObject({ a: 'abc'.repeat(100) })).toEqual({
                a: 'abc'.repeat(100),
            }));

        it(`trimObject`, () =>
            expect(trimObject({ a: 'abc'.repeat(1000) })).toEqual({
                a: 'abc'.repeat(333) + 'a...',
            }));

        it(`trimObject`, () =>
            expect(trimObject({ a: 'abc'.repeat(2000) })).toEqual({
                a: 'abc'.repeat(333) + 'a...',
            }));

        it(`fromCurrencyString`, () => expect(fromCurrencyString('')).toEqual(0));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$0.00')).toEqual(0));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$100.00')).toEqual(100));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$12.34')).toEqual(12.34));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$45.67')).toEqual(45.67));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('($12.34)')).toEqual(-12.34));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('($45.67)')).toEqual(-45.67));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('-$12.34')).toEqual(-12.34));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('-$45.67')).toEqual(-45.67));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$12,345,678.00')).toEqual(12345678));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$45,678')).toEqual(45678));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$12345678')).toEqual(12345678));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('45678')).toEqual(45678));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('$522.54')).toEqual(522.54));

        it(`fromCurrencyString`, () => expect(fromCurrencyString('0.00+0')).toEqual(0));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('0.00+10')).toEqual(10));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('10.00+10')).toEqual(20));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('10.00+0')).toEqual(10));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('10.00-10')).toEqual(0));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('10.00-20')).toEqual(-10));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('0.00-20')).toEqual(-20));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('0.00-0')).toEqual(0));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('1.00+abc')).toEqual(1));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('1.00+1+2')).toEqual(3));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('2.00-abc')).toEqual(2));
        it(`fromCurrencyString`, () => expect(fromCurrencyString('2.00-1+2')).toEqual(3));

        it(`fromPercentageString`, () => expect(fromPercentageString('')).toEqual(0));
        it(`fromPercentageString`, () => expect(fromPercentageString('0%')).toEqual(0));
        it(`fromPercentageString`, () => expect(fromPercentageString('100%')).toEqual(100));
        it(`fromPercentageString`, () => expect(fromPercentageString('12.34%')).toEqual(12.34));
        it(`fromPercentageString`, () => expect(fromPercentageString('45.67%')).toEqual(45.67));
        it(`fromPercentageString`, () => expect(fromPercentageString('-12.34%')).toEqual(-12.34));
        it(`fromPercentageString`, () => expect(fromPercentageString('-45.67%')).toEqual(-45.67));
        it(`fromPercentageString`, () => expect(fromPercentageString('(12.34%)')).toEqual(-12.34));
        it(`fromPercentageString`, () => expect(fromPercentageString('(45.67%)')).toEqual(-45.67));
        it(`fromPercentageString`, () => expect(fromPercentageString('12,345,678.00%')).toEqual(12345678));
        it(`fromPercentageString`, () => expect(fromPercentageString('45,678%')).toEqual(45678));
        it(`fromPercentageString`, () => expect(fromPercentageString('12345678%')).toEqual(12345678));
        it(`fromPercentageString`, () => expect(fromPercentageString('45678%')).toEqual(45678));
        it(`fromPercentageString`, () => expect(fromPercentageString('522.54%')).toEqual(522.54));
    });
});

// ******************************
