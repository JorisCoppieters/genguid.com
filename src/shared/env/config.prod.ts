import { config as baseConfig } from './config.base';
import { ENV_TYPE } from '../enums/env-type';
import { LOG_LEVEL } from '../enums/log-level';

export const config = Object.assign(baseConfig, {
    envType: ENV_TYPE.Production,
    logLevel: LOG_LEVEL.Warning,
    r18: false,
    requireEmailConfirmation: true,
});
