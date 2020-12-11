#!/bin/bash
exec > generated-html/current_versions.html
cp generated-versions/current_versions.txt generated-html/current.txt
cd generated-html
sed -e '2d;4d' current.txt > current2.txt
awk 'NR % 2' current2.txt > even_lines
awk '{print $11}' even_lines > current_versions
awk '{print $6}' even_lines > tile_names
paste -d \\n tile_names current_versions > names_current_version
awk 'NR % 2 != 1' current2.txt > latest.txt
tail -100 latest.txt > latest_removed_ops.txt
tail -100 names_current_version > current_removed_ops.txt
awk '{print $6}' latest_removed_ops.txt > latest_versions
echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "<style>"
echo "table, th, td {  border: 1px solid black; border-collapse: collapse;}"
echo "</style>"
echo "</head>"
echo "<body>"
echo "<h2>Sample Tile Version Report</h2>"
echo "<table style="width:100%">"
echo "<tr>"
echo "<th>" "Tile Name" "</th>"
echo "<th>" "Tile Current Version" "</th>"
echo "<th>" "Tile Version Available" "</th>"
for l in 1 3 5 7 9 11 13 15 17 19 21 23 25
do
 m=$(($l+1))
 cat current_removed_ops.txt > current_only_names_versions.txt
 echo "<tr>"
 column1=$(sed -n "${l}p" current_only_names_versions.txt)
 column2=$(sed -n "${m}p" current_only_names_versions.txt)
 echo "<th>" "$column1" "</th>"
 echo "<th>" "$column2" "</th>"
 if [ $l == 1 ]
 then
     k=1
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 3 ]
 then
     k=2
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 5 ]
 then
     k=3
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 7 ]
 then
     k=4
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 9 ]
 then
     k=5
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 11 ]
 then
     k=6
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 13 ]
 then
     k=7
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 15 ]
 then
     k=8
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 17 ]
 then
     k=9
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 19 ]
 then
     k=10
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 21 ]
 then
     k=11
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 elif [ $l == 23 ]
 then
     k=12
     column3=$(sed -n "${k}p" latest_versions)
     echo "<th>" "$column3" "</th>" "</tr>"
 else [ $l == 25 ]
     k=13
     #sed -n "${k}p" latest_versionsa
     echo "<th>" "depriciated" "</th>" "</tr>"
 fi
done
echo "</table>"
echo "</body>"
echo "</html>"
