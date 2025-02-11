*** Settings ***
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    Collections

# Tehdään root-kansion polusta oma muuttuja
*** Variables ***
${path_Jani}    C:\\Kouluhommat\\Liiketoimintaprosessien automatisointi\\Ohjelmistorobotiikka\\Ohjelmistorobotiikka\\
${path_Teemu}    C:\\Users\\teemu\\OneDrive\\Työpöytä\\vuosi2\\Moduuli_3\\Ohjelmistorobotiikka ja automaatio\\ProjektiAutomaatio\\Ohjelmistorobotiikka\\
# Tietokanta muuttujat
${dbname}    rpa_kurssi
${dbuser}    Robotuser
${dbpass}    mahtavaRyhma
${dbhost}    localhost
${dbport}    3306


# Luodaan keywordi millä tietokantaan otetaan yhteys
*** Keywords ***
Make Connection
    [Arguments]    ${DBtoConnect}

    Connect To Database    pymysql    ${DBtoConnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}


*** Keywords ***
Add invoice header to database
    [Arguments]    ${items}
    Make Connection    ${dbname}

    ${insertStatement}=    Set Variable    insert into invoiceheader (InvoiceNumber, CompanyName, CompanyCode, ReferenceNumber, InvoiceDate, DueDate, BankAccountNumber, AmountExclVAT, VAT, TotalAmount, Invoicestatus_ID, Comments) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '2000-01-01', '2000-01-01', '${items}[6]', 0, 0, 0, -1, 'Processing');    
    Log    ${insertStatement}
    Execute Sql String    ${insertStatement}


    Disconnect From Database

*** Tasks ***
Read CSV files to lists and add data to database
    Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${path_Teemu}ResultFiles\\InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${path_Teemu}ResultFiles\\InvoiceRowData.csv
    Log    ${outputHeader}
    Log    ${outputRows}


    # Luetaan CSV-tiedostojen jokainen elementti listaan, splitataan ne rivinvaihdolla ja logitetaan tulos seuraavaa vaihetta varten.
    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n

    # Poistetaan listoista ensimmäisen ja viimeisen indeksin elementit (Otsikot ja tyhjä indeksi)
    # Ensin headers lista

    ${length}=    Get Length    ${headers}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0

    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    # Seuraavaksi rows lista

    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}
    
    # Logitus ja tarkastetaan että indeksien poisto onnistui
    Log    ${headers}
    Log    ${rows}


    # Listataan jokainen taulukon elementti ja tallennetaan se muuttujaan headerItems, erotinmerkkinä puolipiste ';'
    # Kutsutaan keywordia ja lisätään tiedot tietokannan Invoiceheader tauluun
    FOR    ${headerElement}    IN    @{headers}
        Log    ${headerElement}
        @{headerItems}=    Split String    ${headerElement}    ;

        Add invoice header to database    ${headerItems}
    END    