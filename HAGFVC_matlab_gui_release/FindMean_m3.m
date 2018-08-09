% function [ muVeg_initial , muSoil_initial ] = FindMean_m3(  NumA , XA , NumASmoothed , window_v)

function [ muVeg_initial , muSoil_initial , beginVMat , CuVCell ] = FindMean_m3(  NumA , XA , NumASmoothed , window_v)
    
    % CURVATURE COMPARISON IN MULTIPLE SMOOTHING SCALE
    
%     [ meanVVec ] = CalVegMean( NumA , XA , window_v );
    
    [ meanVVec , beginVMat , CuVCell ] = CalVegMean( NumA , XA , window_v);
    
    [ meanSVec ] = CalSoilMean( NumASmoothed , XA );
    
    % DELETE INCORRECT MEAN IN SOME SEARCHING SCALE
    
    MuVegMat = meanVVec;  
    
    MuVegMat( MuVegMat == 0 ) = [];    
    
%     if backupTempMvalue(4,1)<-22||backupTempMvalue(4,1)>-10
        
        muVeg_initial = ceil( mean( MuVegMat ) );
        
%     else
        
%         muVeg_initial=backupTempMvalue(4,1);
        
%     end
    
    muSoil_initial = meanSVec;

end

%% CALCULATE MEAN OF VEGETATION

% function [ meanVVec ] = CalVegMean( NumA , XA , window)
function [ meanVVec , beginMat , CuCell ] = CalVegMean( NumA , XA , window)

    meanVVec = zeros( window - 1 , 1 );  
    
    beginMat = zeros( window - 1 , 1 ); 
    
    CuCell = cell(window - 1 , 1 );
    
    for t = 2 : 1 : window
        
        % SMOOTH CURVE
        
        NumASmoothed = smooth ( NumA / sum( NumA ), t );  
                
        % SEARCH FIRST LOCAL MAXIMUM CURVATURE
        
        [meanVVec( t-1 , 1 ) , beginMat( t-1 ), CuCell{ t-1 }] = FindVmean( NumASmoothed , XA );
        
        % FIND INCORRECT MEAN IN SOME SEARCHING SCALE

        if meanVVec( t-1 , 1 ) < -22 || meanVVec( t-1 , 1 ) > -10
            
            meanVVec( t-1 , 1 ) = 0;
            
        end
        
    end

end

%% CALCULATE MEAN OF SOIL 

function [ meanSVec ] = CalSoilMean(  NumASmoothed , XA )

    % REMOVE VERY SMALL VALUE
	NumASmoothed_cut_idx =  NumASmoothed > 0.005 ;

	NumASmoothed_cut = NumASmoothed( NumASmoothed_cut_idx );

	% FIND LOCAL MAXIMUM OF SOIL
	for j = length( NumASmoothed_cut ) - 1 : -1 : 2

		if NumASmoothed_cut(j+1) < NumASmoothed_cut(j) && NumASmoothed_cut(j-1) < NumASmoothed_cut(j)
		
			LocalMaxIdx =  NumASmoothed == NumASmoothed_cut(j) ;
			
			meanSVec = XA( LocalMaxIdx );
			
			break
			
		end

	end

end

