function ys = Gaussian_kern_reg(xs, x, y, h)
% Gaussian kernel function

	kerf = @( z )exp( -z .* z/2 ) / sqrt( 2 * pi );

	z = kerf( ( xs - x ) / h );
	
	ys = sum( z .* y ) / sum( z );

end
