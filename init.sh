CB_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)

alias cb="$CB_PATH/cb.sh"
