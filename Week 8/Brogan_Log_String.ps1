# Task: Create a prompt that allows the user to specify a keyword or phrase to search on
# Find a string from your event logs to search on

# List all the available Windows Event logs
Get-EventLog -list

# Create a prompt to allow user to select the Log category to view
$readLog = Read-host -Prompt "Please select a log to review from the list above"

# Allows user to select all logs from the aforementioned category that contain a user-specified string
$stringLog = Read-host -Prompt "Choose a string to search for within the $readLog log category"

# Gets the newest 40 logs from the user-specified log that contains the user-specified string and outputs to a file
Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -match $stringLog } | Export-csv "C:\Users\timothy\Documents\${stringLog}Logs.csv"