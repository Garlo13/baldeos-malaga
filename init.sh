#!/bin/bash

html="baldeos-source.html"
table="table.html"
lines="lines.txt"
csv="baldeos.csv"

function download_baldeos () {
    curl 'https://limpiezademalaga.es/baldeo-diario/' -o $html
}

function extract_information () {
 xmllint --html --xpath '//table/tbody/tr/td' $html | grep --invert-match -E 'Riego operativo.*|Riego incidencia.*' > $table

 remove_html_tags $table
}

function remove_html_tags () {
    while IFS= read -r line; do
        # Case 1: <td ... />
        if [[ $line == *"/>" ]]; then
            echo "" >> $lines
        else
            # Case 2: <td>...</td>
            # Drop everything before ">" (inclusive)
            cell=${line#*>}
            # Drop everything after "</td>" (inclusive)
            cell=${cell%</td>*}
            echo "$cell" >> $lines
        fi
   done < $1
}

function add_lines_to_csv () {
 cat $lines | paste -d "," - - - - - >> $csv
}

download_baldeos
extract_information
add_lines_to_csv

rm $table
rm $lines
rm $html
