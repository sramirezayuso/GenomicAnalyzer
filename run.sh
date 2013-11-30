#! /bin/bash

initial=$(date +%s%N | cut -b1-13)
./aminoacids $1
./proteins
./phenotypes
java -ea -jar speciesMatcher.jar
final=$(date +%s%N | cut -b1-13)
txt="Tiempo de ejecucion: "
seconds="segundos"
time=`expr $final - $initial`
thou=1000
timesec=$(bc -l <<< "scale=3;$time / $thou")
echo $txt $timesec $seconds
rm aminoacids.out
rm proteins.out
rm phenotypes.out
