"_________________________________________________________________________________________"
"WYKONAŁ: Jakub Kuczmarski IP-171"

"_________________________________________________________________________________________"
"ZADANIE: Wyszukiwarka plików, która jednocześnie bierze pod uwagę wzorzec nazwy, oczekiwany rozmiar, datę utworzenia."


#Przywitanie z użytkownikiem
"_________________________________________________________________________________________"
$UserName = Read-Host "Podaj swoje imię"
"Witaj " + $UserName + " w PowerShellu ! Za chwilę zostanie Ci przedstawiony raport dyskowy z tego sprzętu."
"_________________________________________________________________________________________"

#Pobranie i wyświetlenie obecnej daty
$CurrentDate = Get-Date


#Stan całkowietej pamięci i wolnego miejsca na dyskach z danego dnia
"Stan pamięci na konkretnych dyskach z dnia: " + $CurrentDate

#Sprawdzenie dostępnych dysków
$diskName = (Get-CimInstance -ClassName Win32_LogicalDisk).DeviceID #Wczytanie do zmiennej literek dostępnych dysków
$sum=$diskName.count
$letterTable=@()
for($i=0; $i -lt $sum; $i++)
{
    $diskLetter = $diskName[$i]
    $letterTable += $diskLetter[0]
    "_________________________________________________________________________________________"
    "Dysk " + $diskLetter
    "Całkowity rozmiar:  " + [math]::Round((Get-Volume -DriveLetter $diskLetter[0]).Size / 1Gb) + " GB"
    "Wolne miejsce:  " + [math]::Round((Get-Volume -DriveLetter $diskLetter[0]).SizeRemaining / 1Gb) + " GB"
    
}

#Wybór dysku
"_________________________________________________________________________________________"
do{$disk = Read-Host "Wybierz literkę dysku w której chcesz szukać pliku [C/D]"}
until($disk -eq "C" -or $disk -eq "D")
if($disk -eq "C")
    {
        "_________________________________________________________________________________________"
        "Witaj na dysku C: ! "
        "_________________________________________________________________________________________"
        #Wybór miejsca poszukiwania pliku lub folderu - cały dysk lub konkretna ściezka
        do{$searchPalce = Read-Host "Szykamy w obrębie całym dysku C: ? [t/n]"}
        while(-NOT($searchPalce -eq "t" -or $searchPalce -eq "n"))
        if($searchPalce -eq "t")
        {
            $mainPath = "C:\"
        }
        else
        {
            "_________________________________________________________________________________________"
            do{$mainPath = Read-Host "Podaj ścieżkę katalogu do analizy [Litera dysku:\folder\podfolder\ ..., np. D:\studia\ANG]"}
            while($mainPath[0] -notlike "C" )
        }
        "_________________________________________________________________________________________"
        
    }
else
    {
        "_________________________________________________________________________________________"
        "Witaj na dysku D: !" 
        "_________________________________________________________________________________________"
        #Root folder
        do{$searchPalce = Read-Host "Szykamy w obrębie całym dysku D: ? [t/n]"}
        while(-NOT($searchPalce -eq "t" -or $searchPalce -eq "n"))
        if($searchPalce -eq "t")
        {
            $mainPath = "D:\"
        }
        else
        {
            "_________________________________________________________________________________________"
            do{$mainPath = Read-Host "Podaj ścieżkę katalogu do analizy [Litera dysku:\folder\podfolder\ ..., np. D:\studia\ANG]"}
            while($mainPath[0] -notlike "D" )
        }
        
        "_________________________________________________________________________________________"
    }
#------------------------------------------------------

#Fraza, po której szukamy pliku
$name= Read-Host "Podaj frazę po której będziemy szukać"
"_________________________________________________________________________________________"

#Wstęp teoretyczny dotyczący różnego rodzaju rozszerzeń plikowych
"PRZYKŁADOWE TYPY ROZSZERZEŃ PLIKÓW"

"Rozszerzenia dokumentów:
 1. .txt -> pliki tekstowe, bez formatowania
 2. .pdf -> format Adobe Acrobat
 3. .docx -> domyślny format dokumentów Word
 4. .csv -> otwarty format reprezentujący dowolny typ danych w formie tabeli
 5. .xlsx -> domyślny format dokumentów Excel
 6. .pptx -> domyślny format PowerPoint
 _________________________________________________________________________________________
 Rozszerzenia audio i wideo:
 1. .mp3 -> standardowy kodek muzyczny z kompresją.
 2. .mp4 -> format zdolny do przechowywania treści multimedialnych, takich jak audio, wideo i napisy.
 _________________________________________________________________________________________
 Rozszerzenia zdjęć:
 1. .jpeg / .jpg -> format najczęściej używany w obrazach cyfrowych, z kompresją i utratą.
 2. .png -> format graficzny z bezstratną kompresją. Obsługuje folie.
 _________________________________________________________________________________________
 Rozszerzenia systemu Windows:
 1. .exe -> plik wykonywalny Windows.
 2. .bat -> skrypt dla CMD.
 3. .dll -> biblioteki z kodem niezbędnym do działania programów.
 4. .msi -> instalator.
 _________________________________________________________________________________________
 Skompresowane rozszerzenia plików:
 1. .zip -> format opracowany przez WinZIP.
 2. .rar -> format kompresji opracowany przez WinRAR bardziej wydajny niż ZIP.
 3. .7z -> darmowy format opracowany przez twórcę 7-Zip.
 _________________________________________________________________________________________
 Rozszerzenia obrazu CD lub DVD:
 1. .img -> szeroko stosowane, na przykład, do tworzenia dosłownych kopii kart pamięci lub innych jednostek.
 _________________________________________________________________________________________
 Rozszerzenia internetowe:
 1. html -> plik tekstowy z kodem strony internetowej.
 2. .css -> rozszerzenie stylu, które towarzyszy HTML.
 3. .js -> skrypt JavaScript.
 4. .php -> kod PHP.
 5. .eml / .msg -> format wiadomości e-mail.
 _________________________________________________________________________________________"

