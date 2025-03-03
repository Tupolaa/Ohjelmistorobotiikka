def ValidateRefNumber(referenceNum):
    
    # Tarkistetaan, että viitenumero on pituudeltaan vähintään 4 merkkiä pitkä
    if len(referenceNum) < 4:
        return False
    
    check_numbers = [7, 3, 1]
    
    
    checksum = 0 

    # Käydään läpi viitenumeron kaikki numerot lukuunottamatta viimeistä, joka on sitten tarkistenumero
    for i in range(len(referenceNum) - 1):
        
        digits = int(referenceNum[-2 - i])  # Luetaan numerot oikealta vasemmalle
        multiplier = check_numbers[i % 3]  # Valitaan järjestys 7, 3, 1
        
        checksum = checksum + (digits * multiplier)

    # Määritetään tarkistenumero
    next_ten = (checksum + 9) // 10 * 10
    check_digit = next_ten - checksum

    # Verrataan laskettua tarkistenumeroa annettuun tarkistenumeroon
    if check_digit == int(referenceNum[-1]):
        return True

    return False


def ValidateIban(iban: str):
    iban = iban.replace(" ", "").upper() 
    
    if not (iban.startswith("FI") and len(iban) == 18):
        return False
    
    iban = iban[4:] + iban[:4]
    iban = iban.replace("FI", "1518", 1)
    
    if int(iban) % 97 == 1:
        return True

    return False


def ValidateAmount(HeaderAmount, RowAmount, MaxDIFF):
    if(abs(HeaderAmount-RowAmount) < MaxDIFF):
        return True    
    return False
