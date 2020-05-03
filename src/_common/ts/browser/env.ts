// ******************************
// Imports:
// ******************************

import { ENV_TYPE, HOST } from '../env/constants';
import { generateGuid } from '../system/guid';
import { readLS, writeLS, LOCAL_STORAGE_KEY } from './local-storage';
import { readQV, QUERY_VARIABLE_KEY } from './query-variables';

// ******************************
// Declarations:
// ******************************

export function getClientId(in_envType: ENV_TYPE): string {
    if ([ENV_TYPE.Development, ENV_TYPE.Test].indexOf(in_envType) >= 0) {
        const queryVariableClientId = readQV(QUERY_VARIABLE_KEY.ClientId);
        if (queryVariableClientId) {
            return queryVariableClientId as string;
        }
    }

    let clientId = readLS(in_envType, LOCAL_STORAGE_KEY.ClientId) as string;
    if (!clientId) {
        clientId = generateGuid();
        writeLS(in_envType, LOCAL_STORAGE_KEY.ClientId, clientId);
    }
    return clientId;
}

// ******************************

export function getEnvType(in_propertiesEnv: string) {
    const propertiesEnv = (in_propertiesEnv || '').trim().toLowerCase();
    if (['development', 'dev'].indexOf(propertiesEnv) >= 0) {
        return ENV_TYPE.Development;
    }
    if (['test'].indexOf(propertiesEnv) >= 0) {
        return ENV_TYPE.Test;
    }
    if (getIsDevUrl()) {
        return ENV_TYPE.Development;
    }
    if (getIsTestUrl()) {
        return ENV_TYPE.Test;
    }
    return ENV_TYPE.Production;
}

// ******************************

export function getIsDevUrl(): boolean {
    return readQV(QUERY_VARIABLE_KEY.Env) === 'dev' || !!location.host.match(`^(?:www\.)?dev\.${HOST.replace(/[.]/g, '\\.')}`);
}

// ******************************

export function getIsTestUrl(): boolean {
    return readQV(QUERY_VARIABLE_KEY.Env) === 'test' || !!location.host.match(`^(?:www\.)?test\.${HOST.replace(/[.]/g, '\\.')}`);
}

// ******************************
