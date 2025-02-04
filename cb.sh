#!/bin/bash

# Description: Unify copy and paste commands into one intelligent chainable command
# https://gist.github.com/RichardBronosky/56d8f614fab2bacdd8b048fb58d0c0c7
# based on https://github.com/javier-lopez/learn/blob/master/sh/tools/cb

VERSION="1.0.0"

_usage() {
    echo "Usage: cb [OPTIONS]

Unify the copy and paste commands into one intelligent chainable command.

Options:
  -a, --append              Append to the clipboard instead of overwriting.
  -i, --ignore-interrupts   Ignore interrupt signals.
  -U, --update              Update this program to the latest version.
  -v, --version             Show the version of this program.
  -h, --help                Show this help message and exit."
}

_version() {
    echo "cb version $VERSION"
}

_cb_copy() {
    if command -v xclip &>/dev/null; then
        if [[ $APPEND == "true" ]]; then
            { _paste_from_clipboard; cat; } | xclip -selection clipboard -i
        else
            cat | xclip -selection clipboard -i
        fi
    elif command -v xsel &>/dev/null; then
        if [[ $APPEND == "true" ]]; then
            { _paste_from_clipboard; cat; } | xsel --clipboard
        else
            cat | xsel --clipboard
        fi
    elif command -v pbcopy &>/dev/null; then
        if [[ $APPEND == "true" ]]; then
            { _paste_from_clipboard; cat; } | pbcopy
        else
            cat | pbcopy
        fi
    else
        echo "Error: No clipboard utility found (xclip, xsel, or pbcopy required)." >&2
        exit 1
    fi
}

_cb_paste() {
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard -o
    elif command -v xsel &>/dev/null; then
        xsel --clipboard
    elif command -v pbpaste &>/dev/null; then
        pbpaste
    else
        echo "Error: No clipboard utility found (xclip, xsel, or pbpaste required)." >&2
        exit 1
    fi
}

main() {
    if [[ $# -eq 0 ]] && [[ ! -p /dev/stdin ]]; then
        # No arguments and no input pipe
        _cb_paste
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) _usage; exit 0 ;;
            -a|--append) APPEND="true"; shift ;;
            -i|--ignore-interrupts) trap '' SIGINT; shift ;;
            -v|--version) _version; exit 0 ;;
            *) echo "Error: Unknown option '$1'"; _usage; exit 1 ;;
        esac
    done

    # Process input
    if [[ -p /dev/stdin ]]; then
        _cb_copy
    else
        _cb_paste
    fi
}

main "$@"
