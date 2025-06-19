<# Sukibaby's Simfile Tool
   https://github.com/sukibaby/simfile-tool

   You can run the script directly like so:

   PS C:\Users\Stepper\Downloads> & '.\simfile-tool.ps1' "C:\Games\StepMania 5\Songs\In The Groove"   #>

#region BEGINNING OF PROGRAM
param(
  [Parameter(Position = 0)]
  [string]$directoryToUse
)

if ($null -ne $directoryToUse) {
  $directoryToUse = $directoryToUse.Replace("`"", "'")
}

Write-Verbose " ~ Version 8/20/2024 v2 ~"
Write-Verbose "Check for new versions at:"
Write-Verbose "https://github.com/sukibaby/simfile-tool"
Write-Verbose ""
Write-Verbose "Be sure to make a backup of your files first."
Write-Verbose ""

#endregion

#region FUNCTION Get-Directory
function Get-Directory {
  param($dir)
  if (!$dir -or $dir -eq "" -or !(Test-Path $dir -PathType Container)) {
    Write-Verbose "No directory provided."
    if (!$dir -or $dir -eq "" -or !(Test-Path $dir -PathType Container)) {
      Write-Verbose "Press any key to exit..."
      $null = Read-Host
      exit
    }
  }
  return $dir
}

# METHOD TO GET DIRECTORY
$directoryToUse = Get-Directory -dir $directoryToUse
if ($null -eq $directoryToUse) {
  return
}
#endregion

#region FUNCTION Write-Separator
function Write-Separator {
  Write-Verbose ""
  Write-Verbose "--------------------------------------------------"
  Write-Verbose ""
}
#endregion

#region FUNCTION Get-File
function Get-File {
  param($dir, $rec)
  Get-ChildItem $dir -Include *.sm, *.ssc -Recurse:$rec
}
#endregion

#region FUNCTION Update-Field-Capitalization, Update-Capitalization, Update-Capitalization-StepArtist
# The result of the prompt is a global variable so it can be reused if Update-Capitalization-StepArtist is called.
function Update-Field-Capitalization {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($dir, $rec, $field)
  Write-Verbose ""
  $changeField = Read-Host -Prompt "Would you like to change the $field field capitalization? (yes/no, default is no)"
  if ($changeField -eq 'yes') {
    $global:capitalizationPromptAnswer = Read-Host -Prompt "Please enter one of the following switches: u (uppercase), t (title case), l (lower case)"
    if ($global:capitalizationPromptAnswer -notin @("u", "t", "l")) {
      Write-Error "Invalid switch: $global:capitalizationPromptAnswer. Please provide one of the following switches: u (uppercase), t (title case), l (lower case)"
      return
    }
    if ($field -eq "STEPARTIST") {
      Update-Capitalization-StepArtist -StepArtist_dir $dir -StepArtist_rec $rec
    }
    else {
      Update-Capitalization -dir $dir -rec $rec -field $field -switch $global:capitalizationPromptAnswer
    }
  }
}

function Update-Capitalization {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($dir, $rec, $field, $switch)
  $files = Get-File -dir $dir -rec $rec
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    $found = $false
    $content = $content | ForEach-Object {
      if (!$found -and ($_ -match "#$field")) {
        $parts = $_ -split ':'
        switch ($switch) {
          "u" { $parts[1] = $parts[1].ToUpper() }
          "t" { $parts[1] = (Get-Culture).TextInfo.ToTitleCase($parts[1].ToLower()) }
          "l" { $parts[1] = $parts[1].ToLower() }
        }
        $found = $true
        return ($parts -join ':')
      }
      return $_
    }
    Set-Content -Path $file.FullName -Value $content
  }
}

function Update-Capitalization-StepArtist {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($StepArtist_dir, $StepArtist_rec)
  $StepArtist_files = Get-File -dir $StepArtist_dir -rec $StepArtist_rec
  foreach ($StepArtist_file in $StepArtist_files) {
    $StepArtist_content = Get-Content -LiteralPath $StepArtist_file.FullName
    for ($i = 0; $i -lt $StepArtist_content.Length; $i++) {
      if ($StepArtist_content[$i] -match "//---------------(dance-.*) - (.*?)----------------") {
        $matchedGroup = $Matches[2]
        switch ($global:capitalizationPromptAnswer) {
          "u" { $StepArtist_content[$i] = $StepArtist_content[$i].Replace($matchedGroup, $matchedGroup.ToUpper()) }
          "t" { $StepArtist_content[$i] = $StepArtist_content[$i].Replace($matchedGroup, (Get-Culture).TextInfo.ToTitleCase($matchedGroup.ToLower())) }
          "l" { $StepArtist_content[$i] = $StepArtist_content[$i].Replace($matchedGroup, $matchedGroup.ToLower()) }
        }
      }
    }
    Set-Content -Path $StepArtist_file.FullName -Value $StepArtist_content
  }
}
#endregion

