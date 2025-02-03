# Ohjelmistorobotiikka
Ohjelmistorobotiikka ja -automaatio

Työvaiheet: 

1. Luodaan Data taulut Laskujen otsikoille ja riveille. Määritellään data taulujen sisältö tietokanta taulujen sarakkeiden nimien mukaisesti.

2. Luodaan uusi muuttuja mihin tallennetaan kaikki SourceFiles hakemiston .pdf päätteiset tiedostot, tässä tapauksessa kaikki pdf muodossa olevat laskut.

3. For-Each looppia hyödyntäen luemme kaikki tiedostot muuttujasta käyttäen Read PDF Text aktiviteettia ja tulostamme ne logiin.

4. Haetaan SubString metodia käyttämällä saadusta tulosteesta kohta CompanyCode ja määritellään se vastaamaan oikeaa Y-tunnus tulostetta ja tallennetaan tämä tieto omaan CompanyCode muuttujaan.

5. Lisätään Switch-aktiviteetti millä varmistamme, että eri Y-Tunnuksen laskut tallentuvat Data tauluun.

6. Lisätään Add Data Row aktiviteetti, millä lisätään Data Tauluun oikeaan sarakkeeseen muuttujan CompanyCoden tieto.

7. Lopuksi kirjoitetaan ResultFile hakemistoon Write-CSV aktiviteetilla uusi .csv tiedosto mikä sisältää laskujen otsikko datan.

8. Haetaan ja lisätään tarvittavat tiedot CSV-tiedostoon
