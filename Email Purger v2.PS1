<# * FUNCTIONS AND VARIABLES #>
Clear-Host
# Check for Updates on Powershell Module
try {
    Write-Host "[+] Checking for updates on the ExchangeOnlineManagement module..." -ForegroundColor Yellow
    Update-Module -Name ExchangeOnlineManagement -ErrorAction Stop
    Write-Host "[+] Done"
}
catch {
    Write-Host "[!] There was an error updating the ExchangeOnlineManagement module..." -ForegroundColor Red
    throw $_
}

function DisplaySetupConfiguration {
Clear-Host
Start-Sleep -Milliseconds 100 # to load colors
Write-Host "___________              .__.__    __________                                  " -ForegroundColor "Red"
Write-Host "\_   _____/ _____ _____  |__|  |   \______   \__ _________  ____   ___________ " -ForegroundColor "Red"
Write-Host " |    __)_ /     \\__  \ |  |  |    |     ___/  |  \_  __ \/ ___\_/ __ \_  __ \" -ForegroundColor "Magenta"
Write-Host " |        \  Y Y  \/ __ \|  |  |__  |    |   |  |  /|  | \/ /_/  >  ___/|  | \/" -ForegroundColor "Magenta"
Write-Host "/_______  /__|_|  (____  /__|____/  |____|   |____/ |__|  \___  / \___  >__|   " -ForegroundColor "Magenta"
Write-Host "        \/      \/     \/                                /_____/      \/       " -ForegroundColor "Magenta"
Write-Host "" # empty line for space
Write-Host "== Current Search Settings ==" -ForegroundColor Cyan

Write-Host "Admin Email:          " -NoNewline
if ($UserPrincipalName -eq "") {
    Write-Host "Not configured yet" -ForegroundColor "DarkGray"
} else {
    Write-Host "$UserPrincipalName" -ForegroundColor "Yellow"
}

Write-Host "Sender From Address:  " -NoNewline
if ($fromAddress -eq "") {
    Write-Host "Not configured yet" -ForegroundColor "DarkGray"
} else {
    Write-Host "$fromAddress" -ForegroundColor "Yellow"
}

Write-Host "Sender Email Subject: " -NoNewline
if ($emailSubject -eq "") {
    Write-Host "Not configured yet" -ForegroundColor "DarkGray"
} else {
    Write-Host "$emailSubject" -ForegroundColor "Yellow"
}
Write-Host "Search Name:          " -NoNewline
if ($searchName -eq "") {
    Write-Host "Not configured yet" -ForegroundColor "DarkGray"
} else {
    Write-Host "$searchName" -ForegroundColor "Yellow"
}

if ($reenteringData -eq "Y") {
    Write-Host "" # empty line for space
    Write-Host "Note: To re-enter correct data, you must type it out again. Entering nothing will clear the field." -ForegroundColor "Yellow"
} else {
    <# do nothing #>
}

Write-Host "" # empty line for space
}



# reset all variables to starting default
$setupConfigured = 'n'
$reenteringData = 'n'
$UserPrincipalName = ''
$fromAddress = ''
$emailSubject = ''
$searchName = ''

<# * START OF SCRIPT #>

Clear-Host # clear terminal for visibility

<# User types in Variables #>
while ($setupConfigured -ne 'y') {

    DisplaySetupConfiguration
    $UserPrincipalName = Read-Host -Prompt "Enter your administrator email address"
    DisplaySetupConfiguration
    $fromAddress = Read-Host -Prompt "Enter the email address of the sender"
    DisplaySetupConfiguration
    $emailSubject = Read-Host -Prompt "Enter the subject of the email you wish to get rid of"
    DisplaySetupConfiguration
    $searchName = Read-Host -Prompt "Please give this search a name (Ex. Fire Dept Phishing Email Dec 12 2025)"
    DisplaySetupConfiguration

    $confirmSetupConfiguration = "" # reset the confirm variable in case the user had to go back to make
    while ('y','n' -notcontains $confirmSetupConfiguration) {
        Write-Host ""
       $confirmSetupConfiguration = Read-Host "Is everything correct? (Y/N) [If you select No, you will have to enter everything again due to the current limitations of this script.]"
       if ($confirmSetupConfiguration -eq 'y') {
        Write-Host "[+] You confirmed this configuration is accurate." -ForegroundColor "Cyan"
        $confirmSetupConfiguration = 'y' # Setup is confirmed. Continue the script by leaving the while loop
        $setupConfigured = 'y'
       } elseif ($confirmSetupConfiguration -eq 'n') {
        Write-Host "[=] You selected 'N'. Please enter the setup again." -ForegroundColor "Cyan"
        $confirmSetupConfiguration = 'n'
        $reenteringData = 'y'
       } else {
        Write-Host "[!] Invalid answer. Please try again." -ForegroundColor "Red"
       }
    }
}

