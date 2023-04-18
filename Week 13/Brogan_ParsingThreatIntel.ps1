# Storyline:

# Array of websites containing threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules', 'https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Loop through the URLs for the rules list
foreach ($u in $drop_urls) {

    # Split the URL with the '/' delimeter
    $temp = $u.split("/")

    # Grab the filename from the array
    $file_name = $temp[-1]

    # Checks if the file to-be-downloaded already exists
    if (Test-Path $file_name) {

        continue

    } else {

        # Download the file
        Invoke-WebRequest -Uri $u -OutFile $file_name

    }

}

# Array containing the filename
$input_paths = @('.\compromised-ips.txt', '.\emerging-botcc.rules')

# Extract the IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list
Select-String -Path $input_paths -Pattern $regex_drop | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

# Get the IP addresses discovered, loop through, and create IPTables or Windows firewall rules via a switch statement
# Then save to a file
$rule_type = Read-Host "Would you like to create IPTables or Windows FW rules with the above IP addresses?`n'i' for IPTables`n'w' for Windows"

switch ( $rule_type ) {
    'i' { 
        # Create IPTables rules
        (Get-Content -Path ".\ips-bad.tmp") | % `
        { $_ -replace "^","iptables -A INPUT -s " -replace "$", " -j DROP" } | `
        Out-File -FilePath "iptables.bash"

    }
    'w' {
        # Create Windows firewall rules
        $firewall_rules = (Get-Content -Path ".\ips-bad.tmp") | ForEach-Object { 
            $subnet = '255.255.255.255'
            $ip = $_
            New-Object -TypeName "System.Management.Automation.PSObject" -Property @{
                'Rule' = "New-NetFirewallRule -RemoteAddress $ip/$subnet -DisplayName 'Block Bad IP: $ip/$subnet' -Direction inbound -Profile Any -Action Block"
            }
        }
        $firewall_rules | Select-Object -ExpandProperty Rule | Out-File -FilePath "C:\Windows-firewall-rules.txt"
}

