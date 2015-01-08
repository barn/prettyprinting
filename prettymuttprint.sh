#!/bin/sh

# What do you want the base of the files to be called?
FBASE='muttprint'
WHERETO="${HOME}/Desktop/"
URL2PDF="${HOME}/bin/url2pdf"

# Mess.
function generate_filename() {
    local outfile
    local count

    outfile="${WHERETO}/${FBASE}.pdf"
    if [ -e "${outfile}" ]
    then
        count=1

        outfile="${WHERETO}/${FBASE}-${count}.pdf"
        while [ -e "${outfile}" ]
        do
            count=$(( $count + 1 ))
            outfile="${WHERETO}/${FBASE}-${count}.pdf"
        done
    fi

    echo "${outfile}"
}

function fail() {
    cd $ORIGDIR
    rm -rf "${TMPFILE}"
    exit 10
}

function file_to_pdf() {
    local file=$1
    local pdffile

    if [ -z $file ]
    then
        echo "Failed to extract HTML" >&2
        fail
    fi

    mv "$file" "${file}.html"
    file="${file}.html"

    # http://gavinballard.com/automatically-converting-html-to-pdf-on-mac/
    # https://github.com/scottgarner/URL2PDF
    pdffile=$(${URL2PDF} -b YES -i YES -j NO --url=file://$PWD/$file -p ~/Desktop/)

    if [ -e "${pdffile}" ]
    then
        mv "${pdffile}" "$(generate_filename)"
    fi
}

if ! [ -e "${URL2PDF}" ]
then
    echo "Can't find a valid url2pdf" >&2
    exit 20
fi

# Joy follows.
tempfoo=`basename $0`
TMPFILE=`mktemp -d -t ${tempfoo}` || exit 1

ORIGDIR=$PWD
cd $TMPFILE



# Split out the raw email in to all of it's parts. text-plainN,
# text-htmlN, etc...
#
# http://www.pldaniels.com/ripmime/
ripmime --name-by-type -i - -d $TMPFILE || exit 25


count=0
for file in $( find . -iname 'text-html*' )
do
    count=$(( $count + 1 ))  # This just needs to be not 0, but why not
                             # count it anyway.
    file_to_pdf "${file}"
done

# Didn't do any html files, what's left?
if [ $count -eq 0 ]
then
    for file in $( find . -iname 'text-plain*' )
    do
        count=$(( $count + 1 ))
        file_to_pdf "${file}"
    done
fi

cd $ORIGDIR

# Tidy.
rm -rf "${TMPFILE}"
