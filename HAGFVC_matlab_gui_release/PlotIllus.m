function PlotIllus(XA, NumA, NumASmoothed, ImgCropLABdbl_A, muVeg, varVeg, weightVeg, muSoil, varSoil, weightSoil, Threshold, SaveIllusPath)
		h = figure( 'visible' , 'off');
		
		% HISTOGRAM
        bar( XA , NumA / sum ( NumA ) , 'k' , 'stack','edgecolor','none' );  
		hold on
		
		% SMOOTHED CURVE
        plot( XA , NumASmoothed, 'c ', 'LineWidth' , 1.5 ); 
		hold on 
		
		% GAUSSIAN DISTRIBUTION - VEGETATION
        X = unique( ImgCropLABdbl_A( : ) );  
        y_Veg = normpdf( X , muVeg , sqrt( varVeg ) );
        y1 = y_Veg * weightVeg; 
		plot( X , y1 , 'g' , 'LineWidth' , 2.5 );    
		hold on
		
		% GAUSSIAN DISTRIBUTION - SOIL
        y_Soil = normpdf( X ,muSoil , sqrt( varSoil ) );
        y2 = y_Soil * weightSoil;   
		plot( X , y2 , 'color' , [1 0.7 0.2] , 'LineWidth' , 2.5 );  
		hold on
		
		% THRESHOLD
        yThresh = 0 : 0.05 : 0.1;    
		xThresh = Threshold * ones( 3 , 1 );
        plot( xThresh , yThresh , 'm' , 'linewidth' , 2 );   
		hold on
		
		% MEAN VALUE
        ymuVeg = 0 : 0.005 : 0.1;    
		xmuVeg = muVeg * ones( length(ymuVeg) , 1 );
        plot( xmuVeg , ymuVeg , '--g' , 'linewidth' , 2 ); 
		hold on
        ymuSoil = 0 :0.005: 0.1;    
		xmuVeg = muSoil * ones( length(ymuSoil) , 1 );
        plot( xmuVeg , ymuSoil ,'--','color' , [1 0.7 0.2]  , 'linewidth' , 2 );  
		
		xlim( [ -40 20 ] );   ylim( [ 0 0.2 ] );
        set( gca , 'XTick' , -40 : 5 : 20 , 'YTick' , 0 : 0.02 : 0.2,...
            'xcolor' , 'k' , 'ycolor' , 'k' , 'box' , 'off' );
        legend('Histogram of a* Values','Smoothed  Curve',...
            'Gaussian - Vegetation','Gaussian - Background','Threshold',...
            'Mean - Vegetation' , 'Mean - Background'); 
        grid on
		
        width=800;  height=300;  left=200;   bottem=100;
        set(h,'position',[left,bottem,width,height])
		
        saveas( h , SaveIllusPath , 'png');
        close ( h );          
		
end