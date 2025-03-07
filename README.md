# Ohjelmistorobotiikka
Ohjelmistorobotiikka ja -automaatio

Työvaiheet

UiPathissa:


1. Luodaan Data taulut Laskujen otsikoille ja riveille. Määritellään data taulujen sisältö tietokanta taulujen sarakkeiden nimien mukaisesti.

2. Luodaan uusi muuttuja mihin tallennetaan kaikki SourceFiles hakemiston .pdf päätteiset tiedostot, tässä tapauksessa kaikki pdf muodossa olevat laskut.

3. For-Each looppia hyödyntäen luemme kaikki tiedostot muuttujasta käyttäen Read PDF Text aktiviteettia ja tulostamme ne logiin.

4. Haetaan SubString metodia käyttämällä saadusta tulosteesta kohta CompanyCode ja määritellään se vastaamaan oikeaa Y-tunnus tulostetta ja tallennetaan tämä tieto omaan CompanyCode muuttujaan.

5. Lisätään Switch-aktiviteetti millä varmistamme, että eri Y-Tunnuksen laskut tallentuvat Data tauluun.

6. Lisätään Add Data Row aktiviteetti, millä lisätään Data Tauluun oikeaan sarakkeeseen muuttujan CompanyCoden tieto.

7. Lopuksi kirjoitetaan ResultFile hakemistoon Write-CSV aktiviteetilla uusi .csv tiedosto mikä sisältää laskujen otsikko datan.

8. Haetaan ja lisätään tarvittavat tiedot CSV-tiedostoon

9. Erotettiin datarivien tiedot otsikko datoista Split-komennolla

10. Parsittiin tarvittavat datat splitatuista rivi tiedoista CSV-tiedostoon


Robot Frameworkissa: 

1. Tehtiin tarvittavat keywordit millä otettiin yhteys tietokantaan.

2. Splitattiin CSV-tiedostojen tuloste puolipistettä erotinmerkkinä käyttäen, ja luotiin näiden avulla SQL-lauseet millä tiedot siirrettiin oikeisiin tietokannan sarakkeisiin, Header ja Row tauluille molemmille omat keywordinsa. Jokaisen laskun tila päivitettiin tässä vaiheessa "-1" eli "Processing" vaiheeseen.

3. Validaatiot: 

    - Viitenumerolle
    - IBAN-tunnukselle
    - Otsikko ja rivitaulun laskujen summan tarkistus

4. Tehtiin SQL-lauseke mikä hakee molemmista tietokannan tauluista INNER JOIN:ia hyödyntäet laskujen tiedot, minkä invoicestatus on -1. 

5. For-Looppia hyödyntäen jokainen ${invoices} elementti päivitettiin statukseen 0 (All OK), mikäli validoinnit suoritettiin onnistuneesti.