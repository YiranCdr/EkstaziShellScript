### Ekstazi Runner

[TOC]

#### 1. File structure

- Res
  - \<projectName\>
    - `*.time.log` - the log file that store time-consuming information, which is actually a csv-format `commitSHA,RunWithoutEkstaziInSec,RunWithMilosEkstaziInSec,RunWithOurEkstaziInSec,ExitCode,`
    - `*.log` - the maven log for all exes, no matter they fail or not. 
  - `ekstaziInsertionOriEkstazi.py` - `pom.xml` injector. Will inject the original ekstazi plugin to root `pom.xml`.
  - `ekstaziInsertion.py` - Will inject our ekstazi plugin to root `pom.xml`
- \<projectName\> - git repositories. 
- `RunPerProj.sh` - use `bash run` to run this script. 

#### 2. Take care at the following checkpoints... 

##### 2.1 RunPerProj.sh

This is the entrance of our script. This script will automatically run 20 successfully-builded reversions on origin/master. 

###### 2.1.1 To run this script...

```bash
bash RunPerProj.sh
```

###### 2.1.2 To specify which project to run

```bash
[line 173] main <projectName>
```

###### 2.1.3 To specify which version of ekstazi to run

```bash
[line 141] run $projectName $logFileName $timeFileName true true false
[line 156] run $projectName $logFileName $timeFileName true true false
```

- First bool var: Whether or not to run the project without ekstazi.
- Second bool var: Whether or not to run the project with the original ekstazi. 
- Third bool var: whether or not to run the project with our ekstazi. 

#### 3. Avaliable projects

You can apply the following projects with test our script. Simply clone the project under this root directory and make modifications mentioned at 2.1.2, and then run `bash RunPerProj.sh` at this root directory. 

- https://github.com/YiranCdr/javapoet
- https://github.com/YiranCdr/commons-cli
- https://github.com/YiranCdr/commons-math
- https://github.com/YiranCdr/commons-net
- https://github.com/YiranCdr/commons-jexl
- https://github.com/YiranCdr/commons-email

