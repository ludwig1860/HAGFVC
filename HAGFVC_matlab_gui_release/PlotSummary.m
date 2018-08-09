function PlotSummary(XA, NumA, XL, NumL)		
		
	hf1 = figure( 'visible' , 'off' );
	
    % THUMB - CIE A HISTOGRAM(NO STRETCHED)
    subplot( 2 , 2 , 1 );   bar( XA , NumA / sum( NumA ) , 'r' ,'edgecolor','none' );
    title( 'CIE A HISTOGRAM' );   xlim( [ -50 50 ] );   ylim( [0 0.1] );
    set( gca , 'XTick' , -50 : 25 : 50 , 'YTick' , 0 : 0.05 : 0.1 , 'xcolor' , 'k' , 'ycolor' , 'k' , 'box' , 'off' );
	
    % THUMB - CIE L HISTOGRAM(NO STRETCHED)
    subplot( 2 , 2 , 2 );   bar( XL , NumL / sum( NumL ) , 'g' , 'edgecolor','none' );
    title( 'CIE L HISTOGRAM' );   xlim( [ 0 120 ] );   ylim([0 0.1]);
    set( gca , 'XTick' , 0 : 20 : 120 , 'YTick' , 0 :0.05 : 0.1 , 'xcolor' , 'k' , 'ycolor' , 'k' , 'box' , 'off' );
	
		
end