// ******************************
// Imports:
// ******************************

import { LOG_LEVEL, ENV_TYPE } from '../../shared/env/enums';
import { readQV, QUERY_VARIABLE_KEY } from './query-variables';

// ******************************
// Configuration:
// ******************************

const version = '<APP_VERSION>'; // TODO
export const VERSION = version;

const appName = '<APP_NAME>'; // TODO;
export const APP_NAME = appName;
export const APP_NAME_VARIABLE = APP_NAME.replace(/[ _]/, '-').toLowerCase();
export const APP_NAME_UPPERCASE_VARIABLE = APP_NAME.replace(/[ _]/, '_').toUpperCase();
export const SESSION_STORAGE_PREFIX = APP_NAME_VARIABLE;
export const LOCAL_STORAGE_PREFIX = APP_NAME_VARIABLE;

const appHost = location.host.replace(/(test|dev)./, '').replace(/:[0-9]+/, '');
export const HOST = appHost;

const envType = getEnvType('');

const debugMode = false;
const verboseMode = false;

const portIdx = 0; // TODO

export const ENV: ENV_TYPE = envType;
export const IS_DEV = envType === ENV_TYPE.Development;
export const IS_TEST = envType === ENV_TYPE.Test;
export const IS_PROD = envType === ENV_TYPE.Production;
export const SHORT_ENV: string = IS_PROD ? 'prod' : IS_TEST ? 'test' : 'dev';
export const ENV_PREFIX: string = IS_PROD ? '' : `${SHORT_ENV}.`;

let logLevel = LOG_LEVEL.Info; // TODO
if (debugMode) {
    logLevel = Math.max(logLevel, LOG_LEVEL.Debug);
} else if (verboseMode) {
    logLevel = Math.max(logLevel, LOG_LEVEL.Verbose);
} else if (IS_PROD) {
    logLevel = LOG_LEVEL.Warning;
}

const prodPortGroup = 4000;
const prodWebPortGroup = 5000;
const testPortGroup = 6000;
const testWebPortGroup = 7000;
const devPortGroup = 8000;
const devWebPortGroup = 9000;
export const HTTP_PORT = (IS_PROD ? prodPortGroup : IS_TEST ? testPortGroup : devPortGroup) + portIdx * 10;
export const HTTPS_PORT = (IS_PROD ? prodPortGroup : IS_TEST ? testPortGroup : devPortGroup) + portIdx * 10 + 1;
export const WEB_HTTPS_PORT = (IS_PROD ? prodWebPortGroup : IS_TEST ? testWebPortGroup : devWebPortGroup) + portIdx * 10 + 1;

export const WEB_PORT_PREFIX = IS_DEV ? `:${WEB_HTTPS_PORT}` : '';
export const PORT_PREFIX = IS_DEV ? `:${HTTPS_PORT}` : '';

export const WEB_URL = `https://${ENV_PREFIX}${appHost}${IS_DEV ? `:${WEB_HTTPS_PORT}` : ''}`;

export const SERVER_URL = `https://${ENV_PREFIX}${appHost}${IS_DEV ? `:${HTTPS_PORT}` : ''}`;

export const SOCKET_URL = `https://${ENV_PREFIX}${appHost}${IS_DEV ? `:${HTTPS_PORT}` : ''}`;
export const SOCKET_NAME_SPACE = 'ws';

// ******************************
// Helper Functions:
// ******************************

function getEnvType(in_propertiesEnv: string) {
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

function getIsDevUrl(): boolean {
    return readQV(QUERY_VARIABLE_KEY.Env) === 'dev' || !!location.host.match(`^(?:www\.)?dev\.${HOST.replace(/[.]/g, '\\.')}`);
}

// ******************************

function getIsTestUrl(): boolean {
    return readQV(QUERY_VARIABLE_KEY.Env) === 'test' || !!location.host.match(`^(?:www\.)?test\.${HOST.replace(/[.]/g, '\\.')}`);
}

// ******************************
