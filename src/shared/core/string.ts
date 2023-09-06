// ******************************
// Declarations:
// ******************************

export function toTitleCase(in_value: string) {
    return _toSegments(in_value)
        .map((seg) => seg.slice(0, 1).toUpperCase() + seg.slice(1))
        .join(' ');
}

// ******************************

export function toPascalCase(in_value: string) {
    return _toSegments(in_value)
        .map((seg) => seg.slice(0, 1).toUpperCase() + seg.slice(1))
        .join('');
}

// ******************************

export function toCamelCase(in_value: string) {
    const pascalCase = toPascalCase(in_value);
    return pascalCase.slice(0, 1).toLowerCase() + pascalCase.slice(1);
}

// ******************************

export function toKebabCase(in_value: string) {
    return _toSegments(in_value).join('-');
}

// ******************************

export function leftPad(in_value: string, in_pad: string, in_padAmount: number) {
    if (in_padAmount <= in_value.length) {
        return in_value;
    }
    if (in_pad.length !== 1) {
        throw new Error(`Pad should be one character`);
    }
    return (in_pad.repeat(in_padAmount) + in_value).substr(-in_padAmount);
}

// ******************************

export function rightPad(in_value: string, in_pad: string, in_padAmount: number) {
    if (in_padAmount <= in_value.length) {
        return in_value;
    }
    if (in_pad.length !== 1) {
        throw new Error(`Pad should be one character`);
    }
    return (in_value + in_pad.repeat(in_padAmount)).substr(0, in_padAmount);
}

// ******************************

export function centerPad(in_value: string, in_pad: string, in_padAmount: number) {
    if (in_padAmount <= in_value.length) {
        return in_value;
    }
    if (in_pad.length !== 1) {
        throw new Error(`Pad should be one character`);
    }

    while (in_value.length < in_padAmount) {
        const leftOrRight = in_value.length % 2 === 1;
        in_value = (leftOrRight ? in_pad : '') + in_value + (leftOrRight ? '' : in_pad);
    }

    return in_value.substr(0, in_padAmount);
}

// ******************************

// export function toCurrencyString(in_value: number): string {
//     if (isNaN(in_value)) {
//         throw new Error(`Value isn't a number`);
//     }

//     const negative = in_value <= -0.01;
//     const absVal = Math.abs(in_value);
//     const fullValue = dollarRound(absVal);
//     const decimalValue = dollarRound((absVal - fullValue) * 100);
//     const stringValue = `$${Number(fullValue).toLocaleString()}.${('00' + decimalValue).slice(-2)}`;
//     return negative ? `(${stringValue})` : `${stringValue}`;
// }

// ******************************

export function fromCurrencyString(in_value: string): number {
    let match;
    let parsedValue = (`${in_value}` || '').replace(/[,]/g, '').replace(/[$]/, '');

    match = parsedValue.match(/^(.+)\*(.+)$/);
    if (match) {
        return (fromCurrencyString(match[1]) || 0) * (fromCurrencyString(match[2]) || 0);
    }

    match = parsedValue.match(/^(.+)\/(.+)$/);
    if (match) {
        return (fromCurrencyString(match[1]) || 0) / (fromCurrencyString(match[2]) || 1);
    }

    match = parsedValue.match(/^(.+)\+(.+)$/);
    if (match) {
        return (fromCurrencyString(match[1]) || 0) + (fromCurrencyString(match[2]) || 0);
    }

    match = parsedValue.match(/^(.+)\-(.+)$/);
    if (match) {
        return (fromCurrencyString(match[1]) || 0) - (fromCurrencyString(match[2]) || 0);
    }

    const negative = parsedValue.match(/^\(.*\)$/);
    if (negative) {
        parsedValue = parsedValue.replace(/^\((.*)\)$/, '$1');
    }

    const numValue = parseFloat(parsedValue);
    if (isNaN(numValue)) {
        return 0;
    } else {
        return bankersRound((negative ? -1 : 1) * numValue);
    }
}

// ******************************

export function toPercentageString(in_value: number): string {
    if (isNaN(in_value)) {
        throw new Error(`Value isn't a number`);
    }

    const value = in_value * 100;
    const negative = value <= -0.01;
    const fullValue = Math.abs(dollarRound(value));
    const decimalValue = Math.abs(dollarRound(value * 100 - fullValue * 100));
    const stringValue = `${Number(fullValue).toLocaleString()}.${('00' + decimalValue).slice(-2)}%`;
    return negative ? `(${stringValue})` : `${stringValue}`;
}

// ******************************

export function toWholePercentageString(in_value: number): string {
    const value = in_value * 100;
    const negative = value <= -1;
    const fullValue = Math.abs(dollarRound(value));
    const stringValue = `${Number(fullValue).toLocaleString()}%`;
    return negative ? `(${stringValue})` : `${stringValue}`;
}

// ******************************

export function fromPercentageString(in_value: string): number {
    let parsedValue = (`${in_value}` || '').replace(/[,]/g, '').replace(/[%]/, '');
    const negative = parsedValue.match(/^\(.*\)$/);
    if (negative) {
        parsedValue = parsedValue.replace(/^\((.*)\)$/, '$1');
    }

    const numValue = parseFloat(parsedValue);
    if (isNaN(numValue)) {
        return 0;
    } else {
        return ((negative ? -1 : 1) * numValue) / 100;
    }
}

// ******************************

export function trimObject(in_data: any) {
    let data = in_data;
    const dataType = typeof data;
    if (data !== null && dataType === 'object') {
        if (Array.isArray(data)) {
            const arrayCutOff = 10;
            if (data.length > arrayCutOff) {
                data = data.slice(0, arrayCutOff).concat([`(${data.length - arrayCutOff} more...)`]);
            }
            data = data.map((val: any) => trimObject(val));
        } else if (data instanceof Date) {
            return data.toString();
        } else {
            data = Object.keys(data).reduce((dict: { [key: string]: any }, key) => {
                dict[key] = trimObject(data[key]);
                return dict;
            }, {});
        }
    } else if (dataType === 'string') {
        if (data.length > 1000) {
            data = data.slice(0, 1000) + '...';
        }
    }

    return data;
}

// ******************************
// Helper Functions:
// ******************************

function _toSegments(in_value: string) {
    return in_value
        .replace(/([a-z0-9]|(?=[A-Z]))([A-Z])/g, '$1-$2')
        .toLowerCase()
        .replace(/^-/, '')
        .split(/[-_ ]/);
}

// ******************************
