#initialisation of variables. File is taken in for comparison with argument. Regex searches for an expression following the "-NUM.NUM.NUM-NUM." format
File="RPMListDummyChallenge.txt"
Lines=$(cat $File)
RPM=$1
regex='-(([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)\-([[:digit:]]+))\.'

#checks arg is not null
if [[ -z "$1" ]] ; then
    echo 'No argument supplied. Expected format is "vcg-iid-simulator-MAJ.MIN.PATCH-BUILD.el7.x86_64.rpm"'
    exit 1
fi

#checks if arg matches regex. uses regex to grab each part of the -123.456.78-9 expression from arg
[[ "$RPM" =~ $regex ]]

uversion="${BASH_REMATCH[1]}"
umajor="${BASH_REMATCH[2]}"
uminor="${BASH_REMATCH[3]}"
upatch="${BASH_REMATCH[4]}"
ubuild="${BASH_REMATCH[5]}"

#throws error if regex is not found within arg. Might go back and do this in a cleaner way but it works.
if [[ -z "${BASH_REMATCH[1]}" ]] ; then
    echo 'Error recognising version inputted. Expected format is "vcg-iid-simulator-MAJ.MIN.PATCH-BUILD.el7.x86_64.rpm"'
    exit 1
fi

#clear files before writing
truncate -s 0 upgrades.txt
truncate -s 0 downgrades.txt
truncate -s 0 noaction.txt

#does the same with the regex as above for each line in the manifest. elif ladder then checks whether version is newer or older and appends to appropriate .txt file
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