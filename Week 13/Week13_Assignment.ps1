# Login to a remote SSH server with specified user credentials. You will be prompted for a password.
New-SSHSession -ComputerName '192.168.4.22' -Credential (Get-Credential sys320)

while ($True) {

    # Add a prompt to run user-specific commands
    $the_cmd = read-host -Prompt "Please enter a command"

    # Run the aforementioned command on remote SSH server
    (Invoke-SSHCommand -index 0 $the_cmd).Output

}

# Retrieve a specific local file from a remote server using SCP
Get-SCPFile -ComputerName '192.168.4.22' -Credential (Get-Credential sys320) -RemotePath '/home/sys320' -LocalFile '.\tedx.jpeg'
