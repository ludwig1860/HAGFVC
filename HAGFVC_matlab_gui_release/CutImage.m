function [ img_rgb2 ] = CutImage( img_rgb, height, width )
% cutImage function conducts crop job according to ratio of height/width
%   Input parameter1 : img_rgb  input RGB image
%   Input parameter2 : height   the height of img_rgb
%   Input parameter3 : width    the width of img_rgb
%   Output parameter : img_rgb2  the cropped RGB image

	[ row , column ] = size( img_rgb( : , : , 1 ) );

	rh = ceil( ( 1 - height ) * row / 2 );   

	if rh == 0

		rh = 1;
		
	end

	rw = ceil( ( 1 - width ) * column / 2 );

	if rw == 0

		rw = 1;
		
	end

	img_rgb2 = img_rgb( rh : row - rh , rw : column - rw , 1 : 3 );

	clear img_rgb row column
end

