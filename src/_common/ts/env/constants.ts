// ******************************
// Constants:
// ******************************

export const HOST = "genguid.com";
export const APP_NAME = 'Gen GUID';
export const APP_NAME_VARIABLE = APP_NAME.replace(/[ _]/, '-').toLowerCase();
export const SESSION_STORAGE_PREFIX = APP_NAME_VARIABLE;
export const LOCAL_STORAGE_PREFIX = APP_NAME_VARIABLE;

// ******************************
// Enums:
// ******************************

export enum ENV_TYPE {
    Development = 'Development',
    Test = 'Test',
    Production = 'Production',
}

// ******************************

export enum LOG_LEVEL {
    Off = 0,
    Error = 1,
    Warning = 2,
    Info = 3,
    Verbose = 4,
    Debug = 5,
}

// ******************************

export enum API_METHOD {
    Post = 'POST',
    Get = 'GET',
    Put = 'PUT',
    Delete = 'DELETE',
}

// ******************************
