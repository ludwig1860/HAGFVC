function  [weightVeg, weightSoil, muVeg, muSoil, varVeg, varSoil] = EstiGaussian (ImgA, muVeg_initial, muSoil_initial, XA, NumASmoothed)
	
    warning('off');
    
	% WEIGHT CALCULATION
    dTotalPixelNum = length( ImgA( : ) );
	
    dVegIdx = ImgA( : ) <= muVeg_initial + 0.5;
	
    dSoilIdx = ImgA( : ) > muSoil_initial -0.5;
	
    PureVeg = ImgA( dVegIdx );  
	
	PureSoil = ImgA( dSoilIdx );
	
    dMuVegIdx = XA == muVeg_initial;    
	
	dMuSoilIdx = XA == muSoil_initial;
	
    dMuVegNum = dTotalPixelNum * NumASmoothed( dMuVegIdx );
	
    dMuSoilNum = dTotalPixelNum * NumASmoothed( dMuSoilIdx );
	
    dNumVeg = 2*length( PureVeg ) - dMuVegNum;  

	dNumSoil = 2 * length( PureSoil ) - dMuSoilNum;
	
    dVegMin = min( PureVeg );   
	
	dSoilMax = max( PureSoil );  
	
	dSoilMin = 2 * muSoil_initial - dSoilMax;
	
    if round( dSoilMax ) > 50
	
        dSoilMax = 50;   
		
		dSoilMin = 2 * muSoil_initial - dSoilMax;
		
    end
	
    weightVeg = dNumVeg / dTotalPixelNum;
	
	weightSoil = dNumSoil / dTotalPixelNum; 

    
   % ESTABLISH DATA BE FITTED
   
   FakeVeg = PureVeg;   
   
   dVegMinIdxOfXA = find( XA == round( dVegMin ) ); 
   
   countVeg = 1;
   
    for k = 1 : round( muVeg_initial - dVegMin + 1 ) - 1
	
        dNumOfNumASingle = dTotalPixelNum * NumASmoothed( dVegMinIdxOfXA + k - 1 );
		
        dValueOfXASingle = XA( dVegMinIdxOfXA + k - 1 );
		
        FakeVeg( countVeg : dNumOfNumASingle + countVeg - 1 ) = 2 * muVeg_initial - dValueOfXASingle;
		
        countVeg = countVeg + dNumOfNumASingle;
		
    end
	
    FakeSoil = PureSoil;    
	
	dSoilMaxIdxOfb = find(XA == round( dSoilMax ) );  
	
	countSoil = 1;
	
    for j = 1 : round( muSoil_initial - dSoilMin + 1 ) - 1
	
        dNumOfNumASingle = dTotalPixelNum * NumASmoothed( dSoilMaxIdxOfb - j + 1 );
		
        dValueOfXASingle = XA( dSoilMaxIdxOfb - j + 1 );
		
        FakeSoil( countSoil : dNumOfNumASingle + countSoil - 1 ) =  2 * muSoil_initial - dValueOfXASingle;
		
        countSoil = countSoil + dNumOfNumASingle;
		
    end
	
    dVegIdx02 = ImgA( : ) < muVeg_initial - 0.5;
	
    dSoilIdx02 = ImgA( : ) >= muSoil_initial + 0.5;
	
    PureVeg02 = ImgA( dVegIdx02 );  
	
	PureSoil02 = ImgA( dSoilIdx02 );
    
    
    
    vegetation = [ PureVeg02 ; FakeVeg ];  
	
	soil = [ PureSoil02 ; FakeSoil ];
    
    % FITTING GAUSSIAN CURVE OF VEGETATION AND BACKGROUND(SOIL) 
	
    [ muVeg , stdVeg ] = normfit( vegetation );     
	
	[muSoil , stdSoil ] = normfit(soil);
	
    varVeg = stdVeg .^ 2;    
	
	varSoil = stdSoil .^ 2;
	
end
