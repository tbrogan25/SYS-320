# Task: Create a prompt that allows the user to specify a keyword or phrase to search on
# Find a string from your event logs to search on

# List all the available Windows Event logs
Get-EventLog -list

# Create a prompt to allow user to select the Log to view
$readLog = Read-host -Prompt "Please select a log to review from the list above"

Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -match "password" } | Export-csv "C:\Users\timothy\Documents\passwordLogs.csv"
