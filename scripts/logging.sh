# takes a string and append it to the log file 
# as well as the console tty
# log file is configured with $LOG_PATH enviorment
function log {
  echo "$1" | tee -a $LOG_PATH
}

# clears the log file
# log file is configured with $LOG_PATH enviorment
function empty_log {
    echo "" > $LOG_PATH
}

# generates info log using log func declared above
function info {
    log "===[INFO]===[`date +'%F-%T'`]=== : $1"
}

# generates warn log using log func declared above
function warn {
    log "===[WARN]===[`date +'%F-%T'`]=== : $1"
}

# generates FATAL log using log func declared above
function fatal {
    log "===[FATAL]==[`date +'%F-%T'`]=== : $1"
}