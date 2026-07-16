# The simfile tool :-)

[![PSScriptAnalyzer](https://github.com/sukibaby/simfile-tool/actions/workflows/powershell.yml/badge.svg?branch=main&event=push)](https://github.com/sukibaby/simfile-tool/actions/workflows/powershell.yml)

This script is designed to automate the most tedious and error-prone processes of preparing a StepMania pack for release! It is also equally useful for people looking to make bulk edits to existing simfiles.

***Click [here](https://raw.githubusercontent.com/sukibaby/simfile-tool/refs/heads/main/simfile-tool.ps1), save the script to your computer, and run it! [PowerShell](https://learn.microsoft.com/en-us/powershell/) is required.***

***Run `simfile-tool.ps1` followed by the path to the files. For example:***
```
simfile-tool.ps1 "C:\Games\ITGmania\Songs\StepMania 5"
```

### Features include:

 - Edit multiple simfiles at once with bulk updates for banners, backgrounds, CD titles, credits, and more.
 - Standardize capitalization across song metadata and step artist credits quickly and easily.
 - Apply or remove the 9ms ITG offset quickly.
 - Identify & replace problematic characters in filenames which could cause problems on certain operating systems.
 - Help clean up and prepare your song folders for release with file renaming, compatibility checks, and automatic cleanup of `*.old` files.

## Known issues


### [ and ] characters not supported

A limitation of PowerShell is that it can not reliably process filenames that contain either the `[` or `]` characters.

I do not recommend using the `[` or `]` characters in file names, because they can cause problems with various other tools, or StepMania itself.

### Auto-capitalization feature

Non-Latin script characters may get broken or provide unexpected results when using the auto-capitalization feature.

I recommend scanning for Unicode characters and replacing them if necessary before using auto-capitalization.


### Allowing scripts to run on Windows

By default, Windows does not let you run scripts from sources it does not recognize.

One option is to copy and paste the contents of `simfile-tool.ps1` into your preferred text editor and save it as a .ps1 file.

It's also possible to bypass the script prevention on a case-by-case basis:
```
powershell.exe -ExecutionPolicy Bypass -File .\simfile-tool.ps1 "C:\Games\ITGmania\Songs\StepMania 5"
```
