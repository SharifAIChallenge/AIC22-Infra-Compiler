#! /bin/bash
echo "---------------- run compile script --------------------"
( cd ../scripts && ./compile.sh ../src/$1 $2 ../src/$3) 
