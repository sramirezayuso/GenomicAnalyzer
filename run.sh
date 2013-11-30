#! /bin/bash

initial=$(date +%s%N | cut -b1-13)
./aminoacids $1
./proteins
./phenotypes
java -ea -jar speciesMatcher.jar
final=$(date +%s%N | cut -b1-13)
txt="Tiempo de ejecucion: "
time=`expr $final - $initial`
echo $txt $time
