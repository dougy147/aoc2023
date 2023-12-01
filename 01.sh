#!/bin/sh

result=0;while read line; do num=$(echo $line | tr "[a-zA-Z]" " " | sed "s/\ //g"); num1=$(echo $num | grep -Eo "^."); num2=$(echo $num | grep -Eo ".$"); num3=$(echo $num1$num2); result=$(( result + num3)) ; done < assets/01.txt; echo $result

