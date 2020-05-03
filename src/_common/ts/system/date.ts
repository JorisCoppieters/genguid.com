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

export function getDurationTimestamp(in_seconds: number) {
    const hours = Math.floor(in_seconds / 3600);
    const minutes = Math.floor((in_seconds - hours * 3600) / 60);
    const seconds = Math.floor(in_seconds - hours * 3600 - minutes * 60);

    const hoursPart = ('0' + hours).slice(-2);
    const minutesPart = ('0' + minutes).slice(-2);
    const secondsPart = ('0' + seconds).slice(-2);
    return hoursPart + ':' + minutesPart + ':' + secondsPart;
}

// ******************************

export function getNiceDateTimestamp(in_date?: Date) {
    const dateObj = in_date ? new Date(in_date) : new Date();
    const year = dateObj.getFullYear();
    const month = ('0' + (dateObj.getMonth() + 1)).slice(-2);
    const date = ('0' + dateObj.getDate()).slice(-2);

    const hours = ('0' + dateObj.getHours()).slice(-2);
    const minutes = ('0' + dateObj.getMinutes()).slice(-2);
    const seconds = ('0' + dateObj.getSeconds()).slice(-2);
    return hours + ':' + minutes + ':' + seconds + ' ' + date + '/' + month + '/' + year;
}

// ******************************
