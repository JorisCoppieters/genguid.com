import { config } from '../../shared/env/config';
import { ENV_TYPE } from '../../shared/enums/env-type';

// ******************************
// Configuration:
// ******************************

export const APP_TITLE = config.appTitle;
export const APP_TITLE_AND_SLOGAN = `${config.appSlogan} | ${config.appTitle}`;

const host = config.appHost;
const isDev = config.envType === ENV_TYPE.Development;
const isTest = config.envType === ENV_TYPE.Test;
const isProd = config.envType === ENV_TYPE.Production;
const shortEnv: string = isProd ? 'prod' : isTest ? 'test' : 'dev';
const envPrefix: string = isProd ? '' : `${shortEnv}.`;
const envHost = `${envPrefix}${host}`;
const prodPortGroup = 4000;
const testPortGroup = 6000;
const devPortGroup = 8000;
const httpsPort = (isProd ? prodPortGroup : isTest ? testPortGroup : devPortGroup) + config.portIdx * 10 + 1;
export const WEB_URL = `https://${envHost}${isDev ? `:${httpsPort}` : ''}`;

// ******************************
// Extra Usage:
// ******************************

/*

USAGE:TEST - getNow()
USAGE:TEST - unsetNow()

*/

// ******************************