# * Start the Exchange Management module
try {
    Write-Host "[+] Importing ExchangeOnlineManagement module..." -ForegroundColor "Yellow"
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    Write-Host "[+] ExchangeOnlineManagement module imported!" -ForegroundColor "Green"
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "[!] There was an issue importing the ExchangeOnlineManagement module. Please check your Wi-Fi connection and try again." -ForegroundColor "Red"
    throw $_
}

# Connect to the Exchange Online Powershell Session
try {
    Write-Host "[+]Connecting to the Exchange Online Powershell Session..." -ForegroundColor "Yellow"
    # Connect to Exchange
    Connect-IPPSSession -UserPrincipalName $UserPrincipalName -EnableSearchOnlySession -ErrorAction Stop
    Write-Host "[+] Connected to the Exchange Online Powershell Session!" -ForegroundColor "Green"
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "[!] There was an issue connecting to the Exchange Online Powershell Session. Ensure your password is correct and that Exchange servers are online and try again." -ForegroundColor "Red"
    throw $_
}

<# * Search for emails… #>
# 1. Create the search query…
$Search = New-ComplianceSearch -Name $SearchName -ExchangeLocation All -ContentMatchQuery "(From:$fromAddress) AND (Subject:$emailSubject)"

# 2. Start the search…
try {
    Write-Host "[+] Starting search..." -ForegroundColor "Yellow"
    #Start-ComplianceSearch -Identity $Search.Identity -ErrorAction Stop
    Start-ComplianceSearch -Identity $Search.Identity
    Write-Host "[+] Search started!" -ForegroundColor "Green"
}
catch {
    Write-Host "[!] There was an issue with starting the search." -ForegroundColor "Red"
    Write-Host "[-] Disconnecting session..." -foreground Yellow
    Disconnect-ExchangeOnline
    throw $_
}

# 3. Get search Results
$job = Get-ComplianceSearch -Identity $SearchName

