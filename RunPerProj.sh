# Param1: N. Roll back N commits.
rollBackN() {
    # clean untracked files like .ekstazi/*
    git clean -fd
    # Force to checkout, since we may modify pom.xml
    git checkout -f HEAD~$1
}
# Param1: n, current head location
# Safe Method - Unit ready. 
rollBackLastValid() {
    n=$1
    output=''
    while ((${#output} == 0))
    do
        ((n=$n + 1))
        output=$(git diff  --name-only HEAD HEAD~$n -- *.java)
    done
    rollBackN $n
    return $n
}

# Param1: projectName
# Param2: logFileName
# Param3: timeFileName
# Param4: phaseTimeFileName
# Param5: ifExecuteWithoutEkstazi true/false
# Param6: ifExecuteOriginalEkstazi true/false
# Param7: ifExecuteOurEkstazi true/false
run() {
  projectName=$1
  logFileName=$2
  timeFileName=$3
  phaseTimeFileName=$4
  ifExecuteWithoutEkstazi=$5
  ifExecuteOriginalEkstazi=$6
  ifExecuteOurEkstazi=$7
  cp pom.xml ../Res/$1/pom.xml
  printf "$(git rev-parse HEAD)," >> $timeFileName

  # Run without Ekstazi
  if [[ $ifExecuteWithoutEkstazi == true ]]
  then
    start_time=$(python -c "import time; print(int(time.time()*1000))")
    mvn -Drat.ignoreErrors=true -Dcheckstyle.skip clean install >> $logFileName
    mvnExitCode=$?
    end_time=$(python -c "import time; print(int(time.time()*1000))")
    printf `expr $end_time - $start_time` >> $timeFileName
    printf "," >> $timeFileName 
    # Remove color information from logfiles (for maven ouput)
    rm -f "${logFileName}s"
    sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' $logFileName > "${logFileName}s"
    rm $logFileName
    mv "${logFileName}s" $logFileName
    rm "${logFileName}s"
    # Check if maven build successfully
    if [[ "$mvnExitCode" -ne 0 ]] 
    then
      # Print out exe time if the following 2 steps are not exed at all. 
      printf "0,0," >> $timeFileName      
      printf "0,0,0,0,\n" >> $phaseTimeFileName
      return 1
    fi
  else
    printf "0," >> $timeFileName
  fi

  # Run with original Ekstazi
  if [[ $ifExecuteOriginalEkstazi == true ]]
  then
    # Modifiy pom.xml to load ekstazi
    python ../Res/ekstaziInsertionOriEkstazi.py pom.xml 
    rm -rf .ekstazi
    prevEkstaziFolder="../Res/${projectName}/.ekstazi"
    if [[ -d $prevEkstaziFolder ]]
    then
      cp -r $prevEkstaziFolder .ekstazi
    fi
    start_time=$(python -c "import time; print(int(time.time()*1000))")
    mvn -Drat.ignoreErrors=true -Dcheckstyle.skip clean install >> $logFileName
    mvnExitCode=$?
    end_time=$(python -c "import time; print(int(time.time()*1000))")
    printf `expr $end_time - $start_time` >> $timeFileName
    printf "," >> $timeFileName 
    # Remove color information from logfiles (for maven ouput)
    rm -f "${logFileName}s"
    sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' $logFileName > "${logFileName}s"
    rm $logFileName
    mv "${logFileName}s" $logFileName
    rm "${logFileName}s"
    if [[ "$mvnExitCode" -ne 0 ]]
    then
      # Print out exe time if the following 1 step are not exed at all. 
      printf "0," >> $timeFileName
      # If build fail, and tmptimeA.csv exist, record the phase time as 0.
      printf "0,0,0,0,\n" >> $phaseTimeFileName
      return 1
    fi
    # If build success, and tmptimeA.csv exist, record the phase time. 
    timeParseOutput=$(python ../Res/EkstaziTimeParser.py)
    printf "$timeParseOutput\n" >> $phaseTimeFileName
    # if build success, rm the original .ekstazi folder, copy-past the new .ekstazi folder
    rm -rf $prevEkstaziFolder
    cp -r .ekstazi $prevEkstaziFolder
  else
    printf "0," >> $timeFileName
  fi

  # Run with our Ekstazi
  if [[ $ifExecuteOurEkstazi == true ]]
  then
    cp ../Res/$1/pom.xml pom.xml
    python ../Res/ekstaziInsertion.py pom.xml
    # prevEkstaziFolder="../Res/${projectName}/.ekstazi"
    # rm -r -f .ekstazi
    # if [[ -d $prevEkstaziFolder ]]
    # then
    #   cp -r $prevEkstaziFolder .ekstazi
    # fi
    start_time=$(python -c "import time; print(int(time.time()*1000))")
    mvn -Drat.ignoreErrors=true -Dcheckstyle.skip clean install >> $logFileName
    mvnExitCode=$?
    end_time=$(python -c "import time; print(int(time.time()*1000))")
    printf `expr $end_time - $start_time` >> $timeFileName
    printf "," >> $timeFileName 
    # Remove color information from logfiles (for maven ouput)
    rm -f "${logFileName}s"
    sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' $logFileName > "${logFileName}s"
    rm $logFileName
    mv "${logFileName}s" $logFileName
    rm "${logFileName}s"
    if [[ "$mvnExitCode" -ne 0 ]]
    then
      return 1
    fi
  else
    printf "0," >> $timeFileName
  fi

  return 0
}
# Param1: projectName
main() {
  projectName=$1
  cd $projectName
  git clean -fd
  git checkout -f origin/master
  # Make sure that previous ekstazi is removed. 
  rm -rf .ekstazi
  rm -rf ../Res/$projectName/.ekstazi
  time=$(date "+%Y%m%d-%H%M%S")
  # Mainly record maven output
  logFileName="../Res/$projectName/$time.log"
  # a csv file: commitSHA,RunWithoutEkstaziInSec,RunWithMilosEkstaziInSec,RunWithOurEkstaziInSec,ExitCode,
  timeFileName="../Res/$projectName/$time.time.log"
  # Add a title for timeFileName
  printf "commitSHA,RunWithoutEkstaziInSec,RunWithMilosEkstaziInSec,RunWithOurEkstaziInSec,ExitCode,\n" >> $timeFileName
  # Record time per phase. 
  # With Csv format - ATime, ETime, CTime, TestClassNum, 
  phaseTimeFileName="../Res/$projectName/$time.phase.time.log"
  # Add a title for phaseTimeFileName
  printf "ATime,ETime,CTime,TestClassNum,\n" >> $phaseTimeFileName
  # If folder exists, -p will skip this mkdir.
  mkdir -p ../Res/$projectName
  # Remove the initial .ekstazi folder, if exist.
  rm -rf ../Res/$projectName/.esktazi
  lastValidSha=$(git rev-parse HEAD)
  round=20
  run $projectName $logFileName $timeFileName $phaseTimeFileName true true false
  # If the above line fails, -1 will be added as the exitcode. Otherwise, 0. 
  if [[ "$?" -ne 0 ]]
  then
    printf "1,\n" >> $timeFileName
    round=1+$round
  else
    printf "0,\n" >> $timeFileName 
  fi
  # for the residual 19 reversions - 
  rollbackNum=0
  while (($round>=2))
  do
    ((round=$round-1))
    rollBackLastValid $rollbackNum
    rollbackNum=$?
    run $projectName $logFileName $timeFileName $phaseTimeFileName true true false
    if [[ "$?" -ne 0 ]]
    then
      printf "1,\n" >> $timeFileName
      ((round=$round+1))
      git clean -fd
      git checkout -f $lastValidSha
    else
      printf "0,\n" >> $timeFileName 
      lastValidSha=$(git rev-parse HEAD)
      rollbackNum=0
    fi
  done
}
# Param1: project name
# main $1
main javapoet
# main commons-math
# main commons-cli
# main javapoet
# main commons-email
# main commons-jexl
# main commons-validator
# main commons-net