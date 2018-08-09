function PlotMeanSearch( muVeg_initial , beginVMat , CuVCell , Threshold , MESE_V_PathName)

    % EXTRACT VEG PART
    
    T = round( Threshold );
    
    h = figure( 'visible' , 'off');
    
    legendInfo = cell(1 , numel( beginVMat ) );
    
    for i = 1 : 1 : numel( beginVMat )
        
        inx = find( CuVCell{i}( : , 1 )  == T );
            
        x = CuVCell{i}( : , 1 );
        
        y = CuVCell{i}( : , 2 );
        
        plot( x(1 : inx) , y(1 : inx) , 'Marker' , '*' , 'linewidth' , 1.5);
        
        legendInfo{i} = ['Smooth Level = ',num2str( i + 1 )];
        
        hold on
    
    end
    
    % PLOT INITIAL VEG_MEAN 
    
    yini = [ min(CuVCell{1}( 1 : inx , 2 )),  max(CuVCell{1}( 1 : inx , 2 )) ];
    
    xini = muVeg_initial * ones( 2 , 1 );
    
    plot( xini , yini , '--m' , 'linewidth' , 3 );
    
    hold on
    
    % PLOT FINAL VEG_MEAN 
    
%     yfin = [ min(CuVCell{1}( 1 : inx , 2 )),  max(CuVCell{1}( 1 : inx , 2 )) ];
    
%     xfin = muVeg * ones( 2 , 1 );
    
%     plot( xfin , yfin , '--r' , 'linewidth' , 2 );
    
    % PLOT LINE Y=0
    x0 =  [ min(CuVCell{1}( : , 1 )),  max(CuVCell{1}( : , 1 )) ];
    
    y0 = [0 , 0];
    
    plot( x0 , y0 , ':k' , 'linewidth' , 2 )

    xlim( [ min( CuVCell{1}( : , 1 ) )   max( CuVCell{1}( : , 1 ) ) ] ); 
    
    set( gca , 'XTick' , min( CuVCell{1}( : , 1 ) ) : 2 : max( CuVCell{1}( : , 1 ) ) ,...
        'xcolor' , 'k' , 'ycolor' , 'k' , 'box' , 'off' );
    
    xlabel('CIE a* value'); 
    
    ylabel('10000 * Curvature');
    
    % LEGEND

    legend(legendInfo,'Mean Value');

    % SAVE

    saveas( h , MESE_V_PathName , 'png' );

end