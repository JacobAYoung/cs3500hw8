#!/bin/bash

#unzip files
for x in *.ZIP; do 
    #remove directory if exists
    newDirectory=${x::${#x}-4}
    if [ -d "$newDirectory" ]; then
        rm -r "$newDirectory"
    fi
    mkdir "$newDirectory"
    cd "$newDirectory"
    unzip "../$x" > /dev/null
    cd "..";
done

#mkdir "submissionsOutput"
# if [ -d "submissionsOutput" ]; then
#     rm -r "submissionsOutput"
# else
#     mkdir "submissionsOutput"
# fi

# mkdir finalOutput

inputs=0
cd "sampleInput"
for y in *.txt; do
    let "inputs=inputs+1"
done
cd ".."

cd "submissions"

for x in *.pl; do
    cd "../sampleInput/"
    fileName="${x::${#x}-3}"
    correct=0
    for y in *.txt; do
        contents=`cat $y`
        output="$fileName-$y.out"
        outputDirectory="./submissionsOutput/$output"
        expectedOutput="./expectedOutput/$y.out"
        cd ".."
        answer=`cat $expectedOutput`
        program="./submissions/$x"
        swipl $program $contents > $outputDirectory
        DIFF=$(diff --strip-trailing-cr $outputDirectory $expectedOutput --ignore-space-change --ignore-blank-lines)
        if [ "$DIFF" == "" ]; then
            let "correct=correct+1"


            var=$(grep -w -regexp="$answer" $program)
            echo $program
            echo $answer
            echo $var


            if grep -q "$answer" $program; then
                star="*"
            else
                star=""
            fi
        fi
        cd "sampleInput"
    done
    cd ".."
    percent=$(awk "BEGIN { pc=100*${correct}/${inputs}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
    echo "$fileName,$percent$star" >> grades.txt
    cd "sampleInput"
done

#back to main directory
cd ".."
