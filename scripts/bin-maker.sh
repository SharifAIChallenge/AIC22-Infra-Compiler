#! /bin/bash

# in all the functions bel
# check weather or not exitcode was 0 and return
function check {
    if [ $1 -eq 0 ];then
        info "code compiled successfully!"
    else
        fatal "couldn't compile code!"
        exit -1
    fi
}

######## depricated --> user enter_compile_dir instead ##########
# tries to enter the codebase folder if any
# rules:
#   if there is more than one folder: dont enter
#   if there is no folder : dont enter
#   if there is one and only one folder: enter!
function enter_codebase {

    codebase_dir=`ls -d */ | head -n1`
    dir_count=`ls -d */ | wc |  awk '{print$1}'`

    echo "$codebase_dir:$dir_count"
    # exit 0
    if [ -z  "$codebase_dir" ] || [ $dir_count -ne 1 ] ;then
        warn "no directory found in given source file"
        codebase_dir="./"
    fi
    cd $codebase_dir
    info "entered the code base"

}


# a better version of enter_codebase 
# witch search for a spesific file and 
# changes directory to the parent folder
function enter_compile_dir {
    # defaulting to first one if found multiple
    find . -iname $1
    compile_path=`find . -iname $1 | head -n1`
    info "compile path is :$compile_path"

    if [ -z compile_path ];then
        fatal "$1 not found!"
        exit -1;
    fi

    cd `dirname $compile_path`
}





PYTHON_CLIENT_ENTRY_FILE="client.py"
# compiles the python client into binary file
# the precedure taken here are based on the code
# structure described in the github repo lined below
# https://github.com/SharifAIChallenge/AIC21-client-python
# the binary compiler used here is pyinstaller pakage should
# be installed in the running enviorment (docker, virtualenv, ...)
function python-bin {
    echo "//////////// Welcome to Python ////////////"
    enter_compile_dir $PYTHON_CLIENT_ENTRY_FILE
    cd .. # stay above src/ dir

    info "language detected: python"
    info "start compiling using pyinstaller"
    echo "------------------------------"./src/$PYTHON_CLIENT_ENTRY_FILE
    pyinstaller --hidden-import cmath --onefile ./src/$PYTHON_CLIENT_ENTRY_FILE >> $LOG_PATH 2>&1 
    check $?
    mv dist/`basename $PYTHON_CLIENT_ENTRY_FILE .py` $BIN_PATH
}    

CPP_MAKE_FILE="CMakeLists.txt"
CPP_EXEC_FILE_NAME="client"
# compiles the cpp client into binary file
# the precedure taken here are based on the code
# structure described in the github repo lined below
# https://github.com/SharifAIChallenge/AIC21-client-cpp
# the binary compiler used here is cmake mixed with "make"
# thus both packages should be installed in the running 
# enviorment (docker, virtualenv, ...)
function cpp-bin {
#
#    enter_compile_dir $CPP_MAKE_FILE
#
#    info "language detected: C"
#    info "start compiling using CMAKE"
#    mkdir build
#    cd build
#        pwd >>$LOG_PATH
#        cmake .. >>$LOG_PATH 2>&1
#        make >>$LOG_PATH 2>&1
#        check $?
#        pwd >>$LOG_PATH
#
#        # use -name <exec-name> if many
#        executable=`find . -name $CPP_EXEC_FILE_NAME -type f -executable -print`
#        mv $executable $BIN_PATH
#    cd ..
     cd /home/scripts/isolated/AIC22-Client-Cpp
     rm -rf ./build/
     source ~/.bashrc
     ./build.sh >> /home/scripts/cpp-build.log
     mv build $BIN_PATH
     cd -
}

# not yet supported
# if you are next gen "team e Zrsakht" then "dastet ro mibuse" 
function java-bin {

    fatal "not currently supported!\n use [jar] instead"
    return -1
}

# the function below turns the jar file into linux executalbe file
# and its not yet optimized (turning jar into binary)
# holds up with the API just lacks performance
# again:
# if you are next gen "team e Zrsakht" then "dastet ro mibuse" 

JAR_STUB_PATH="$PWD/jar-stub.sh"
JAR_FILE_REGEX='*.jar'
function jar-bin {

    enter_compile_dir $JAR_FILE_REGEX

    info "language detected: jar"
    info "start compiling using jar-stub"
    
    jarfile=`ls | grep "jar" | head -n1`
    if [ -z $jarfile ];then
        fatal "couldn't find the jar file"
        return -1
    fi
    
    cat $JAR_STUB_PATH $jarfile >$BIN_PATH 2>>$LOG_PATH
    check $?
    chmod +x $BIN_PATH
}

# pun intended
function bin-bin {

    # enter_codebase

    warn "no compiling needed!"
    mv `ls | head -n1` $BIN_PATH 
}
