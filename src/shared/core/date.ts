// ******************************
// Declarations:
// ******************************

export const S = 1000;
const M = 60 * S; // Ignore multiplier
const H = 60 * M; // Ignore multiplier
export const D = 24 * H; // Ignore multiplier
export const W = 7 * D; // Ignore multiplier

let FROZEN_NOW: Date | null = null;

// ******************************

export function setNow(in_date: Date): void {
    FROZEN_NOW = in_date;
}

// ******************************

export function unsetNow(): void {
    FROZEN_NOW = null;
}

// ******************************

export function getNow(): Date {
    if (FROZEN_NOW !== null) {
        return new Date(FROZEN_NOW.getTime());
    }
    return new Date(); // Ignore new Date()
}

// ******************************

export function getNowTime(): number {
    return getNow().getTime();
}

// ******************************

// export function extractValidDate(in_date: any, in_default?: any): Date {
//     if (isValidDate(in_date)) {
//         return new Date(in_date);
//     }

//     if (in_default === undefined) {
//         throw new Error(`Invalid date value: ${in_date}`);
//     }

//     return in_default;
// }

// ******************************

export function isValidDate(in_date: any): boolean {
    if (in_date === null || in_date === undefined) {
        return false;
    }
    const date = new Date(in_date);
    return !isNaN(date.getTime());
}

// ******************************

// export function startOfYear(in_date?: Date): Date {
//     const yearOfDate = new Date(in_date || getNow());
//     yearOfDate.setUTCMonth(0, 1);
//     yearOfDate.setUTCHours(0, 0, 0, 0);
//     return yearOfDate;
// }

// ******************************

// export function startOfMonth(in_date?: Date): Date {
//     const monthOfDate = new Date(in_date || getNow());
//     monthOfDate.setUTCDate(1);
//     monthOfDate.setUTCHours(0, 0, 0, 0);
//     return monthOfDate;
// }

// ******************************

// export function startOfWeek(in_date?: Date): Date {
//     const weekOfDate = new Date(in_date || getNow());
//     const dayDiff = weekOfDate.getUTCDay() === 0 ? 6 : weekOfDate.getUTCDay() - 1;
//     weekOfDate.setUTCDate(weekOfDate.getUTCDate() - dayDiff);
//     weekOfDate.setUTCHours(0, 0, 0, 0);
//     return weekOfDate;
// }

// ******************************

// export function startOfDay(in_date?: Date): Date {
//     const dayOfDate = new Date(in_date || getNow());
//     dayOfDate.setUTCHours(0, 0, 0, 0);
//     return dayOfDate;
// }

// ******************************

// export function endOfMonth(in_date?: Date): Date {
//     const monthOfDate = startOfMonth(in_date || getNow());
//     monthOfDate.setUTCMonth(monthOfDate.getUTCMonth() + 1);
//     monthOfDate.setUTCMilliseconds(-1);
//     return monthOfDate;
// }

// ******************************

// export function endOfWeek(in_date?: Date): Date {
//     const weekOfDate = startOfWeek(in_date || getNow());
//     weekOfDate.setUTCDate(weekOfDate.getUTCDate() + 7);
//     weekOfDate.setUTCMilliseconds(-1);
//     return weekOfDate;
// }

// ******************************

// export function endOfDay(in_date?: Date): Date {
//     const dayOfDate = startOfDay(in_date || getNow());
//     dayOfDate.setUTCDate(dayOfDate.getUTCDate() + 1);
//     dayOfDate.setUTCMilliseconds(-1);
//     return dayOfDate;
// }

// ******************************

// export function getNiceDate(in_date?: Date, in_shortYear?: boolean): string {
//     const dateObj = in_date ? new Date(in_date) : getNow();
//     const year = dateObj.getUTCFullYear();
//     const month = ('0' + (dateObj.getUTCMonth() + 1)).slice(-2);
//     const date = ('0' + dateObj.getUTCDate()).slice(-2);

//     if (in_shortYear) {
//         return `${date}/${month}/${`${year}`.slice(-2)}`;
//     }
//     return `${date}/${month}/${year}`;
// }

