// ******************************
// Declarations:
// ******************************

export function getNow(): number {
    return new Date().getTime();
}

// ******************************

export function curDateStamp() {
    const date = new Date();
    return [date.getFullYear(), ('00' + (date.getMonth() + 1)).slice(-2), ('00' + date.getDate()).slice(-2)].join('-');
}

// ******************************
