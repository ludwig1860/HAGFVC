
function SaveFVCSheet(outFolderPath,strFilename,dFVC,dThreshold,dMuVegIni,dMuSoilIni,dMuVeg,dMuSoil,dVarVeg,dVarSoil,dWeightVeg,dWeightSoil,dFractionUC,dFractionM)
    % SaveFVCSheet.m SAVE RESULTS TO EXCEL
	
	% strSavePath = fullfile( handles.outputfilePath , 'Results.xlsx' );
	strSavePath = fullfile( outFolderPath , 'FVC_ESTIMATES.xlsx' );
	
    titles = { 'Filename' , 'FVC' , 'Threshold' , 'Mean_Veg_Ini' , 'Mean_Soil_Ini' , 'Mean_Veg',...
        'Mean_Soil' , 'Var_Veg' , 'Var_Soil' , 'Weight_Veg' , 'Weight_Soil','Fraction of Uncertainty Pixels',...
        'Fraction of Mixed Pixels'};
	
    xlswrite( strSavePath , titles , 'Sheet1' , 'A1' );
    xlswrite( strSavePath , strFilename , 'Sheet1' , 'A2' );
    xlswrite( strSavePath , dFVC , 'Sheet1' , 'B2' );
    xlswrite( strSavePath , dThreshold , 'Sheet1' , 'C2' );
    xlswrite( strSavePath , dMuVegIni , 'Sheet1' , 'D2' );  
    xlswrite( strSavePath , dMuSoilIni , 'Sheet1' , 'E2' );
    xlswrite( strSavePath , dMuVeg , 'Sheet1' , 'F2' );  
    xlswrite( strSavePath , dMuSoil , 'Sheet1' , 'G2' );
    xlswrite( strSavePath , dVarVeg , 'Sheet1' , 'H2' );  
    xlswrite( strSavePath , dVarSoil , 'Sheet1' , 'I2' );
    xlswrite( strSavePath , dWeightVeg , 'Sheet1' , 'J2' );  
    xlswrite( strSavePath , dWeightSoil , 'Sheet1' , 'K2' );
    xlswrite( strSavePath , dFractionUC , 'Sheet1' , 'L2' );
	xlswrite( strSavePath , dFractionM , 'Sheet1' , 'M2' );
    
    strProcessTime = { 'Process Time' , datestr( now , 31 ) } ;
    xlswrite( strSavePath , strProcessTime , 'Sheet1' , [ 'A' , num2str( length(dFVC) + 5 ) ] );    

end