// ******************************

// export function getShortDate(in_date?: Date, in_hideYear?: boolean): string {
//     const dateObj = in_date ? new Date(in_date) : getNow();
//     const year = `${dateObj.getUTCFullYear()}`.slice(-2);
//     const month = ('0' + (dateObj.getUTCMonth() + 1)).slice(-2);
//     const date = ('0' + dateObj.getUTCDate()).slice(-2);

//     return in_hideYear ? `${date}/${month}` : `${date}/${month}/${year}`;
// }

// ******************************

export function toDateStamp(in_date?: Date): string {
    const dateObj = in_date ? new Date(in_date) : getNow();
    const year = dateObj.getUTCFullYear();
    const month = ('0' + (dateObj.getUTCMonth() + 1)).slice(-2);
    const date = ('0' + dateObj.getUTCDate()).slice(-2);

    return `${year}-${month}-${date}`;
}

// ******************************

export function toDateTimeStamp(in_date?: Date): string {
    const dateObj = in_date ? new Date(in_date) : getNow();
    const year = dateObj.getUTCFullYear();
    const month = ('0' + (dateObj.getUTCMonth() + 1)).slice(-2);
    const date = ('0' + dateObj.getUTCDate()).slice(-2);

    const hours = ('0' + dateObj.getUTCHours()).slice(-2);
    const minutes = ('0' + dateObj.getUTCMinutes()).slice(-2);
    const seconds = ('0' + dateObj.getUTCSeconds()).slice(-2);
    return `${year}-${month}-${date} ${hours}:${minutes}:${seconds}`;
}

// ******************************

export function curDateStamp(): string {
    const date = new Date();
    return [date.getFullYear(), ('00' + (date.getMonth() + 1)).slice(-2), ('00' + date.getDate()).slice(-2)].join('-');
}

// ******************************

export function getDurationTimestamp(in_seconds: number): string {
    const hours = Math.floor(in_seconds / 3600);
    const minutes = Math.floor((in_seconds - hours * 3600) / 60);
    const seconds = Math.floor(in_seconds - hours * 3600 - minutes * 60);

    const hoursPart = ('0' + hours).slice(-2);
    const minutesPart = ('0' + minutes).slice(-2);
    const secondsPart = ('0' + seconds).slice(-2);
    return hoursPart + ':' + minutesPart + ':' + secondsPart;
}

// ******************************

export function getNiceDateTimestamp(in_date?: Date): string {
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

export function getLedgerDateTimestamp(in_date?: Date): string {
    const dateObj = in_date ? new Date(in_date) : new Date();
    const year = dateObj.getFullYear();
    const month = ('0' + (dateObj.getMonth() + 1)).slice(-2);
    const date = ('0' + dateObj.getDate()).slice(-2);

    const hours = ('0' + dateObj.getHours()).slice(-2);
    const minutes = ('0' + dateObj.getMinutes()).slice(-2);
    const seconds = ('0' + dateObj.getSeconds()).slice(-2);
    return `${year}-${month}-${date} ${hours}:${minutes}:${seconds}`;
}

// ******************************

export function getNiceDate(in_date?: Date): string {
    const dateObj = in_date ? new Date(in_date) : new Date();
    const year = dateObj.getFullYear();
    const month = ('0' + (dateObj.getMonth() + 1)).slice(-2);
    const date = ('0' + dateObj.getDate()).slice(-2);

    return `${date}/${month}/${year}`;
}

// ******************************

export function getDateStampRange(in_numDays: number): Array<string> {
    const numDays = in_numDays || 365;
    const dateKeys = [...Array(numDays)]
        .map((_, idx) => idx)
        .map((day) => new Date(Date.now() - 3600 * 24 * 1000 * day))
        .map((date) => toDateStamp(date));
    return dateKeys;
}

// ******************************

export function fromDateStamp(in_date?: string | null): Date {
    if (!in_date) {
        return new Date();
    }

    return new Date(`${in_date}`);
}

// ******************************
