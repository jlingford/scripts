#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch ${filename}.sh
chmod u+x ${filename}.sh

template() {
    cat <<'EOF'
#!/usr/bin/bash

input=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "Usage: $0 [INPUT]"
    exit 1
fi

# Main:

EOF
}

template >"${filename}.sh"
