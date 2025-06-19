#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch ${filename}.sh
chmod u+x ${filename}.sh

echo -e "#!/usr/bin/bash" >>${filename}.sh
echo -e "" >>${filename}.sh
echo -e 'input=$1' >>${filename}.sh
echo -e "" >>${filename}.sh
echo -e 'if [[ $# -eq 0 ]]; then' >>${filename}.sh
echo -e '\t>&2 echo "Error: no arguments provided"' >>${filename}.sh
echo -e '\t>&2 echo "USAGE: $0 [INPUT]"' >>${filename}.sh
echo -e '\texit 1' >>${filename}.sh
echo -e 'fi' >>${filename}.sh
echo -e "" >>${filename}.sh