function [ mSoil ] = FindSmean( a , xa )
    
    % TURE OVER VECTOR
    
    a = flipud( a );
    
    xa = flipud( xa' );
        
    % DELETE SAMLL POINTS
     
    cut_idx = find( a > 0.005 );
    
    a_cut = a( cut_idx );
    
    xa_cut = xa( cut_idx );
    
    % CALCULATE SECOND DERIVATIVE AND CURVITY
    
    slope = zeros( numel( cut_idx ) - 1 , 2 );
    
    second_derivative = zeros( numel( cut_idx ) - 2 , 2 );
    
    curvature = zeros( numel( cut_idx ) - 2 , 2 );
    
    % SLOPE

    temp1 = xa_cut( 2 : end );
    
    slope( : , 1 ) = flipud( temp1' );
    
    for p = 1 : numel(cut_idx) - 1
        
        slope( p , 2 ) = ( a_cut( p + 1 ) - a_cut( p ) ) / ( xa_cut( p + 1 ) - xa_cut( p ) );
        
    end
    
    % SECOND DERIVATIVE
    
    temp2 = xa_cut( 2 : end - 1 );
    
    second_derivative( : , 1 ) = flipud( temp2' );
    
    for q = 1 : numel( cut_idx ) - 2
        
        second_derivative( q , 2 ) = ( slope( q + 1 , 2 ) - slope( q , 2 ) ) / ( xa_cut( p + 1 ) - xa_cut( p ) );
        
    end
    
    % CURVATURE   >0 - concave 凹面 ;   <0  -  convex 凸面
    
   curvature( : , 1 ) = flipud( temp2' );
   
    for m = 1 : numel( cut_idx ) - 2
        
        curvature( m , 2 ) = ( second_derivative( m , 2 ) ) ./ ( 1 + slope( m , 2 ) .^ 2 ) .^ 1.5;
        
    end

    curvature( : , 2 ) = 10000 * curvature( : , 2 );
    
    % BEGIN FROM CURVATURE<0 (CONVEX) POINT
    
    bIdx = curvature ( : , 1 );            cu = curvature( : , 2 );
    
    num = numel( curvature( : , 1 ) );     count=0;  

    if cu( 1 ) > 0
        
        for i = 1 : num
            
            if cu( i ) >0
                
                count = count + 1;
                
                if cu( i + 1 )<0
                    
                    break
                    
                end
                
            end
            
        end
        
    end

    if count >= 1
        
        begin = count + 2;
        
    else
        
        begin = 3;
        
    end

    % ALL LOCAL MAXIMUM CURVATURE POINT
    
    matchRule = [];    k=1;
        
    for j = begin : num - 2
    
        if cu(j)<0  &&abs(cu(j+1))-abs(cu(j))<0  && abs(cu(j-1))-abs(cu(j))<0  % searching rule
            
            if cu( j + 2 ) < cu( j )   %
                
                matchRule( k ) = bIdx( j + 2 );
            
            else
                
                matchRule( k ) = bIdx( j );
            
            end
            
            k=k+1;
            
        end
        
    end

    % MEAN POINT - FIRST LOCAL MAXIMUM CURVATURE POINT
    
    if isempty( matchRule )
        
        matchRule(1) = 0;
        
        mVeg = matchRule(1);  % MARKED
        
    else

%         mSoil = matchRule( 1 ) - 1;
        mSoil = matchRule( 1 );
    
    end

end


% function [ mVeg ] = FindVmean( a , xa )

function [ mVeg , begin , curvature ] = FindVmean( a , xa )
    
    % DELETE SAMLL POINTS
    
    cut_idx = find( a > 0.005 );
    
    a_cut = a( cut_idx );
    
    xa_cut = xa( cut_idx );
    
    % CALCULATE SECOND DERIVATIVE AND CURVATURE
    
    slope = zeros( numel( cut_idx ) - 1 , 2 );
    
    second_derivative = zeros( numel( cut_idx ) - 2 , 2 );
    
    curvature = zeros( numel( cut_idx ) - 2 , 2 );
    
    % SLOPE
    
    slope( : , 1 ) = xa_cut( 2 : end );
    
    for p = 1 : numel(cut_idx) - 1
        
        slope( p , 2 ) = ( a_cut( p + 1 ) - a_cut( p ) ) / ( xa_cut( p + 1 ) - xa_cut( p ) );
        
    end
    
    % SECOND DERIVATIVE
    
    second_derivative( : , 1 ) = xa_cut( 2 : end - 1 );
    
    for q = 1 : numel( cut_idx ) - 2
        
        second_derivative( q , 2 ) = ( slope( q + 1 , 2 ) - slope( q , 2 ) ) / ( xa_cut( p + 1 ) - xa_cut( p ) );
        
    end
    
    % CURVATURE   >0 - concave 凹面 ;   <0  -  convex 凸面
    
    curvature( : , 1 ) = xa_cut( 2 : end - 1 );
    
    for m = 1 : numel( cut_idx ) - 2
        
        curvature( m , 2 ) = ( second_derivative( m , 2 ) ) ./ ( 1 + slope( m , 2 ) .^ 2 ) .^ 1.5;
        
    end

    curvature( : , 2 ) = 10000 * curvature( : , 2 );
    
    % BEGIN FROM CURVATURE<0 (CONVEX) POINT
    
    bIdx = curvature ( : , 1 );            cu = curvature( : , 2 );
    
    num = numel( curvature( : , 1 ) );     count=0;  
    
    if cu( 1 ) > 0
        
        for i = 1 : num
            
            if cu( i ) >0
                
                count = count + 1;
                
                if cu( i + 1 )<0
                    
                    break
                    
                end
                
            end
            
        end
        
    end

    if count >= 1
        
        begin = count + 2;
        
    else
        
        begin = 3;
        
    end

    % ALL LOCAL MAXIMUM CURVATURE POINT
    
    matchRule = [];    k=1;

    for j = begin : num - 2
   
        if cu(j) < 0  && abs(cu(j+1)) - abs(cu(j)) < 0  && abs(cu(j-2)) - abs(cu(j)) < 0 && abs(cu(j-1)) - abs(cu(j)) < 0  % searching rule

            if cu( j + 2 ) < cu( j )
                
                matchRule( k ) = bIdx( j + 2 );
                
            elseif cu( j - 2 ) < cu( j )
                
                matchRule( k ) = bIdx( j - 2 );
                
            else
                
                matchRule( k ) = bIdx( j );
                
            end
            
            k = k + 1;
            
        end
    end

    % MEAN POINT - FIRST LOCAL MAXIMUM CURVATURE POINT
    
    if isempty( matchRule )
        
        matchRule(1) = 0;
        
        mVeg = matchRule(1);  % MARKED
        
    else
        
        % SET SEARCH RANGE
        
        sectionIdx = matchRule > -25;
        
        matchRule = matchRule( sectionIdx );
        
%         mVeg = matchRule( 1 ) + 2;
        
        mVeg=matchRule(1);
    end

end

