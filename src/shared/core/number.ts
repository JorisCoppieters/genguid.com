// ******************************
// Declarations:
// ******************************

export function isPositiveInteger(in_value: number) {
    return Number.isInteger(in_value) && in_value >= 0;
}

// ******************************

// export function isPositiveReal(in_value: number) {
//     return !Number.isNaN(in_value) && in_value >= 0;
// }

// ******************************

export function bankersRound(in_value: number, in_places = 2): number {
    const p = Math.pow(10, Math.max(0, in_places));
    const x = in_value * p;
    const r = Math.round(x);
    const br = (x > 0 ? x : -x) % 1 === 0.5 ? (0 === r % 2 ? r : r - 1) : r;
    return br / p;
}

// ******************************

export function dollarRound(in_value: number): number {
    const s = in_value < 0 ? -1 : 1;
    const v = Math.floor(Math.abs(in_value) + 0.005); // Ignore Math.floor()
    if (v === 0) return 0;
    return v * s;
}

// ******************************

// export function bankersDiff(in_value1: number, in_value2: number): number {
//     const diff = in_value2 - in_value1;
//     if (Math.abs(diff) < 0.01) {
//         return 0;
//     }
//     return bankersRound(diff);
// }

// ******************************
