#!/bin/bash

mkdir -p $1

rm $1/*

for f in `cat $2`; do
       touch $1/$f.txt
done

