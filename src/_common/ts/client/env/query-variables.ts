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

export function parseQueryString(in_queryString: string | null) {
    if (!in_queryString) {
        return {};
    }

    let queryString = in_queryString;
    if (queryString.substr(0, 1) !== '?') {
        queryString = `?${queryString}`;
    }

    return queryString
        .substring(1)
        .split('&')
        .reduce((dict: {[key: string]: string | undefined}, param) => {
            const [key, value] = param.split('=');
            const decKey = decodeURIComponent(key);
            const decValue = decodeURIComponent(value);
            dict[decKey] = decValue;
            return dict;
        }, {})
}

// ******************************

export function toQueryString(in_keyValues: {[key: string]: string | undefined}) {
    const queryString = Object.keys(in_keyValues)
        .map((key: string) => {
            const value = in_keyValues[key];
            const encKey = encodeURIComponent(key);
            return typeof(value) === 'undefined' ? `${encKey}` : `${encKey}=${encodeURIComponent(value)}`
        })
        .join('&');

    return queryString.length ? `?${queryString}` : '';
}

// ******************************

export function readQV(in_key: QUERY_VARIABLE_KEY): string | boolean | number | null {
    const keyVals = parseQueryString(window.location.search);
    const value = keyVals[in_key];
    if (!value) {
        return null;
    }
    if (value === '') {
        return '';
    }
    if (value === 'true') {
        return true;
    }
    if (value === 'false') {
        return false;
    }
    if (!isNaN(+value)) {
        return +value;
    }
    return value;
}

// ******************************

export function writeQV(in_key: QUERY_VARIABLE_KEY, in_value: string | boolean | number | null): void {
    let value = in_value;
    if (value === null) {
        return clearQV(in_key);
    }
    if (typeof value === 'boolean') {
        value = value ? 'true' : 'false';
    }

    const keyVals = parseQueryString(window.location.search);
    keyVals[in_key] = `${value}`;

    const newSearch = toQueryString(keyVals);
    if (window.location.search === newSearch) {
        return;
    }

    window.history.pushState({ page: `${document.location.pathname}${newSearch}` }, '', `${document.location.pathname}${newSearch}`);
}

// ******************************

export function clearQV(in_key: QUERY_VARIABLE_KEY): void {
    const keyVals = parseQueryString(window.location.search);
    if (typeof(keyVals[in_key]) !== 'undefined') {
        delete keyVals[in_key];
    }

    const newSearch = toQueryString(keyVals);
    if (window.location.search === newSearch) {
        return;
    }

    if (window.location.search === newSearch) {
        return;
    }

    window.history.pushState({ page: `${document.location.pathname}${newSearch}` }, '', `${document.location.pathname}${newSearch}`);
}
// ******************************
