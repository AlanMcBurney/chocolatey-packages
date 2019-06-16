﻿$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$isoPackageName = 'veeam-backup-and-replication-iso'
$scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$commonPath = $(Split-Path -parent $(Split-Path -parent $scriptPath))
$filename = 'VeeamBackup&Replication_9.5.4.2753.Update4a.iso'
$installPath = Join-Path  (Join-Path $commonPath $isoPackageName) $filename

$fileLocation = 'Backup\Shell.x64.msi'
$updateFileVersion = ($filename -replace 'VeeamBackup&Replication_' -replace '.iso').ToLower()
$updateFileLocation = "Updates\veeam_backup_$($updateFileVersion)_setup.exe"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  isoFile        = $installPath
  softwareName   = 'Veeam Backup & Replication Console*'
  file           = $fileLocation
  fileType       = 'msi'
  silentArgs     = "ACCEPTEULA=YES ACCEPT_THIRDPARTY_LICENSES=1 /qn /norestart /l*v `"$env:TEMP\$env:ChocolateyPackageName.$env:ChocolateyPackageVersion.log`""
  validExitCodes = @(0,1641,3010)
  destination    = $toolsDir
}

Install-ChocolateyIsoInstallPackage @packageArgs

# An update file is provided in the ISO. This should be executed after
# the installation of the software.
# This update file contains an update to all available software on the
# ISO and should be executed After each installation.
#
# This should be in a seperate package, but you can't trigger / force a
# dependency after the installation Therefore I need to trigger it this way.
If ($filename -Match "Update") {
  $updatePackageArgs = @{
    packageName    = $env:ChocolateyPackageName
    isoFile        = $installPath
    softwareName   = $packageArgs['softwareName']
    file           = $updateFileLocation
    fileType       = 'exe'
    silentArgs     = "VBR_AUTO_UPGRADE=1 /silent /noreboot /log `"$env:TEMP\$env:ChocolateyPackageName.$env:ChocolateyPackageVersion.log`""
    validExitCodes = @(0,1641,3010)
    destination    = $toolsDir
  }

  Install-ChocolateyIsoInstallPackage @updatePackageArgs
}