#region FUNCTION Update-Content, Update-Offset, Update-File
function Update-Content {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($dir, $rec, $pattern, $replacement)
  $files = Get-File -dir $dir -rec $rec
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    for ($i = 0; $i -lt $content.Length; $i++) {
      if ($content[$i] -match $pattern) {
        $content[$i] = $content[$i] -replace $pattern, $replacement
        break
      }
    }
    Set-Content -LiteralPath $file.FullName -Value $content
  }
}

function Update-Offset {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($dir, $rec)
  $files = Get-File -dir $dir -rec $rec
  $operation = Read-Host "Do you want to add or subtract the 9ms ITG offset? (add/subtract/no)"
  $adjustment = switch ($operation) {
    "add" { 0.009 }
    "subtract" { -0.009 }
    default {
      Write-Verbose "No adjustment will be made."
      return
    }
  }
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    $found = $false
    $content = $content | ForEach-Object {
      if (!$found -and ($_ -match "#OFFSET")) {
        $parts = $_ -split ':'
        $semicolon = $parts[1].EndsWith(';')
        $parts[1] = $parts[1].TrimEnd(';')
        $oldOffset = $parts[1]
        $parts[1] = [double]$parts[1] + $adjustment
        if ($semicolon) {
          $parts[1] = $parts[1].ToString() + ';'
        }
        $found = $true
        Write-Verbose "Changed offset in $($file.FullName) from $oldOffset to $($parts[1])"
        return ($parts -join ':')
      }
      return $_
    }
    Set-Content -Path $file.FullName -Value $content
  }
}

function Update-File {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($file, $operations)
  $content = Get-Content -LiteralPath $file.FullName
  $contentModified = $false

  foreach ($operation in $operations) {
    $pattern = $operation.Pattern
    $replacement = $operation.Replacement
    $appendIfNotFound = $operation.AppendIfNotFound -or $false

    $found = $false
    for ($i = 0; $i -lt $content.Length; $i++) {
      if ($content[$i] -match $pattern) {
        Write-Verbose "Replacing '$($content[$i])' with '$replacement'"
        $content[$i] = $content[$i] -replace $pattern, $replacement
        $found = $true
        $contentModified = $true
      }
    }

    if ($appendIfNotFound -and -not $found) {
      Write-Verbose "Appending '$replacement' to the file."
      $content += $replacement
      $contentModified = $true
    }
  }

  if ($contentModified) {
    Set-Content -LiteralPath $file.FullName -Value $content
  }
}

#endregion

#region FUNCTION Test-FilePath, Remove-OldFile
function Test-FilePath {
  param($dir)
  $files = Get-ChildItem $dir -Recurse -File
  $containsSpecialChars = $false
  foreach ($file in $files) {
    if ($file.FullName -match '\[|\]') {
      $containsSpecialChars = $true
      break
    }
  }
  if ($containsSpecialChars) {
    Write-Warning @"
   One or more file paths contain `[` or `]`.

            Unfortunately, PowerShell doesn't handle square brackets well.

            Some operations will not succeed with these
            characters present in the file path.

            Please rename those files, and then run the tool again.
"@
  }
}

