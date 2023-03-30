# Task: Grab the DHCP and DNS server information using a WMI class

Get-WmiObject Win32_NetworkAdapterConfiguration | Select DHCPServer, DNSServerSearchOrder

# Task: Export the list of running processes and services into respective files

## Processes

Get-Process | Export-Csv -Path "C:\processes.csv" -NoTypeInformation

## Services

Get-Service | Export-Csv -Path "C:\services.csv" -NoTypeInformation

# Task: Start and stop Windows Calculator using the process name

## Starting calc.exe

Start-Process calc.exe

## Stopping calc.exe

#Stop-Process -Name Calculator