while ("Completed" -notcontains $job.status) {
    $status = $job.Status
    Clear-Host
    Write-Host "$searchName is $status" -NoNewline
    
    for ($i = 1; $i -le 5; $i++) {
        Write-Host " ."-NoNewline
        Start-Sleep -Seconds 2
        }
    # repeat get job status
    $job = Get-ComplianceSearch -Identity $SearchName
    Start-Sleep -Milliseconds 500
}
if ($job.Status -eq "Completed") {
    $status = $job.Status
    Write-Host "" #empty line for space
    Write-Host "[-] $SearchName is $status!" -ForegroundColor Green
    Read-Host "Press Enter to view the results of the search"
    Write-Host "8888888888888888888888888888888888888888888888888" -ForegroundColor "Cyan"
    Write-Host "888           Beginning of Results            888" -ForegroundColor "Cyan"
    Write-Host "8888888888888888888888888888888888888888888888888" -ForegroundColor "Cyan"
    Clear-Host

    # Show the results of the search
    $results = Get-ComplianceSearch -Identity $SearchName | Select-Object Name, CreatedBy, CreatedTime, JobEndTime, Items, SuccessResults
    $resultItems = $results.Items

    if ($resultItems -eq 0) {
        Write-Host "[+] $resultItems matching emails were found." -ForegroundColor "Green"
        Write-Host "If you believe there are supposed to be any matching emails, please ensure the search criteria is correct and try again."
        Read-Host "Press Enter to Continue"
    } elseif ( $resultItems -ge 1) {
        Write-Host "[+] $resultItems matching emails were found." -foreground "Yellow"
        $results | Format-List Name, CreatedBy, CreatedTime, JobEndTime, Items, SuccessResults

        Write-Host "[+] Please scroll to the top to view the results." -ForegroundColor Cyan

        # ask the user if they want to delete all emails
        Write-Host ""
        $answer_Delete = "" # resets the variable to allow the below while loop
        while ($answer_Delete -ne 'y' -and $answer_Delete -ne 'n') {
            $answer_Delete = Read-Host "Do you want to delete all $resultItems found emails? (Y/N)"
            if ($answer_Delete -eq 'Y') {
                try {
                    Write-Host "[+] Beginning to delete emails..." -ForegroundColor "Yellow"
                    # Delete found emails…
                    New-ComplianceSearchAction -SearchName $SearchName -Purge -PurgeType HardDelete -ErrorAction Stop
                    Write-Host "[+] Emails deleted!" -ForegroundColor Green
                    Read-Host "Press Enter to exit this script."
                    # To disconnect the Powershell session…
                    try {
                        Write-Host "[+] Disconnecting from the Exchange Online session..." -ForegroundColor "Yellow"
                        Disconnect-ExchangeOnline -ErrorAction Stop
                        Write-Host "[+] Successfully disconnected from the Exchange online session!" -ForegroundColor Green
                        Start-Sleep -Seconds 3
                        exit
                    }
                    catch {
                        Write-Host "[!] There was an error disconnecting from the Exchange Online session." -ForegroundColor "Red"
                        throw $_
                    }   
                }
                catch {
                    Write-Host "[!] There was an error with deleting emails." -ForegroundColor "Red"
                    throw $_
                }
                
            } elseif ($answer_Delete -eq 'N') {
                Write-Host "[+] You selected not to delete the matching emails." -ForegroundColor "Cyan"
                Write-Host "[+] Ending script..." -ForegroundColor "Yellow"
                try {
                        Write-Host "[+] Disconnecting from the Exchange Online session..." -ForegroundColor "Yellow"
                        Disconnect-ExchangeOnline -ErrorAction Stop
                        Write-Host "[+] Successfully disconnected from the Exchange online session!" -ForegroundColor "Green"
                        Start-Sleep -Seconds 1
                        Write-Host "[+] Closing Script..." -ForegroundColor "Yellow"
                        Start-Sleep -Seconds 2
                        Clear-Host
                        exit
                    }
                    catch {
                        Write-Host "[!] There was an error disconnecting from the Exchange Online session." -ForegroundColor "Red"
                        throw $_
                    }
                Start-Sleep -Seconds 2
                Write-Host "[+] Closing Script..." -ForegroundColor "Cyan"
                Start-Sleep -Seconds 2
                Clear-Host
                exit
            } else {
                Write-Host "[!] Invalid Answer. Please Try again." -ForegroundColor "Red"
            }
        }
    } elseif ($resultItems -le -1) {
        Write-Host "[!] The number of found items is less than 1. This shouldn't happen if everything was configured correctly. Please double check that everything was input correctly and try again." -ForegroundColor Red
    } else {
        Write-Host "[!] There was an error with getting the number of emails that match the search criteria. Please double check that everything is input correctly and try again. If it doesn't work again, please double check that this script is working properly." -ForegroundColor Red
    }
    Write-Host "8888888888888888888888888888888888888888888888888" -ForegroundColor "Cyan"
    Write-Host "888              End of Results               888" -ForegroundColor "Cyan"
    Write-Host "8888888888888888888888888888888888888888888888888" -ForegroundColor "Cyan"
    Write-Host "" # just for space and readability
} else {
    Write-Host "[!] There was an error with showing the results of the search not showing as completed or not being included in the while loop beforehand. $SearchName's status is not 'Completed', it listed as $status." -ForegroundColor "Red"
    throw $_
}