function Remove-OldFile {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param($targetDir)
  if (!(Test-Path -Path $targetDir)) {
    Write-Verbose "The directory `"$targetDir`" does not exist."
    return
  }
  $oldFileList = Get-ChildItem -Path $targetDir -Recurse -Filter "*.old"
  if ($oldFileList) {
    Write-Verbose "The following .old files were found:"
    foreach ($oldFile in $oldFileList) {
      Write-Verbose "`"$($oldFile.FullName)`""
    }
    $firstCheckMessage = "Do you want to remove all of the above files? (yes/no, default is no)"
    $userResponse = Read-Host -Prompt $firstCheckMessage
    if ($userResponse -eq 'yes') {
      $doubleCheckMessage = "Are you sure you want to delete these files? (yes/no, default is no)"
      $doubleCheckResponse = Read-Host -Prompt $doubleCheckMessage
      if ($doubleCheckResponse -eq 'yes') {
        foreach ($oldFile in $oldFileList) {
          Remove-Item -Path $oldFile.FullName
        }
        Write-Verbose "All .old files have been removed."
      }
      else {
        Write-Verbose "No files were removed."
      }
    }
    else {
      Write-Verbose "No files were removed."
    }
  }
  else {
    Write-Verbose "No .old files found in `"$targetDir`"."
  }
}
#endregion

#region FUNCTION Convert-FilenamesForFilesharing
function Convert-FilenamesForFilesharing {
  param($dir, $rec)
  # If I missed any file types that we should look for, they can be added here.
  $files = Get-ChildItem $dir -Include *.sm, *.ssc, *.mp3, *.ogg, *.png, *.gif, *.jpg, *.jpeg -Recurse:$rec

  # First, rename all the files in the directory
  $renamedFiles = @{}
  foreach ($file in $files) {
    $newFileName = $file.Name -replace '[^a-zA-Z0-9._]', '_'
    try {
      Rename-Item -LiteralPath $file.FullName -NewName $newFileName -ErrorAction Stop
      $renamedFiles[$file.FullName] = Join-Path $file.Directory $newFileName
      Write-Verbose "Renamed file '$($file.FullName)' to '$newFileName'"
    }
    catch {
      Write-Warning "Failed to rename file '$($file.FullName)' to '$newFileName'. Error: $_"
      Write-Warning "Values in the simfile will not be changed."
      return
    }
  }

  # Refresh the $files variable
  $files = Get-ChildItem $dir -Include *.sm, *.ssc, *.mp3, *.ogg, *.png, *.gif, *.jpg, *.jpeg -Recurse:$rec

  # Then, update the references in each file
  foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName
    $content = $content | ForEach-Object {
      if ($unnamedVariable -match "#MUSIC" -or $unnamedVariable -match "#BANNER" -or $unnamedVariable -match "#BACKGROUND" -or $unnamedVariable -match "#CDTITLE") {
        $parts = $unnamedVariable -split ':', 2
        $parts[1] = $parts[1].TrimStart().Replace(' ', '_')
        $unnamedVariable = $parts -join ':'
      }
      $unnamedVariable
    }
    Set-Content -LiteralPath $file.FullName -Value $content
  }
}
#endregion

#region USER INPUT Get Subdirectory Query
$recursePrompt = Read-Host -Prompt "Do you want to search in subdirectories as well? (yes/no, default is yes)"
$recurseOption = $recursePrompt -ne "no"
Write-Verbose ""

$simFiles = Get-File -dir $directoryToUse -Recurse $recurseOption
if ($simFiles.Count -eq 0) {
  Write-Verbose "No simfiles were found. Exiting..."
  exit
}

$displayFilesPrompt = Read-Host -Prompt 'Would you like to see the complete list of files that will be modified? (yes/no, default is yes)'
if ($displayFilesPrompt -ne 'no') {
  Write-Verbose ""
  Write-Verbose "The following files will be modified."
  Write-Verbose "Please note you'll get a chance to confirm changes before they are applied."
  $simFiles | ForEach-Object { Write-Verbose $_.FullName }
}

Write-Verbose ""
Test-FilePath -dir $directoryToUse
Write-Separator # End every region in this section with a Write-Separator so everything looks nice.
#endregion

#region USER INPUT ISO-8859-1 Verification
Write-Verbose "To ensure compatibility with all versions of StepMania/ITG, you can check for characters which may not be rendered correctly."
Write-Verbose ""
$encoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$unicodeCheckParams = @{
  Prompt         = 'Would you like to check for Unicode characters? (yes/no, default is no)'
  AsSecureString = $false
}
$unicodeCheckInput = Read-Host @unicodeCheckParams
if ($unicodeCheckInput -eq 'yes') {
  $unicodeFiles = Get-File -dir $directoryToUse -Recurse $recurse
  $nonUnicodeCompliantFiles = @()
  foreach ($file in $unicodeFiles) {
    $fileContent = Get-Content -Path $file.FullName | Out-String
    $convertedContent = $encoding.GetString($encoding.GetBytes($fileContent))
    if ($convertedContent -ne $fileContent) {
      $nonUnicodeCompliantFiles += $file.FullName
    }
  }

  if ($nonUnicodeCompliantFiles.Count -eq 0) {
    Write-Verbose "Check completed successfully. No problematic characters were found."
  }
  else {
    $nonUnicodeCompliantFiles
  }
}
else {}

Write-Separator
#endregion

#region USER INPUT Capitalization
$wannaCapitalize = Read-Host -Prompt 'Would you like to standardize capitalization? (yes/no, default is no)'
Write-Verbose "Note: This function may break Unicode-only characters."
if ($wannaCapitalize -eq 'yes') {
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "TITLE"
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "SUBTITLE"
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "ARTIST"
  Update-Field-Capitalization -dir $directoryToUse -rec $recurse -field "STEPARTIST"
}

Write-Separator
#endregion

#region USER INPUT Offset Adjustment
Update-Offset -dir $directoryToUse -rec $recurse
Write-Separator
#endregion

#region USER INPUT Adjust Values In Simfile
$operations = @()

$wannaMessage = @"
  The following section changes the text values inside the simfile. It won't
  move any files. For example, if you plan to have a banner called 'banner.png'
  in all your song directories, you would enter banner.png when prompted. You
  can change the banner, CD title, background, step artist, and credit fields
  here.
"@

Write-Verbose $wannaMessage
$wannaModify = Read-Host -Prompt 'Would you like to modify any of these values? (yes/no, default is no)'
if ($wannaModify -eq 'yes') {
  Write-Verbose ""
  $addBanner = Read-Host -Prompt 'Would you like to add a banner to all files? (yes/no, default is no)'
  if ($addBanner -eq 'yes') {
    $bannerPrompt = Read-Host -Prompt 'Enter the banner file name, including extension'
    $operations += @{ Pattern = '^#BANNER:.*?;'; Replacement = "#BANNER:$bannerPrompt;" }
  }

  Write-Verbose ""
  $addCDTitle = Read-Host -Prompt 'Would you like to add a CD title to all files? (yes/no, default is no)'
  if ($addCDTitle -eq 'yes') {
    $CDTitlePrompt = Read-Host -Prompt 'Enter the CD title file name, including extension'
    $operations += @{ Pattern = '^#CDTITLE:.*?;'; Replacement = "#CDTITLE:$CDTitlePrompt;" }
  }

  Write-Verbose ""
  $addBG = Read-Host -Prompt 'Would you like to add a background to all files? (yes/no, default is no)'
  if ($addBG -eq 'yes') {
    $BGPrompt = Read-Host -Prompt 'Enter the background file name, including extension'
    $operations += @{ Pattern = '^#BACKGROUND:.*?;'; Replacement = "#BACKGROUND:$BGPrompt;" }
  }

  Write-Verbose ""
  $setStepArtist = Read-Host -Prompt 'Would you like to set something for the step artist field? This is the per-chart credit. (yes/no, default is no)'
  if ($setStepArtist -eq 'yes') {
    $stepArtist = Read-Host -Prompt 'Enter the credit value'
    <# To-do: add more chart types below (pump, smx, etc) #>
    $danceTypes = @("dance-single", "dance-double", "dance-couple", "dance-solo")
    foreach ($danceType in $danceTypes) {
      $operations += @{ Pattern = "//--------------- $danceType - (.*?) ----------------"; Replacement = "//--------------- $danceType - $stepArtist ----------------" }
    }
  }

  Write-Verbose ""
  $setCredit = Read-Host -Prompt 'Would you like to set something for the credit field? (This is the #CREDIT field for the simfile, not the per-chart "Step artist" field.) (yes/no, default is no)'
  if ($setCredit -eq 'yes') {
    $creditValue = Read-Host -Prompt 'Enter the credit value'
    $operations += @{ Pattern = '^#CREDIT:.*?;'; Replacement = "#CREDIT:$creditValue;" }
  }

  Write-Verbose ""
  $addGenre = Read-Host -Prompt 'Would you like to apply a genre to these files? (yes/no, default is no)'
  if ($addGenre -eq 'yes') {
    $GenrePrompt = Read-Host -Prompt 'Enter the genre'
    $operations += @{ Pattern = '^#GENRE:.*?;'; Replacement = "#GENRE:$GenrePrompt;"; AppendIfNotFound = $true }
  }

  $files = Get-File -dir $directoryToUse -Recurse $recurse
  Write-Verbose ""
  $confirmation = Read-Host "Are you sure you want to apply changes? (yes/no, default is no)"
  Write-Verbose ""
  if ($confirmation -eq "yes") {
    foreach ($file in $files) {
      Write-Verbose "Applying changes to file: $($file.FullName)"
      Update-File -File $file -operations $operations
    }
  }
  else {
    Write-Verbose "No changes were made."
  }
}

Write-Separator
#endregion

#region USER INPUT Remove .old Files
$oldFilesConfirm = Read-Host -Prompt 'Would you like to check for .old files and remove them if found? (yes/no, default is no)'
if ($oldFilesConfirm -eq 'yes') {
  Remove-OldFile -targetDir $directoryToUse -Recurse $recurse
}
else {
  Write-Verbose ""
}

Write-Separator
#endregion

#region USER INPUT Portable Filenames
$wannaMessage = @"
  The following section changes the text values inside the simfile. It won't
  move any files. For example, if you plan to have a banner called 'banner.png'
  in all your song directories, you would enter banner.png when prompted. You
  can change the banner, CD title, background, step artist, and credit fields
  here.

"@

Write-Verbose $renameFilesForSharingMessage
$renameFilesForSharingConfirm = Read-Host -Prompt 'Would you like to check for spaces and special characters and rename the files? (yes/no, default is no)'
if ($renameFilesForSharingConfirm -eq 'yes') {
  Convert-FilenamesForFilesharing -dir $directoryToUse -rec $recurse
}
else {
  Write-Verbose ""
}
Write-Separator
#endregion

#region END OF PROGRAM
# Tell the user everything succeeded.
Write-Verbose "All done :)"
#endregion
