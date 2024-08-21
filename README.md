

# The simfile tool :)

### This is a PowerShell script. Windows users already have PowerShell on their computer. Mac and Linux users can easily install it - instructions are below.

  -----

*With this program, you can do many useful operations related to organization or preparation for pack release, such as:*

1.	File Operations:
•	Retrieve simfiles (`*.sm`, `*.ssc`) from the specified directory.
•	Update specific patterns in the simfiles.
•	Apply or remove the 9ms ITG offset.
•	Delete old backup files (*.old) from the directory.
2.	Field Management:
•	Change the capitalization of specific fields in the simfiles.
•	Change the values of various fields (for example, `#BANNER`, `#GENRE`, or the per-chart Credit field)
3.	File Path Checks:
•	Check for special characters in file paths that might cause issues in PowerShell.
4.	File Renaming for File Sharing:
•	Rename files to remove special characters and updates references within the files.

-----
### How to use
You can run Simfile Tool directly as a PowerShell script. You need to tell it the path of the folder you want to work with. For example:

```
simfile-tool.ps1 "C:\Games\ITGmania\Songs\StepMania 5"
```

- **Windows**: If you can't run the ps1 script in a PowerShell window, you need to enable execution of PowerShell scripts to run the .ps1 file. If you need to allow the operation of scripts, open a PowerShell window as admin and run the following command: 
```
- Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
After running the script, you can set it back to the default Windows 11 mode like so:
```
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine
```

- **Mac**: Mac users can download PowerShell from the Microsoft website or with Homebrew.

- **Linux**: Linux users can refer to their distribution's instructions for the preferred method.
 
------

There are certain limitations to PowerShell. It is very powerful and flexible but its main weakness is its inability to handle the `[` or `]` characters.

- Non-Unicode characters may get broken when using the auto capitalization feature.
- Directories containing the `[` or `]` characters may result in errors (a warning will be displayed if these are detected when the program is run). It is not recommended to use these characters in the file path if you can help it as they are likely to be problematic in any sort of  command-line tools on any OS.


*If you run into any issues, or have any suggestions, please note them on the Issues section!*
