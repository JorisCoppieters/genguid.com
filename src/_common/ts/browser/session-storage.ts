// ******************************
// Imports:
// ******************************

import { SESSION_STORAGE_PREFIX, ENV_TYPE } from '../env/constants';
import { getClientId } from './env';
import { curDateStamp } from '../system/date';

// ******************************
// Enums:
// ******************************

export enum SESSION_STORAGE_KEY {
}

const SESSION_STORAGE_KEY_DEV_MAPPING: { [key: string]: string } = {
};

// ******************************
// Declarations:
// ******************************

export function readSS(in_envType: ENV_TYPE, in_key: string | string[]): string | boolean | number | null {
    const key = _getKey(in_envType, in_key);
    const value = sessionStorage.getItem(key);
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

export function writeSS(in_envType: ENV_TYPE, in_key: string | string[], in_value: string | boolean | number | null): void {
    let value = in_value;
    if (value === null) {
        return clearSS(in_envType, in_key);
    }
    if (typeof value === 'boolean') {
        value = value ? 'true' : 'false';
    }

    const key = _getKey(in_envType, in_key);

    if (sessionStorage.getItem(key) === value) {
        return;
    }

    return sessionStorage.setItem(key, `${value}`);
}

// ******************************

export function clearSS(in_envType: ENV_TYPE, in_key: string | string[]): void {
    return sessionStorage.removeItem(_getKey(in_envType, in_key));
}

// ******************************
// Helper Functions:
// ******************************

function _getKey(in_envType: ENV_TYPE, in_key: string | string[]): string {
    const clientId = getClientId(in_envType);
    const dateStamp = curDateStamp();
    let keys = Array.isArray(in_key) ? in_key : [in_key];
    if (in_envType === ENV_TYPE.Development) {
        keys = keys.map((key: string) => SESSION_STORAGE_KEY_DEV_MAPPING[key] || key);
    }
    return `${SESSION_STORAGE_PREFIX}:${clientId}:${dateStamp}#${keys.join('#')}`;
}

// ******************************
