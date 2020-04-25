// ******************************
// Imports:
// ******************************

import { LOCAL_STORAGE_PREFIX, ENV_TYPE } from '../env/constants';

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

export function readLS(in_envType: ENV_TYPE, in_key: string | string[]): string | boolean | number | null {
    const key = _getKey(in_envType, in_key);
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

export function writeLS(in_envType: ENV_TYPE, in_key: string | string[], in_value: string | boolean | number | null): void {
    let value = in_value;
    if (value === null) {
        return clearLS(in_envType, in_key);
    }
    if (typeof value === 'boolean') {
        value = value ? 'true' : 'false';
    }

    const key = _getKey(in_envType, in_key);
    if (localStorage.getItem(key) === value) {
        return;
    }

    return localStorage.setItem(key, `${value}`);
}

// ******************************

export function clearLS(in_envType: ENV_TYPE, in_key: string | string[]): void {
    return localStorage.removeItem(_getKey(in_envType, in_key));
}

// ******************************
// Helper Functions:
// ******************************

function _getKey(in_envType: ENV_TYPE, in_key: string | string[]): string {
    let keys = Array.isArray(in_key) ? in_key : [in_key];
    if (in_envType === ENV_TYPE.Development) {
        keys = keys.map((key: string) => LOCAL_STORAGE_KEY_DEV_MAPPING[key] || key);
    }
    return `${LOCAL_STORAGE_PREFIX}#${keys.join('#')}`;
}

// ******************************
