*** Settings ***
Library    OperatingSystem
Library    String
Library    DatabaseLibrary
Library    Collections
Library    DateTime
Library    Validations.py


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

    ${InvoiceDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDate}=    Convert Date    ${items}[5]    date_format=%d.%m.%Y    result_format=%Y-%m-%d

    ${insertStatement}=    Set Variable    insert into invoiceheader (InvoiceNumber, CompanyName, CompanyCode, ReferenceNumber, InvoiceDate, DueDate, BankAccountNumber, AmountExclVAT, VAT, TotalAmount, Invoicestatus_ID, Comments) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${InvoiceDate}', '${dueDate}', '${items}[6]', ${items}[7], ${items}[8], ${items}[9], -1, 'Processing');    
    Log    ${insertStatement}
    Execute Sql String    ${insertStatement}

    Disconnect From Database

*** Keywords ***
Add invoiceRow to Database
    [Arguments]    ${items}
    Make Connection    ${dbname}

    ${insertStatement}=    Set Variable    insert into invoicerow (InvoiceNumber, RowNumber, Description, Quantity, Unit, UnitPrice, VATPercent, VAT, Total) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', ${items}[5], '${items}[6]', ${items}[7], ${items}[8]);

    Log    ${insertStatement}
    Execute Sql String    ${insertStatement}

    Disconnect From Database

*** Keywords ***
Check Invoice Sum
    [Arguments]    ${HeaderTotal}    ${RowTotal}
    ${status}=    Set Variable    ${False}

    ${HeaderTotal}=    Convert To Number    ${HeaderTotal}
    ${RowTotal}=    Convert To Number    ${RowTotal}
    ${DIFF}=    Convert To Number    0.01

    ${status}=    Validate Amount    ${HeaderTotal}    ${RowTotal}    ${DIFF}

    RETURN    ${status}

*** Keywords ***
Check IBAN
    [Arguments]    ${IBAN}
    ${status}=    Set Variable    ${False}
    
    ${status}=    Validate Iban    ${IBAN}
    RETURN    ${status}

*** Keywords ***
Check Reference Number
    [Arguments]    ${ReferenceNum}
    ${status}=    Set Variable    ${False}

    ${status}=    Validate Ref Number    ${ReferenceNum}
    RETURN    ${status}

*** Tasks ***
Read CSV files to lists and add data to database
    Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${path_Jani}ResultFiles\\InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${path_Jani}ResultFiles\\InvoiceRowData.csv
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
    # Kutsutaan keywordia ja lisätään tiedot tietokannan Invoiceheader ja invoiceheader tauluihin

    # Lisätään header tiedot
    FOR    ${headerElement}    IN    @{headers}
        Log    ${headerElement}
        @{headerItems}=    Split String    ${headerElement}    ;

        Add invoice header to database    ${headerItems}
    END    

    # Lisätään rivi tiedot

     FOR    ${rowElement}    IN    @{rows}
        Log    ${rowElement}
        @{rowItems}=    Split String    ${rowElement}    ;

        Add invoiceRow to Database    ${rowItems}
    END   
    Disconnect From Database

*** Tasks ***
Validate and update validation info to DB
    # Haetaan kaikki laskut minkä statuksena on -1 = Processing
    # Validaatiot:
    #     * Viitenumero
    #     * IBAN
    #     * Summan tarkastus otsikko- ja rivitasolla
    Make Connection    ${dbname}

    # Haetaan laskut
    ${invoices}=    Query    select ih.InvoiceNumber, ih.ReferenceNumber, ih.BankAccountNumber, ih.TotalAmount, SUM(ir.Total) AS TotalSum FROM invoiceheader ih JOIN invoicerow ir ON ih.InvoiceNumber = ir.InvoiceNumber WHERE ih.invoicestatus_ID = -1 GROUP BY ih.InvoiceNumber, ih.ReferenceNumber, ih.BankAccountNumber, ih.TotalAmount;

 
    FOR    ${element}    IN    @{invoices}
        Log    ${invoices}
        ${invoiceStatus}=    Set Variable    0
        ${invoiceComment}=    Set Variable    All ok

        # Viitenumeron validointi
        ${ReferenceNumCheck}=    Check Reference Number    ${element[1]}
        IF    ${ReferenceNumCheck}

            Log    Viitenumero oikein
        ELSE
            ${invoiceStatus}=    Set Variable    1
            ${invoiceComment}=    Set Variable   Ref error
        END

        # IBAN-numeron validointi
        ${IbanCheck}=    Check IBAN    ${element[2]}
        IF    ${IbanCheck}

        Log    Iban oikein

        ELSE
        ${invoiceStatus}=    Set Variable    2
        ${invoiceComment}=    Set Variable   Iban error
            
        END

        # Summan tarkastus otsikko- ja rivitasolla
        ${TotalCheck}=    Check Invoice Sum    ${element[3]}    ${element[4]}
        IF    ${TotalCheck}

        Log    Summat oikein

        ELSE
        ${invoiceStatus}=    Set Variable    3
        ${invoiceComment}=    Set Variable   Amount error
            
        END

        # Päivitetään tiedot tietokantaan
        @{params}=    Create List    ${invoiceStatus}    ${invoiceComment}    ${element}[0]
        ${updateStmt}=    Set Variable    update invoiceheader set invoicestatus_ID = %s, comments = %s where invoicenumber = %s;
        Execute Sql String    ${updateStmt}    parameters=${params}
    END
    
    Disconnect From Database


