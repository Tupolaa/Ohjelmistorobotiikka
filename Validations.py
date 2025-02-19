def ValidateRefNumber():
    
    return

def ValidateIban():
    
    
    return

def ValidateAmount(HeaderAmount, RowAmount, MaxDIFF):
    if(abs(HeaderAmount-RowAmount) < MaxDIFF):
        return True    
    return False