### Ekstazi Runner

[TOC]

#### 1. File structure

- Res
  - \<projectName\>
    - `*.time.log` - the log file that store time-consuming information, which is actually a csv-format `commitSHA,RunWithoutEkstaziInSec,RunWithMilosEkstaziInSec,RunWithOurEkstaziInSec,ExitCode,`
    - `*.log` - the maven log for all exes, no matter they fail or not. 
    - `*.phase.time.log` - the log file that store time-consuming information for AEC phases separately, which is actually a csv-format `ATime,ETime,CTime,TestClassNum`.
  - `ekstaziInsertionOriEkstazi.py` - `pom.xml` injector. Will inject the original ekstazi plugin to root `pom.xml`.
  - `ekstaziInsertion.py` - Will inject our ekstazi plugin to root `pom.xml`
- \<projectName\> - git repositories. 
- `RunPerProj.sh` - use `bash run` to run this script. 

#### 2. Take care at the following checkpoints... 

##### 2.1 RunPerProj.sh

This is the entrance of our script. This script will automatically run 20 successfully-builded reversions on origin/master. 

###### 2.1.1 To run this script...

```bash
bash RunPerProj.sh <param1> <param2> <param3>
```

All the params are Boolean ("true" or "false"). 

- **param1** whether or not to run without Ekstazi. Default value is false.
- **param2** whether or not to run the original version of Ekstazi (if you have Ekstazi 5.3.0 on your computer). Default value is false.
- **param3** whether or not to run the our modified version of Ekstazi. Default value is true.

For example, you can run in the following manner:

```bash
bash RunPerProj true false false
```

###### 2.1.2 To specify which project to run

```bash
[line 226-232] main <projectName> $ifWithout $ifOri $ifModif 
```

#### 3. Avaliable projects

You can apply the following projects with test our script. Simply clone the project under this root directory and make modifications mentioned at 2.1.2, and then run `bash RunPerProj.sh` at this root directory. 

- https://github.com/YiranCdr/javapoet
- https://github.com/YiranCdr/commons-cli
- https://github.com/YiranCdr/commons-math
- https://github.com/YiranCdr/commons-net
- https://github.com/YiranCdr/commons-jexl
- https://github.com/YiranCdr/commons-email

For more details about how to run the project, check this [link](https://github.com/YiranCdr/ys23933-EE382V-Software-Evolution-Proj#3-how-can-i-run-your-work).

#### 4. Update Log

##### v1.0

Original submersion

##### v1.0.1

Remove color-format output for `$logFileName`. 

##### v1.1.0

Add phase time counter. Now you can calculate AEC time separately. If your ekstazi doesn't support phase time counting, this new function won't affect the original functions. 

##### v1.2.0

Now time.log shows millisecond

##### v1.2.1

Move "which version to run Ekstazi" to command line. Check 2.2.1. 