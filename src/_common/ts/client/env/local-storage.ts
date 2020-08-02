// ******************************
// Imports:
// ******************************

import { generateGuid } from '../../shared/core/guid';
import { IS_DEV, LOCAL_STORAGE_PREFIX, IS_TEST } from './vars';
import { readQV, QUERY_VARIABLE_KEY } from './query-variables';

// ******************************
// Enums:
// ******************************

export enum LOCAL_STORAGE_KEY {
    ClientId = 'CI',
}

const LOCAL_STORAGE_KEY_DEV_MAPPING: { [key: string]: string } = {
    CI: 'ClientId',
};

// ******************************
// Declarations:
// ******************************

export function getClientId(): string {
    if (IS_DEV || IS_TEST) {
        const queryVariableClientId = readQV(QUERY_VARIABLE_KEY.ClientId);
        if (queryVariableClientId) {
            return queryVariableClientId as string;
        }
    }

    let clientId = readLS(LOCAL_STORAGE_KEY.ClientId) as string;
    if (!clientId) {
        clientId = generateGuid();
        writeLS(LOCAL_STORAGE_KEY.ClientId, clientId);
    }
    return clientId;
}

// ******************************

export function readLS(in_key: string | string[]): string | boolean | number | null {
    const key = _getKey(in_key);
    const value = localStorage.getItem(key);
    if (value === null) {
        return null;
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

export function writeLS(in_key: string | string[], in_value: string | boolean | number | null): void {
    let value = in_value;
    if (value === null) {
        return clearLS(in_key);
    }
    if (typeof value === 'boolean') {
        value = value ? 'true' : 'false';
    }

    const key = _getKey(in_key);
    if (localStorage.getItem(key) === value) {
        return;
    }

    return localStorage.setItem(key, `${value}`);
}

// ******************************

export function clearLS(in_key: string | string[]): void {
    return localStorage.removeItem(_getKey(in_key));
}

// ******************************
// Helper Functions:
// ******************************

function _getKey(in_key: string | string[]): string {
    let keys = Array.isArray(in_key) ? in_key : [in_key];
    if (IS_DEV) {
        keys = keys.map((key: string) => LOCAL_STORAGE_KEY_DEV_MAPPING[key] || key);
    }
    return `${LOCAL_STORAGE_PREFIX}#${keys.join('#')}`;
}

// ******************************
