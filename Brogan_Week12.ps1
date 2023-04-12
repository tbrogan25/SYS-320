# Storyline: Create an Incident Response Toolkit that retrieves:
# Running processes and their respective paths
# Running services and their executable paths
# TCP network sockets
# User account info
# Network adapater info
# 4 additional useful PowerShell cmdlets

# Function:
# Prompts user for the directory location where the above information will be saved
function Get-OutputLocation {
    $location = Read-Host "Enter the location to save the output file:"
    if (-not (Test-Path $location)) {
        Write-Host "Invalid location. Please try again."
        Get-OutputLocation
    }
    return $location
}

Get-OutputLocation

#  Running Processes and the path for each process. 
Get-Process | Select-Object Name,Path | Export-Csv "$location\running_processes.csv" -NoTypeInformation -Encoding UTF8 -Force

# All registered services and the path to the executable controlling the service (you'll need to use WMI).
Get-WmiObject -Class Win32_Service | Select-Object Name, DisplayName, PathName | Export-Csv $location\running_services.csv -NoTypeInformation -Encoding UTF8 -Force

# All TCP network sockets
Get-NetTCPConnection | Export-Csv $location\sockets.csv -NoTypeInformation -Encoding UTF8 -Force

# All user account information (you'll need to use WMI)
Get-WmiObject -Class Win32_UserAccount | Export-Csv $location\users.csv -NoTypeInformation -Encoding UTF8 -Force

# All NetworkAdapterConfiguration information.
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Select-Object IPAddress, DefaultIPGateway, DHCPEnabled, DNSDomain, DNSHostName, DNSServerSearchOrder, IPSubnet, MACAddress |  Export-Csv $location\network.csv -NoTypeInformation -Encoding UTF8 -Force 

# All scheduled tasks
# Useful due to the commonality of attackers creating scheduled Windows tasks to execute malicious code
Get-ScheduledTask |  Export-Csv $location\schedules.csv -NoTypeInformation -Encoding UTF8 -Force

# 100 latest Windows Security event logs for successful login
# Useful to determine whether an unused or default account has logged in
Get-EventLog -LogName Security -InstanceId 4624 -Newest 100 |  Export-Csv $location\password_security_logs.csv -NoTypeInformation -Encoding UTF8 -Force

# 50 latest Windows System event logs for unexpected shutdowns or restarts
# Useful to determine whether a system has been restarted because of malicious activity 
Get-EventLog -LogName System -InstanceId 41 -Newest 50 | Export-Csv $location\system_logs.csv -NoTypeInformation -Encoding UTF8 -Force

# 30 latest Windows Security event logs for attempts to start a process that requires Administrative privileges
# Useful to determine whether an attacker has tried to run software or scripts that require Admin privileges
Get-EventLog -LogName Security -InstanceId 4672 -Newest 30 |  Export-Csv $location\admin_security_logs.csv -NoTypeInformation -Encoding UTF8 -Force

###################

# File hashes

# Get a list of CSV files in the directory specified in function
$csvFiles = Get-ChildItem -Path $location -Filter *.csv

# echo $csvFiles

# Create an empty array to store the results
$results = @()

# Loop through each CSV file and create a hash
foreach ($csvFile in $csvFiles) {
    $hash = Get-FileHash -Path $csvFile.FullName -Algorithm SHA256
    # Add the filename and hash to the results array
    $results += [PSCustomObject]@{
        Filename = $csvFile.Name
        Checksum = $hash.Hash
    }
}

# Save the results to a file
$results | Export-Csv -Path "$location\Checksums.csv" -NoTypeInformation

# Zip above directory to a new folder on my desktop
Compress-Archive -Path "$location" -DestinationPath "C:\Users\Tim\Desktop\SYS-320"

# Create checksum of above zipped file 
Get-FileHash -Path "C:\Users\Tim\Desktop\SYS-320" -Algorithm SHA256 | Out-File -FilePath "C:\Users\Tim\Desktop\SYS-320-Hash"