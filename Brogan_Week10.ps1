do {
    Write-Host "Please choose an option:"
    Write-Host "1. View all services"
    Write-Host "2. View running services"
    Write-Host "3. View stopped services"
    Write-Host "4. Quit"
    $choice = Read-Host "Enter your choice ('all', 'running', 'stopped', 'quit')"

    switch ($choice) {
        'all' {Get-Service}
        'running' {Get-Service | Where-Object {$_.Status -eq "Running"}}
        'stopped' {Get-Service | Where-Object {$_.Status -eq "Stopped"}}
        'quit' {break}
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }

} until ($choice -eq "quit")