#Ścieżka do pliku bash.txt, który zawiera komendy bash
$originalPath = "D:\studia\ROK 4\SEM 7\SYOP\PROJEKTY\4\BASH\bash.txt"
#Ścieżka do pliku powershell.txt, który zawiera przekonwertowane komendy z basha do PowerShella
$resultPath = "D:\studia\ROK 4\SEM 7\SYOP\PROJEKTY\4\BASH\powershell.txt"

#Deklaracja tabeli skrótów
$hashTable = @{ 
    '#! /bin/bash' = '#! /usr/bin/pwsh'
    'echo' = 'Write-Host'
    'read' = 'Read-Host'
    'zmienna' = '$zmienna'
    'liczba=$liczba+1' = '$liczba+=1'
    'sed' = '-Replace'
    'grep' = 'Select-String'
    'cp' = 'Copy-Item'
    'ls' = 'Get-Childitem'
    'cd' = 'Set-ChildItem'
    'pwd' = 'Get-Location'
    'rm' = 'Remove-Item'
    'touch' = 'New-Item'
     }

"[INFO] Zapisywanie przekonwertowanego komend z bash-a do PowerShell-a do pliku ... "

#Wykonujemy dla każdej linii z pliku bash.txt
Get-Content -Path $originalPath | ForEach-Object {
    #Pobieramy aktualną wartość
    $oneLine = $_ 
    
    #Wykonujemy iterację przez hashTable
    $hashTable.GetEnumerator() | ForEach-Object { 
        if ($oneLine -match $_.key) 
        {
            #Zmiana komendy bash (klucz) na PowerShell (wartść) - zamiana klucza z przypisaną do niego wartością
            $oneLine = $oneLine -replace $_.key, $_.value 
        }
    }
   $oneLine
} | Set-Content -Path $resultPath #Zapis przekowertowanej linii do pliku PowerShell.txt