#Rozszerzenie szukanego pliku
"UWAGA: Rozszerzenie pliku należy podać z kropką na początku [np. .txt] !"
$extension = Read-Host "Podaj rozszerzenie szukanego pliku"
$fileExtension = "*" + $extension
"_________________________________________________________________________________________"

#Data powstania pliku
"UWAGA: Datę powstania pliku należy podać zgodnie z formatem - rrrr-MM-dd [np.2021-12-01] !"
$createDate = Read-Host "Podaj datę powstania pliku od której chcesz szukać"
"_________________________________________________________________________________________"

do{$date = Read-Host "Wpisz UP -> jeżeli chcesz szukać od tej daty (włącznie z tą datą) - " $createDate " lub DWON -> jeśli chcesz szukać do tej daty (włącznie z tą datą) - " $createDate}
until($date -eq "up" -or $date -eq "down")
"_________________________________________________________________________________________"


#Wstęp teoretyczny dotyczący różnego rodzaju matematycznyh operatorów zależności
"MATEMATYCZNE OPERATORY ZALEŻNOSCI
1. -lt for less than -> <
2. -gt for greater than -> >
3. -eq for equal to -> =
4. -ne for not equal to -> !=
5. -ge for greater than or equal to -> >=
6. -le for less than or equal to -> =<"

#Rozmiar szukanego pliku
"_________________________________________________________________________________________"

"UWAGA: Romziar pliku należy podać zgodnie z przykładem - 100MB, bez spacji między cyfrą, a jednostką !"
$fileSize = Read-Host "Podaj rozmiar pliku z jednostką KB, MB lub GB"
"_________________________________________________________________________________________"

#Wybór mateamtycznego operatora zależności
do{$matchOperator = Read-Host "Wybierz numer matematycznego opertarora zależności"}
until($matchOperator -eq "1" -or $matchOperator -eq "2" -or $matchOperator -eq "3" -or $matchOperator -eq "4" -or $matchOperator -eq "5")

#Wyświetlanie od danej daty
if($date -eq "up")
{
    "Pliki sprłniające wskazane przez użytkownika kryteria:"
    if($matchOperator -eq "1")
    {
        #Sprawdzamy jednostkę, w której ma być wielkość pliku
        if($fileSize.ToUpper().EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -lt $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.ToUpper().EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -lt $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.ToUpper().EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -lt $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "2")
    {
        if($fileSize.ToUpper().EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -gt $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.ToUpper().EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -gt $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.ToUpper().EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -gt $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "3")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -eq $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -eq $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -eq $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }
    }
    elseif($matchOperator -eq "4")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ne $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ne $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ne $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "5")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ge $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ge $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ge $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }
    }
    elseif($matchOperator -eq "6")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -le $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -le $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -le $fileSize -and $_.Name -match $name -and $_.CreationTime -ge $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }
    }
}
#Wyświetlanie do danej daty 
elseif($date -eq "down")
{
    "Pliki sprłniające wskazane przez użytkownika kryteria:"
    if($matchOperator -eq "1")
    {
    #Sprawdzamy jednostkę, w której ma być wielkość pliku
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -lt $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -lt $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -lt $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "2")
    {
        if($fileSize.EndsWith("KB") -or $fileSize.EndsWith("kb"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -gt $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB") -or $fileSize.EndsWith("mb"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -gt $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB") -or $fileSize.EndsWith("gb"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -gt $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "3")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -eq $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue |
            where-object {$_.length -eq $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -eq $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "4")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ne $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ne $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ne $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "5")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ge $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ge $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} |
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -ge $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }
    elseif($matchOperator -eq "6")
    {
        if($fileSize.EndsWith("KB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -le $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate } | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1KB) + " KB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("MB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -le $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1MB) + " MB"}}, creationTime | Sort-Object length -Descending | format-list
        }
        elseif($fileSize.EndsWith("GB"))
        {
            Get-ChildItem $mainPath -include $fileExtension -force -Recurse -ErrorAction SilentlyContinue | 
            where-object {$_.length -le $fileSize -and $_.Name -match $name -and $_.CreationTime -le $createDate} | 
            select-object Name, fullName, @{n=”Size”;e={„{0:N2}” -f ($_.Length/1GB) + " GB"}}, creationTime | Sort-Object length -Descending | format-list
        }

    }

}

