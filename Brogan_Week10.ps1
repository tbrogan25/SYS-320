# Storyline: Provide all, running, or stopped services based on user input
# 1. Print options to user
# 2. Create switch that responds to each user input
# 3. Quit when specified

do {
    # Prints options to user
    Write-Host "Please choose an option:"
    Write-Host "1. View all services"
    Write-Host "2. View running services"
    Write-Host "3. View stopped services"
    Write-Host "4. Quit"
    # Reads user input
    $choice = Read-Host "Enter your choice ('all', 'running', 'stopped', 'quit')"

    switch ($choice) {
        # Responds with specific services based on user-inputted string
        'all' {Get-Service}
        'running' {Get-Service | Where-Object {$_.Status -eq "Running"}}
        'stopped' {Get-Service | Where-Object {$_.Status -eq "Stopped"}}
        'quit' {break}
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
# Quits when user specifies
} until ($choice -eq "quit")

