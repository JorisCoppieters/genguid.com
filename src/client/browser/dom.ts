import { setCSSClasses } from './css';

// ******************************
// Declarations:
// ******************************

export function getFirstByClass(in_className: string, in_parent?: HTMLElement): HTMLElement | null {
    const parent = in_parent || document;
    if (parent.getElementsByClassName(in_className).length) {
        return parent.getElementsByClassName(in_className)[0] as HTMLElement;
    }
    if (parent.getElementsByClassName(`movie-sync-control-${in_className}`).length) {
        return parent.getElementsByClassName(`movie-sync-control-${in_className}`)[0] as HTMLElement;
    }
    return null;
}

// ******************************

export function getFirstByTag(in_tagName: string, in_parent?: HTMLElement): HTMLElement | null {
    const parent = in_parent || document;
    if (parent.getElementsByTagName(in_tagName).length) {
        return parent.getElementsByTagName(in_tagName)[0] as HTMLElement;
    }
    return null;
}

// ******************************

export function createElement(in_parent: HTMLElement, in_tag: string, in_cssClasses?: Array<string> | string): HTMLElement {
    const element = document.createElement(in_tag);
    const cssClasses = in_cssClasses ? (Array.isArray(in_cssClasses) ? in_cssClasses : [in_cssClasses]) : [];
    in_parent.appendChild(element);
    element.className = cssClasses.join(' ');
    return element;
}

// ******************************

export function createButton(
    in_parent: HTMLElement,
    in_id: string,
    in_toolTip: string,
    in_iconCode: string,
    in_onClick: (this: GlobalEventHandlers, ev: MouseEvent) => void
): HTMLDivElement {
    const button = createElement(in_parent, 'div');
    button.id = `movie-sync-control-${in_id}`;
    button.onclick = in_onClick;
    setCSSClasses(button, ['btn', 'tooltip']);

    const tooltipText = createElement(button, 'span');
    setContent(tooltipText, in_toolTip);
    setCSSClasses(tooltipText, ['tooltip-text']);

    const buttonIconDiv = createElement(button, 'div');
    setCSSClasses(buttonIconDiv, ['icon']);

    const buttonIcon = createElement(buttonIconDiv, 'i');
    buttonIcon.className = `fas fa-${in_iconCode}`;

    return button as HTMLDivElement;
}

// ******************************

export function setContent(in_parent: HTMLElement, in_content: string, in_html?: boolean): void {
    if (in_parent.innerHTML === in_content || in_parent.innerText === in_content) {
        return;
    }
    if (in_html) {
        in_parent.innerHTML = in_content;
        return;
    }
    in_parent.innerText = in_content;
}

// ******************************
