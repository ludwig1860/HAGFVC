function  Threshold = CalThresh(flag, muVeg, varVeg, weightVeg, muSoil, varSoil, weightSoil)
  
  % T1 - MINIMIZE SUM OF MISCLASSIFICATION ERROR 
  if flag == 1
  
	A = varVeg - varSoil;  
	
	B = 2 * ( muVeg * varSoil - muSoil * varVeg );
	
    C = varVeg * muSoil * muSoil - varSoil * muVeg * muVeg + 2 * varVeg * ...
            2 * varSoil * log( sqrt( varSoil ) * weightVeg / ( sqrt( varVeg ) * weightSoil ) );
			
    delta = B * B - 4 * A * C;
    
	if varVeg ~= varSoil && delta >0
	
        Temp1 = ( -B + sqrt( B * B - 4 * A * C ) ) / ( 2 * A );
		
        Temp2 = ( -B - sqrt( B * B - 4 * A * C ) ) / ( 2 * A );
		
        if Temp1 > muVeg && Temp1 < muSoil
            
			Threshold = Temp1;
			
        elseif Temp2 > muVeg && Temp2 < muSoil
		
            Threshold = Temp2;
			
        else
		
            Threshold = ( muVeg + muSoil ) / 2 + ( weightVeg * varVeg + weightSoil * varSoil ) *...
                log( weightSoil /weightVeg ) / ( muSoil - muVeg );
        end
    else
	
        Threshold = ( muVeg + muSoil ) / 2 + ( weightVeg * varVeg + weightSoil * varSoil ) *...
            log( weightSoil / weigh);
			
	end
	
  % T2 - EQUIVALENT MISCLASSIFICATION ERROR
  elseif flag == 2
  
	func = @( x )weightSoil * erfc( ( muSoil - x ) / ( sqrt( varSoil ) * sqrt( 2 ) ) ) ...
            - weightVeg * erfc( ( x - muVeg ) / ( sqrt( varVeg ) * sqrt( 2 ) ) );
			
    Threshold = fzero( func , ( muSoil + muVeg ) / 2 );     
	
  end
		
end