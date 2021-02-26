// ******************************
// Declarations:
// ******************************

export function setCSSClasses(in_parent: HTMLElement, in_classes: Array<string>): void {
    if (!in_parent) return;
    const classes = (in_classes || [])
        .filter((className) => !!className)
        .map((className) => className.replace(/movie-sync-control-/g, ''))
        .map((className) => `movie-sync-control-${className}`);

    const classesStr = classes.sort().join(' ');
    if (in_parent.className === classesStr) {
        return;
    }

    in_parent.className = classesStr;
}

// ******************************

export function addCSSClass(in_parent: HTMLElement, in_className: string): void {
    if (!in_parent) return;
    const classes = (in_parent.className || '')
        .replace(/movie-sync-control-/g, '')
        .split(' ')
        .filter((className) => !!className)
        .filter((className) => className !== in_className);

    classes.push(in_className);

    const classesStr = classes
        .sort()
        .map((className) => `movie-sync-control-${className}`)
        .join(' ');

    if (in_parent.className === classesStr) {
        return;
    }

    in_parent.className = classesStr;
}

// ******************************

export function removeCSSClass(in_parent: HTMLElement, in_className: string): void {
    if (!in_parent) return;
    const classes = (in_parent.className || '')
        .replace(/movie-sync-control-/g, '')
        .split(' ')
        .filter((className) => !!className)
        .filter((className) => className !== in_className);

    const classesStr = classes
        .sort()
        .map((className) => `movie-sync-control-${className}`)
        .join(' ');

    if (in_parent.className === classesStr) {
        return;
    }

    in_parent.className = classesStr;
}

// ******************************
