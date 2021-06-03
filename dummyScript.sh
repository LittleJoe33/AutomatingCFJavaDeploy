File="RPMListDummyChallenge.txt"
Lines=$(cat $File)
RPM=$1
regex='-(([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)\-([[:digit:]]+))\.'

if [[ -z "$1" ]] ; then
    echo 'No argument supplied. Expected format is "vcg-iid-simulator-MAJ.MIN.PATCH-BUILD.el7.x86_64.rpm"'
    exit 1
fi

[[ "$RPM" =~ $regex ]]

uversion="${BASH_REMATCH[1]}"
umajor="${BASH_REMATCH[2]}"
uminor="${BASH_REMATCH[3]}"
upatch="${BASH_REMATCH[4]}"
ubuild="${BASH_REMATCH[5]}"

if [[ -z "${BASH_REMATCH[1]}" ]] ; then
    echo 'Error recognising version inputted. Expected format is "vcg-iid-simulator-MAJ.MIN.PATCH-BUILD.el7.x86_64.rpm"'
    exit 1
fi

truncate -s 0 upgrades.txt
truncate -s 0 downgrades.txt
truncate -s 0 noaction.txt

for Line in $Lines
    do
        [[ "$Line" =~ $regex ]]
        iversion="${BASH_REMATCH[1]}"
        imajor="${BASH_REMATCH[2]}"
        iminor="${BASH_REMATCH[3]}"
        ipatch="${BASH_REMATCH[4]}"
        ibuild="${BASH_REMATCH[5]}"
        if [[ -z "${BASH_REMATCH[1]}" ]] ; then
        echo 'Error recognising version on manifest. Expected format is "vcg-iid-simulator-MAJ.MIN.PATCH-BUILD.el7.x86_64.rpm"'
        exit 1
        fi
        if [[ "$iversion" == "$uversion" ]]; then
            echo "$Line" >> noaction.txt
        elif [[ "$imajor" > "$umajor" ]]; then
            echo "$Line" >> upgrades.txt
        elif [[ "$imajor" < "$umajor" ]]; then
            echo "$Line" >> downgrades.txt
        elif [[ "$iminor" > "$uminor" ]]; then
            echo "$Line" >> upgrades.txt
        elif [[ "$iminor" < "$uminor" ]]; then
            echo "$Line" >> downgrades.txt 
        elif [[ "$ipatch" > "$upatch" ]]; then
           echo "$Line" >> upgrades.txt 
        elif [[ "$ipatch" < "$upatch" ]]; then
           echo "$Line" >> downgrades.txt 
        elif [[ "$ibuild" > "$ubuild" ]]; then
            echo "$Line" >> upgrades.txt 
        elif [[ "$ibuild" < "$ubuild" ]]; then
            echo "$Line" >> downgrades.txt 
        else
            echo 'Unknown error. Probably to do with version numbers. Expected format is "vcg-iid-simulator-MAJ.MIN.PATCH-BUILD.el7.x86_64.rpm"'
            exit 1
        fi
    done