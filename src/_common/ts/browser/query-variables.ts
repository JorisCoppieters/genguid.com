// ******************************
// Enums:
// ******************************

export enum QUERY_VARIABLE_KEY {
    ClientId = 'clientId',
    Env = 'env'
}

// ******************************
// Declarations:
// ******************************

export function readQV(in_key: QUERY_VARIABLE_KEY): string | boolean | number | null {
    const encodedKey = encodeURIComponent(in_key);
    const regExp = new RegExp(`${encodedKey}=(.+)`);

    const keyValue = window.location.search
        .substring(1)
        .split('&')
        .find((curValue) => curValue.match(regExp));

    if (!keyValue) {
        return null;
    }

    const [key, value] = keyValue.split('=');
    if (key !== encodedKey) {
        return null;
    }

    const decodedValue = decodeURIComponent(value);
    if (decodedValue === '') {
        return '';
    }
    if (decodedValue === 'true') {
        return true;
    }
    if (decodedValue === 'false') {
        return false;
    }
    if (!isNaN(+value)) {
        return +value;
    }
    return decodedValue;
}

// ******************************

export function writeQV(in_key: QUERY_VARIABLE_KEY, in_value: string | boolean | number | null): void {
    const encodedKey = encodeURIComponent(in_key);
    const regExp = new RegExp(`${encodedKey}=(.+)`);

    let value = in_value;
    if (value === null) {
        return clearQV(in_key);
    }
    if (typeof value === 'boolean') {
        value = value ? 'true' : 'false';
    }

    const encodedValue = encodeURIComponent(value);

    let newSearch =
        '?' +
        window.location.search
            .substring(1)
            .split('&')
            .filter((curValue) => !curValue.match(regExp))
            .concat([`${encodedKey}=${encodedValue}`])
            .sort()
            .join('&');

    if (newSearch === '?') {
        newSearch = '';
    }

    if (window.location.search === newSearch) {
        return;
    }

    window.history.pushState({ page: `${document.location.pathname}${newSearch}` }, '', `${document.location.pathname}${newSearch}`);
}

// ******************************

export function clearQV(in_key: QUERY_VARIABLE_KEY): void {
    const encodedKey = encodeURIComponent(in_key);
    const regExp = new RegExp(`${encodedKey}=(.+)`);

    let newSearch =
        '?' +
        window.location.search
            .substring(1)
            .split('&')
            .filter((curValue) => !curValue.match(regExp))
            .sort()
            .join('&');

    if (newSearch === '?') {
        newSearch = '';
    }

    if (window.location.search === newSearch) {
        return;
    }

    window.history.pushState({ page: `${document.location.pathname}${newSearch}` }, '', `${document.location.pathname}${newSearch}`);
}
// ******************************
