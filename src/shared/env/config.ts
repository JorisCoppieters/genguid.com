import { config as baseConfig } from './config.base';
import { ENV_TYPE } from '../enums/env-type';

export const config = Object.assign(baseConfig, {
    envType: ENV_TYPE.Development,
    r18: false,
    requireEmailConfirmation: true,
});
