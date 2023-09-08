import { ENV_TYPE } from '../enums/env-type';
import { config } from './config';

// ******************************
// Configuration:
// ******************************

/* istanbul ignore file */

const host = config.appHost;
const envType = config.envType;
const isProd = envType === ENV_TYPE.Production;
const isTest = envType === ENV_TYPE.Test;
export const IS_DEV = envType === ENV_TYPE.Development;
const envShort = isProd ? 'prod' : isTest ? 'test' : 'dev';
const envPrefix = isProd ? '' : `${envShort}.`;

export const ENV_HOST = `${envPrefix}${host}`;

export const CERT_NAME = `${ENV_HOST}.crt`;
export const KEY_NAME = `${ENV_HOST}.key`;

const prodPortGroup = 4000;
const testPortGroup = 6000;
const devPortGroup = 8000;
const portIdx = config.portIdx;

export const HTTPS_PORT = (isProd ? prodPortGroup : isTest ? testPortGroup : devPortGroup) + portIdx * 10 + 1;

// ******************************
