function  [BW, FalseColor, GreenVegCover] = FClassifier(ImgA, Threshold)

	% IMAGE BINARIZATION
    IdxGreenVeg = ImgA <= Threshold;  
	IdxBackground = ImgA > Threshold;
	
    BW = zeros( size( ImgA ) );   
	BW( IdxGreenVeg ) = 1; 
	BW = logical( BW );   
	colormap(gray);
    BW = bwareaopen( BW, 10); % REMOVE NOISE
	
    % COLORED BINARIZATION
    FalseColorR = zeros( size( ImgA ) );  FalseColorR( IdxGreenVeg ) = 0;  
    FalseColorR( IdxBackground ) = 64;  FalseColorR = uint8( FalseColorR );
	
    FalseColorG = zeros( size( ImgA ) );  FalseColorG( IdxGreenVeg ) = 156;  
    FalseColorG( IdxBackground ) = 64;  FalseColorG = uint8( FalseColorG );
	
    FalseColorB = zeros( size( ImgA ) );  FalseColorB( IdxGreenVeg ) = 103;  
    FalseColorB( IdxBackground ) = 64;  FalseColorB = uint8( FalseColorB );
	
    FalseColor = cat( 3 , FalseColorR , FalseColorG , FalseColorB );
	
    % CALCULATE GREEN VEGETATION COVER 
	idx = find( 1 == BW(:) ); 
	v_pix_num = length( idx );
	VegCover = v_pix_num / length( BW(:) );
	
    if VegCover == 1
        GreenVegCover =  1.000;
    elseif VegCover < 0.001
        GreenVegCover = 0.000;
    else
        GreenVegCover = VegCover;
    end
	
end