#!/bin/bash

html="baldeos.html"
table="table.html"
lines="lines.txt"
csv="baldeos.csv"

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

curl 'https://limpiezademalaga.es/baldeo-diario/' -o $html

xmllint --html --xpath '//table/tbody/tr/td' $html | grep --invert-match -E 'Riego operativo.*|Riego incidencia.*' > $table

remove_html_tags $table

cat $lines | paste -d "," - - - - - >> $csv

rm $table
rm $lines
rm $html
