"_________________________________________________________________________________________"
"WYKONAŁ: Jakub Kuczmarski IP-171"

"_________________________________________________________________________________________"
"ZADANIE: Utworzenie serwera FTP na IIS. Przesłanie plików, pobranie plików z serwera oraz wyświetlenie jego zawartości.."

#Przywitanie z użytkownikiem
"_________________________________________________________________________________________"
$UserName = Read-Host "Podaj swoje imię"
"Witaj " + $UserName + " w PowerShellu ! Za chwilę zostanie Ci przedstawiony raport dotyczący serwera FTP."
"_________________________________________________________________________________________"

#Wyświetlanie zawartości serwera ftp
"UWAGA! Serwer FTP zwiera zabezpieczenia przed nieproszonymi użytkownikami. Jedynie osoby uprawnionę moga przegladać jego zawarstość !"



#Kontrola dostępu - login użytkownika
$username = Read-Host "Podaj nazwę użytwnika"
if($username -eq "Kuba Kuczmarski")
    {
        #Hasło użytkonika, jeżeli wprowadzi 3 błędne hasła kończymy skrypt
        $wrongPassword=0
        "`n"
        "UWAGA! Trzykrotne błędne wprowadzenie hasło skutkuje zakończeniem wykonywania się skryptu"
        do{$password = Read-Host "Podaj hasło do konta"
            if($password -eq "SYOP")
            {
                "_________________________________________________________________________________________"

                "`n Witaj na serwerze FTP `n"

                #Pobranie i wyświetlenie obecnej daty
                $CurrentDate = Get-Date

                #Stan serwera FTP z danego dnia
                "Stan serwer FTP z dnia: " + $CurrentDate + "`n"

                #Wyświetlanie zawartości serwera ftp

                #Adres serwera FTP
                $ftp='ftp://192.168.56.1'
                $subfolder='/'
                
                #Pełna ścieżka do serwera
                $ftpuri = $ftp + $subfolder
                
                #Deklaracja klasy identyfikatorów URI, która oferuje wiele właściwości i metod, które umożliwiają łatwe manipulowanie i porównywanie identyfikatorów URI
                $uri=[system.URI] $ftpuri
                
                #Inicjacja nowego WebRequest
                $ftprequest=[system.net.ftpwebrequest]::Create($uri)
                $ftprequest.Credentials=New-Object System.Net.NetworkCredential($username,$password)

                
                #Wartość zawierająca polecenie do wysłania do serwera FTP - wyświetlenie lista plików znajdujących się na serwerze, Method - określa, które polecenie jest wysyłane do serwera
                $ftprequest.Method=[system.net.WebRequestMethods+ftp]::ListDirectory #List Directory - reprezentuje metodę protokołu FTP NLISTA, która pobiera krótką listę plików na serwerze FTP.
                
                #Zwraca odpowiedź z zasobu internetowego
                $response=$ftprequest.GetResponse()
                
                #Pobiera strumień zawierający dane odpowiedzi wysyłane z serwera FTP.
                $strm=$response.GetResponseStream()
                
                #Tworzymy nowy obiekt, z którego będzimey odczytywać pliki
                $reader=New-Object System.IO.StreamReader($strm,'UTF-8')
                
                #Odczyt wszytskich wierszy (plików) z serwera
                $list=$reader.ReadToEnd()
                
                #Rozdzielnei plików - każdy do nowej linijki
                $lines=$list.Split("`n")
                
                #Wyświetlenie wyników
                "Lista plików na serwerze: "
                $lines

                "_________________________________________________________________________________________"
            
                #Wybór jednej z opcji - wgranie na serwer (upload) lub pobranie z serwera (download)
                "`n"
                do{$choiceOption = Read-Host "Wybierz opcję - download [D] lub upload [U]"}
                until($choiceOption -eq "D" -or $choiceOption -eq "U")
                if($choiceOption -eq "D")
                {
                #Pobiernanie plików z serwera na komputer

                    "`n "

                    #Ścieżka, pod która zapisujemy plik na komputerze
                    $localFile = Read-Host "Podaj miejsce, w którym chcesz zapiszać plik z serwera FTP w postaci - Litera dysku:/folder/podfolder/, np. D:/studia/TEST/"

                    #Nazwa pliku, który chcemy pobrać z serwera FTP
                    $fileName = Read-Host "Podaj nazwę pliku, który chcesz pobrać z serwera w postaci - nazwa_pliku_z_serwera.rozszerzenie, np. test.txt"

                    #Pełna scieżka, pod którą zapisujemy plik
                    $path = $localFile + $fileName

                    #Typowe metody wysyłania danych do i otrzymywania danych z zasobu identyfikowanego przez identyfikator URI.
                    $webclient = New-Object System.Net.WebClient

                    #Logowanie do serwera przy użyciu logina i hasła
                    $webclient.Credentials = New-Object System.Net.NetworkCredential($username,$password)

                    #Kompletna ścieżka do pliku, który chcemy pobrać z serwera
                    $uri = New-Object System.Uri($ftpuri+$fileName)

                    #Pobranie plik z serwea do określonej lokalizacjii na komputerze
                    "[INFO] Pobieranie pliku z serwera FTP ..."
                    $webclient.DownloadFile($uri, $path)
                }
                else
                {
                #Dodawanie plików na serwer FTP

                    #Wybór miejsca, z którego pobiermay plik w celu przesłania go na serwer FTP
                    $localFile = Read-Host "Podaj miejsce, z którym chcesz przesłać plik na serwera FTP w postaci - Litera dysku:\folder\podfolder\nazwa_pliku_z_dysku_komputera.rozszerzenie ..., np. D:/studia/Zadania_C++.pdf"

                    #Nazwa pod jaką plik zostanie zapisany na serwrze
                    $fileName = Read-Host "Podaj nazwę pod jaką przesłany plik ma być zapisany na serwerze w postaci - nazwa_pliku.rozszerzenie ..., np. Zadania.pdf"

                    $webclient = New-Object System.Net.WebClient
                    $webclient.Credentials = New-Object System.Net.NetworkCredential($username,$password)
                    $uri = New-Object System.Uri($ftpuri+$fileName)

                    #Wgrywanie pliku na serwer FTP z komputera
                    "[INFO] Wgrywanie pliku na serwer FTP ..."
                     $webclient.UploadFile($uri, $localfile)
                }
                $wrongPassword = 3
            }

            else
            {
                $wrongPassword+=1
            }

            }while(-NOT($wrongPassword -eq 3))

        }
        
else
    {
        "_________________________________________________________________________________________"
        "Niewłaściwy użytkownik ! W celu dokonania ponownej próby, należy uruchomić jeszcze raz skrypt " 
        break;  
    }



