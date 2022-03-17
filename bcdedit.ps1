<# 
.SYNOPSIS

This script will edit the BCDEDIT file on secure boot enabled machines if OptIn is detected, if any other option is detected no changes are made.

.DESCRIPTION

Script flow:
- Saves the nx string to the variable $nx
    - If OptIn is detected, Bitlocker will be suspended and BCDEDIT will be edited.
    - If OptIn is not detected, no changes will be made.
    
Script log data saved to: C:\Windows\Logs\DEP-OptOut-Log.txt

This script is designed to be deployed as an Intune script.

.EXAMPLE
#>

# Start logging
$DefaultLogLocation = "C:\Windows\Logs\DEP-OptOut-Log.txt"
Start-Transcript -Path $DefaultLogLocation

# Need to set the $nx variable here based off the return value of the string query of "BCDEDIT | findstr OptIn"
$nx = BCDEDIT /enum | findstr nx

    # If OptIn value detected, proceed to disable the setting. Bitlocker is suspended for one reboot, and then the value is set.
    If ( $nx -like '*OptIn*' ) {
            Write-Host "OptIn value detected in BCDEDIT, proceed to change settings."
	    Write-Host "Suspending Bitlocker until rebooted, and changing to OptOut" 
            Suspend-Bitlocker C: -RebootCount 1
            BCDEDIT /set "{current}" nx OptOut
	    $nx = BCDEDIT /enum | findstr nx
            If ( $nx -like '*OptIn*' ) {
                Write-Host "OptIn still seems to be enabled, check the log for errors: $DefaultLogLocation"
            } Else {
                Write-Host "BCDEDIT values have been changed successfully."
            	}
	} Else {
            Write-Host "No OptIn value detected in BCDEDIT, no changes will be made."
        }

#Stop logging
Stop-Transcript
