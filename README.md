


# The simfile tool :-)

[![PSScriptAnalyzer](https://github.com/sukibaby/simfile-tool/actions/workflows/powershell.yml/badge.svg?branch=main&event=push)](https://github.com/sukibaby/simfile-tool/actions/workflows/powershell.yml)

You will need PowerShell installed to run this script.

### Features:

 - Retrieve simfiles (`*.sm`, `*.ssc`) from the specified directory.
 -    Update specific patterns in the simfiles. 
 - Apply or remove the 9ms ITG   offset. 
 -    Delete old backup files (*.old) from the directory. 
 -    Change   the capitalization of specific fields in the simfiles. 
 -    Change the   values of various fields (for example, `#BANNER`, `#GENRE`, or the
   per-chart Credit field) 
   - Check for special characters in file paths   that might cause various issues. 
   - Rename files to remove special   characters and updates references within the files.

-----
### How to use

You can run Simfile Tool directly as a PowerShell script. You need to tell it the path of the folder you want to work with. 

If you are on Windows, you already have PowerShell installed.

![image](https://github.com/user-attachments/assets/c470011f-4aa5-4bab-bd99-b57d137db525)


If you are on Mac or Linux, you will need to install PowerShell.

There are many valid and correct ways to install PowerShell. Any method you choose will allow you to use this script.

 - https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.4
 -    https://github.com/PowerShell/powershell/releases

### Usage

Simply run `simfile-tool.ps1` and then tell it which directory you want to work with.
If you wanted to modify the StepMania 5 song folder:
```
simfile-tool.ps1 "C:\Games\ITGmania\Songs\StepMania 5"
```

### Allowing scripts on Windows

By default, Windows does not let you run scripts from sources it does not recognize.

The easiest way is to allow scripts.  Open a PowerShell window as Administrator and run the following command.

```
Set-ExecutionPolicy Bypass -Scope LocalMachine
```





The following command will restore the original Windows settings blocking scripts:
```
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine
```

It's also possible to run it without changing the system policy like so:
```
powershell.exe -ExecutionPolicy Bypass -File .\simfile-tool.ps1 "C:\Games\ITGmania\Songs\StepMania 5"
```


### Known problems

- The `[` or `]` characters should not be used in file names because they cause problems with various tools, including this script.
- Non-Unicode characters may get broken when using the auto capitalization feature.
