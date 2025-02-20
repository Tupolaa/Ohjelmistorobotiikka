def ValidateRefNumber(referenceNum):
    
    if not referenceNum.isdigit() or len(referenceNum) < 4:
        return False
    
    numbers = [7,3,1] 
    checksum = sum(int(d) * numbers[i % 3] for i, d in enumerate(referenceNum[-2::-1]))

    if (10 - (checksum % 10)) % 10 == int(referenceNum[-1]):  
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


print (ValidateRefNumber("1431432"))