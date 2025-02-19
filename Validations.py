def ValidateRefNumber():
    
    return

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


