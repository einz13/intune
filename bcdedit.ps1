<# 
.SYNOPSIS
.DESCRIPTION
.EXAMPLE
C:\PS> powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive 
#>

# Start logging
$DefaultLogLocation = "C:\Windows\Logs\BCDEDIT-Change-Log.txt"
Start-Transcript -Path $DefaultLogLocation

# Need to set the $bcdedit variable here based off the return value of the string query of "BCDEDIT | findstr OptIn"

    # If OptIn value detected, proceed to disable the setting. Bitlocker is suspended for one reboot, and then the value is set.
    If ( BCDEDIT | findstr OptIn -eq $true	) {
            Write-Host "OptIn value detected in BCDEDIT, proceed to change settings."
      			Write-Host "Suspending Bitlocker until rebooted, and changing to OptOut" 
            Suspend-Bitlocker C: -RebootCount 1
            BCDEDIT /set "{current}" nx OptOut
            If ( $bcdeditCheck -eq $true ) {
                Write-Host "OptIn still seems to be enabled, check the log for errors: $DefaultLogLocation"
            } Else {
                Write-Host "BCDEDIT values have been changed successfully."
            }
		} Else {
            Write-Host "No OptIn value detected in BCDEDIT, no changes will be made."
        }

#Stop logging
Stop-Transcript
