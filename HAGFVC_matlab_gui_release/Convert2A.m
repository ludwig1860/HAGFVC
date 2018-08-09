function [img_lab_dbl_A, NumA, XA, NumL, XL] = Convert2A( img )
	
	cform = makecform( 'srgb2lab' );
	
	img_lab = applycform( img , cform ); 
   
	img_lab_dbl = lab2double( img_lab );
	
    img_lab_dbl_A = img_lab_dbl( : , : , 2 );      
	
	img_lab_dbl_L = img_lab_dbl( : , : , 1 );

    [ NumA , XA ] = hist( img_lab_dbl_A( : ) , -50 : 1 : 50 );
	
	[ NumL , XL ] = hist( img_lab_dbl_L( : ) , 0 : 1 : 120 );
	
end
