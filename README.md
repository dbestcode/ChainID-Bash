# ChainID
---

### overview
---
A simple utitlity to create ID's with block chain security

### dependencies
---
* md5sum
* bash

### setup
---
* Update before you install anything

```sh
        sudo apt update
        Sudo apt upgrade
```


Download the repo file, and run the following commands or read the install.sh file and place the files.

```sh
#clone repo
git clone https://github.com/dbestcode/ChainID-Bash.git
#enter directory
cd ChainID-Bash/
# run install script
./install.sh
```


### getting started
---
* Enter the installed repo directory and run:

```sh
./ChainID.sh
```
The genesis block will always fail and print the following:
```sh
BLOCK          : CZNzUleKVPlwelDWRMi8iswYi1K7pnSX.LOK
DATA VALID     : [32mPASS(B[m
LAST BLOCK     : [31mFAIL(B[m
Genesis Block or FAIL
```

Enter your ID info and the block with be generated.  Next time the utility is run it will rpint and that block will pass.

### todo
---
* Color pass/fail status

* switch statment for operation
    * list blocks
    * add blaock
    * verify chain

