# Funkcja odpowiedzialna za stworzenie drzewa z folderami wraz  z ich rozmiarem
function Folder-Tree ($Path, $MaxDepth, $_Depth)
{
    # Sprawdzenie czy użytkownik nie wybrał wartości zagnieżdzenia większej od maksymalnej
    if ($_Depth -ge $MaxDepth) {
        return
    }
    $FirstDirectoryShown = $False
    $start = "| " * $_Depth

    # Iteracja po folderach w podanej ścieżce 
    :NextDirectory foreach ($d in Get-ChildItem $path -Directory -ErrorAction SilentlyContinue  | Where-Object {$_.PSIsContainer -eq $True}) {

        # Transformacja otrzymujemy widok systemu operacyjnego obiektu do widoku ścieżki PowerShell (transformacja ścieżki z OS view do PS view)
        $ProviderPath = $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath($d.PSPath, [Ref]$d.PSProvider)
        $RootRelativePath = $ProviderPath.SubString($d.PSDrive.Root.Length) # Ścieżka do do folderu bez roota (relatywna ścieżka do folderu)
        $PSDriveFullPath = Join-Path ($d.PSDrive.Name + ":") $RootRelativePath # Cała ścieżka do foldery
        
        if (($FirstDirectoryShown -eq $FALSE) -and $ShowDirectory) 
        {
            $FirstDirectoryShown = $True
            Write-Output ("{0}{1}" -f $start, $Path)
        }

        $DirInfo = Get-ChildItem $PSDriveFullPath -recurse | Measure-Object -property length -sum -ErrorAction Ignore
       
        #Wyznaczanie rozmiaru folderu
        $Size = [math]::round($DirInfo.Sum,2)
        
        #Konwersja na daną wielkość w zależności od rozmiaru folder
        if($Size -ge 1073741824) #GBr
        {
            $sizeWithUnit = [string]([math]::round($Size/1GB,2))+" GB"
        }
        elseif($Size -ge 1048576) #MB
        {
            $sizeWithUnit = [string]([math]::round($Size/1MB,2))+" MB"
        }
        elseif($Size -ge 1024) #KB
        {
            $sizeWithUnit = [string]([math]::round($Size/1KB,2))+" KB"
        }
       
        # Ostatni folder w ścieżce
        $PathLeaf = Split-Path $PSDriveFullPath -Leaf


        Write-Output ("{0}+---{1}" -f $start, "$PathLeaf --> $sizeWithUnit") 
        
        # Ponowne wykonanie funkcji
        Folder-Tree -path:$PSDriveFullPath -_Depth:($_Depth + 1) -MaxDepth:$MaxDepth 
    }   

}

#"======================================================================================================="

#Funkcja odpowiedzialna za ponowne wykonanie skryptu bez konieczności ponownego jego uruchamiania
function One-More-Time ($newPath, $MaxDepth, $_Depth, $diskLetter)
{
    "_________________________________________________________________________________________"
    do{$end = Read-Host "Czy kończymy wykonywanie skryptu [T/N]?"}
    until($end -eq "T" -or $end -eq "N")
    if($end -eq "T")
    {
        Exit
        
    }
    elseif ($end -eq "N")
    {
        #Sprawdzenie na jakim dysku obecnie jesteśmy
        if($diskLetter -eq "C")
        {
        do{$newPath = Read-Host "Podaj nową ścieżkę katalogu do analizy z dysku C"}
        while($newPath[0] -notlike "C" )
        "_________________________________________________________________________________________"
        
        }
        else
        {

        do{$newPath = Read-Host "Podaj ścieżkę katalogu do analizy z dysku D"}
        while($newPath[0] -notlike "D" )
        "_________________________________________________________________________________________"
    }

        Folder-Tree -Path $newPath -MaxDepth $MaxDepth -_Depth $Depth
        One-More-Time -newPath $mainPath -MaxDepth $MaxDepth -_Depth $Depth -diskLetter $disk
    }
    }

#"======================================================================================================="

"_________________________________________________________________________________________"
"WYKONAŁ: Jakub Kuczmarski IP-171"

"_________________________________________________________________________________________"
"ZADANIE: Analiza zajętości dysku. Ma zostać wygenerowany obraz w formie drzewa z informacją na gałęziach o rozmiarze każdego z katalogów."


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
do{$disk = Read-Host "Wybierz literkę dysku do analizy [C/D]"}
until($disk -eq "C" -or $disk -eq "D")
if($disk -eq "C")
    {
        "Witaj na dysku C: ! Do dalszej analizy wybrano dysk C"
        #Root folder
        do{$mainPath = Read-Host "Podaj ścieżkę katalogu do analizy [Litera dysku:\folder\podfolder\ ..., np. D:\studia\ANG]"}
        while($mainPath[0] -notlike "C" )
        "_________________________________________________________________________________________"
        
    }
else
    {

        "Witaj na dysku D: ! Do dalszej analizy wybrano dysk D"
        #Root folder
        do{$mainPath = Read-Host "Podaj ścieżkę katalogu do analizy [Litera dysku:\folder\podfolder\ ..., np. D:\studia\ANG]"}
        while($mainPath[0] -notlike "D" )
        "_________________________________________________________________________________________"
    }

# Maksymalny poziom zagnieżdżenia w folderze
[int]$MaxDepth = [int]::MaxValue

#Parametr do rekurencji określający jak głęboko w danym katalogu jesteśmy
[int]$Depth = 0

"Drzewo dla katalogu ze ścieżki: " + $mainPath
Folder-Tree -Path $mainPath -MaxDepth $MaxDepth -_Depth $Depth 

One-More-Time -newPath $mainPath -MaxDepth $MaxDepth -_Depth $Depth -diskLetter $disk
