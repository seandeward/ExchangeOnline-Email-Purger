
param (
  [Parameter(Mandatory=$true)][string]$UserPrincipalName,
  [Parameter(Mandatory=$true)][string]$FromAddress,
  [Parameter(Mandatory=$true)][string]$EmailSubject,
  [Parameter(Mandatory=$true)][string]$SearchName
)

# * DECLARE FUNCTIONS
function Show-WelcomeBanner {
Write-Host "___________              .__.__    __________                                  " -ForegroundColor "Red"
Write-Host "\_   _____/ _____ _____  |__|  |   \______   \__ _________  ____   ___________ " -ForegroundColor "Red"
Write-Host " |    __)_ /     \\__  \ |  |  |    |     ___/  |  \_  __ \/ ___\_/ __ \_  __ \" -ForegroundColor "Magenta"
Write-Host " |        \  Y Y  \/ __ \|  |  |__  |    |   |  |  /|  | \/ /_/  >  ___/|  | \/" -ForegroundColor "Magenta"
Write-Host "/_______  /__|_|  (____  /__|____/  |____|   |____/ |__|  \___  / \___  >__|   " -ForegroundColor "Magenta"
Write-Host "        \/      \/     \/                                /_____/      \/       " -ForegroundColor "Magenta"
Write-Host "" # terminal space for readability
}

function Confirm-TerminalArguments {
  Write-Host "
  Admin Email:          $UserPrincipalName
  Sender/From Address:  $FromAddress
  Target Email Subject: $EmailSubject
  Exchange Search Name: $SearchName
  "
  while ($true) {
  $UserResponse = Read-Host "Is all of this correct? (Y/n) "
    if ($UserResponse -eq 'y') {
      Write-Host "sounds good" -ForegroundColor Green
      return # continue script
    } elseif ($UserResponse -eq 'n') {
      Write-Host "wtf" -ForegroundColor Yellow
      exit # end script
    } else {
      Write-Host "Invalid answer. Please try again." -ForegroundColor Red
      # go back to the top of the `while` loop
    }
  }
}

try {
    Write-Host "[+] Checking for updates on the ExchangeOnlineManagement module..." -ForegroundColor Yellow
    Update-Module -Name ExchangeOnlineManagement -ErrorAction Stop
    Write-Host "[+] Done"
}
catch {
    Write-Host "[!] There was an error updating the ExchangeOnlineManagement module..." -ForegroundColor Red
    throw $_
}

<# * START OF SCRIPT #>
Clear-Host # clear terminal for visibility
Show-WelcomeBanner
Confirm-TerminalArguments
