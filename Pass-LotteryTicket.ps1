#Script:    Pass-LotteryTicket
#Made by:   Marek Kieltyka
#Presented: 21.12.2018r.

Function Pass-LotteryTicket {

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Choose your lucky digit and win up to 100$ ! Every digit wins! Ticket price - only 20$ !"
        )]
        [ValidateSet(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]
        [int]$lucky_digit,
 
        [Parameter(
            Mandatory = $true,
            Position = 2,
            HelpMessage = "Do you want to add two capital letters for getting extra prizes? Five letters are drawn and you will get 200`$ for every hit! It costs additional 40$ (type `"yes`" or `"no`")"
        )]
        [ValidateSet("yes", "no")]
        [string]$choose
    )
 
    Process {

        Pass-LotteryTicketHelp $lucky_digit $choose
    }
}

Function Pass-LotteryTicketHelp {

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [ValidateSet(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]
        [int]$lucky_digit,
 
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [ValidateSet("yes", "no")]
        [string]$choose
    )

    DynamicParam {

        if ($choose -eq "yes") {

            # FIRST PARAMETER
            $AddedLetter = New-Object System.Management.Automation.ParameterAttribute
            $AddedLetter.Position = 3
            $AddedLetter.Mandatory = $true
            $AddedLetter.HelpMessage = "Come on! Pass your favourite letter and give a chance to your fate!"

            $LettersCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $LettersCollection.Add($AddedLetter)
 
            $LetterParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('First_capital_letter', [char], $LettersCollection)
 
            $LetParDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $LetParDictionary.Add('First_capital_letter', $LetterParameter)

            # SECOND PARAMETER
            $AddedLetter = New-Object System.Management.Automation.ParameterAttribute
            $AddedLetter.Position = 4
            $AddedLetter.Mandatory = $true
            $AddedLetter.HelpMessage = "And second letter (can be the same as the first)."

            $LettersCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $LettersCollection.Add($AddedLetter)

            $LetterParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Second_capital_letter', [char], $LettersCollection)
            $LetParDictionary.Add('Second_capital_letter', $LetterParameter)

            return $LetParDictionary
        }
    }
 
    Begin {
       
        $TicketPrice = 20

        #if we chose ticket with letters
        if ($PSBoundParameters.First_capital_letter) {

            $WinningLetters = @{}
            for ($i = 0; $i -lt 5; $i++) {

                $RandomLetter = (65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ }

                # lines 98-109 prevent keys from being identical
                $WinningLetters.Keys | ForEach-Object { 

                    if ($RandomLetter -eq $_) {
                        $RandomLetter = (65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ }
                        if ($RandomLetter -eq $_) {
                            $RandomLetter = (65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ }
                            if ($RandomLetter -eq $_) {
                                $RandomLetter = (65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ } 
                            } 
                        } 
                    }
                }

                $WinningLetters[$RandomLetter] = 200
            }
        }
    }
 
    Process {

        $TicketPassDate = Get-Date -Format g
        $WON = 0
       
        $DigitPrizes = @()
        for ($i = 0; $i -lt 10; $i++) {

            $DigitPrizes += (10..120) | Where-Object {$_ % 10 -eq 0} | Get-Random -Count 1
        }

        #if the highest possible prize isn't drawn, we add it manually
        $Guaranteed = $DigitPrizes | Where-Object { $_ -eq 120}
        if ($Guaranteed -ne 120) { 

            $i = Get-Random -Minimum 0 -Maximum 9
            $DigitPrizes[$i] = 120
        }

        $WON += $DigitPrizes[$lucky_digit]

        #if we decided on dynamic parameters
        if ($PSBoundParameters.First_capital_letter) {

            $TicketPrice += 40

            if ($WinningLetters[$PSBoundParameters.First_capital_letter]) {

                $WON += $WinningLetters[$PSBoundParameters.First_capital_letter]
            }
    
            if ($WinningLetters[$PSBoundParameters.Second_capital_letter]) {
    
                $WON += $WinningLetters[$PSBoundParameters.Second_capital_letter]
            }

            #ticket layout with letters
            "`n        YOUR TICKET       "
            "--------------------------"
            "| Date: $TicketPassDate |"
            "|                        |"
            "|    Digit:   " + $lucky_digit + "          |"
            "|    Letters: " + $PSBoundParameters.First_capital_letter + " " + $PSBoundParameters.Second_capital_letter + "        |"
            "|    Price:   " + $TicketPrice + "$        |"
            "--------------------------"
        }
        else { 
            #ticket layout without letters
            "`n        YOUR TICKET       "
            "--------------------------"
            "| Date: $TicketPassDate |"
            "|                        |"
            "|    Digit:  " + $lucky_digit + "           |"
            "|    Letter: not chosen  |"
            "|    Price:  " + $TicketPrice + "$         |"
            "--------------------------"
        }

        "`n     RESULTS OF DRAW"

        for ($i = 0; $i -lt 10; $i++) {

            if ($lucky_digit -eq $i) {

                Write-Host "Digit prize under", $i, "is", $DigitPrizes[$i], "`$" -BackgroundColor Black -ForegroundColor Yellow
            }

            else { Write-Host "Digit prize under", $i, "is", $DigitPrizes[$i], "`$" }
        }

        if ($WinningLetters) {

            "Winning Letters: (200$ for every hit)"
            $WinningLetters.Keys | ForEach-Object { 

                if ($PSBoundParameters.First_capital_letter -eq $_ -or $PSBoundParameters.Second_capital_letter -eq $_) {

                    Write-Host  "   ", $_, "    " -BackgroundColor Black -ForegroundColor Yellow
                }
                else { "    $_    " }
            }
        }

        #FINAL PRIZE
        $WON -= $TicketPrice

        if ($WON -lt 0) {

            "`nYou have lost " + $WON + "`$... Better luck next time!`n"
        }
        elseif ($WON -eq 0) {
            "`nYou neither lose nor win, maybe buy another ticket?`n"
        }
        else {
            "`nYou have won " + $WON + "`$ ! Really nice!`n"
        }
    }
}