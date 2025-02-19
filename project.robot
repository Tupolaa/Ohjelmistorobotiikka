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
    # Add invoice headers
    FOR    ${headerElement}    IN    @{headers}
        Log    ${headerElement}
        @{headerItems}=    Split String    ${headerElement}    ;

        Add invoice header to database    ${headerItems}
    END    

    # Add invoice Rows

     FOR    ${rowElement}    IN    @{rows}
        Log    ${rowElement}
        @{rowItems}=    Split String    ${rowElement}    ;

        Add invoiceRow to Database    ${rowItems}
    END   

*** Tasks ***
Validate and update validation info to DB
    # Find all invoices with status -1 Processing
    # Validations:
    #     * Referencenumber
    #     * IBAN
    #     * Invoice row amount vs header amount
    Make Connection    ${dbname}

    # Find invoices
    ${invoices}=    Query    select InvoiceNumber, ReferenceNumber, BankAccountNumber, TotalAmount from invoiceheader where invoicestatus_ID = -1;

    FOR    ${element}    IN    @{invoices}
        Log    ${element}
        ${invoiceStatus}=    Set Variable    0
        ${invoiceComment}=    Set Variable    All ok

        # Validate referencenumber
        
        # Validate IBAN
        
        # Validate: Invoice row amount vs header amount
        
        # Update status to DB
        @{params}=    Create List    ${invoiceStatus}    ${invoiceComment}    ${element}[0]
        ${updateStmt}=    Set Variable    update invoiceheader set invoicestatus_ID = %s, comments = %s where invoicenumber = %s;
        Execute Sql String    ${updateStmt}    parameters=${params}
    END

    Disconnect From Database