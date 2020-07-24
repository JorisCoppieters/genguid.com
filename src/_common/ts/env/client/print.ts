// ******************************
// Imports:
// ******************************

import { IS_DEV, IS_TEST } from './vars';

// ******************************
// Declarations:
// ******************************

export function db(in_message: string): void {
    if (IS_DEV || IS_TEST) {
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
