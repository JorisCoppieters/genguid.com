// ******************************
// Imports:
// ******************************

import { ENV_TYPE } from '../env/constants';

// ******************************
// Declarations:
// ******************************

export function db(in_envType: ENV_TYPE, in_message: string): void {
    if ([ENV_TYPE.Development, ENV_TYPE.Test].indexOf(in_envType) >= 0) {
        // tslint:disable-next-line:no-console
        console.log(in_message);
    }
}

// ******************************

export function dbErr(in_message: string): void {
    // tslint:disable-next-line:no-console
    console.error(in_message);
}

// ******************************
