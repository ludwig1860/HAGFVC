function varargout = CalculateFVC(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CalculateFVC_OpeningFcn, ...
    'gui_OutputFcn',  @CalculateFVC_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CalculateFVC is made visible.
function CalculateFVC_OpeningFcn(hObject, eventdata, handles, varargin)

clc

% Choose default command line output for CalculateFVC
handles.output = hObject;

% ********************************************  INITIALIZATION ******************************************
% IMAGE CROP SETTING
handles.height = 1;     handles.width = 1;

set( handles.txtHeight , 'string' , num2str( handles.height ) );

set( handles.txtWidth , 'string' , num2str( handles.width ) );

% EXPERIENCE THRESHOLD SETTING
set( handles.checkboxDEF , 'value' , 0 );     handles.threshold = -4;

set( handles.txtThreshold , 'string' , num2str( handles.threshold ) );

% IMAGE ADJUSTMENT SETTING
set( handles.checkboxIA , 'value' , 0 );

% HISTOGRAM SAVE SETTING
set( handles.cbHistSave , 'value' , 1 );    set( handles.cbSummarySave , 'value' , 1)

% DEFAULT LOG 
set( handles.tboxLog , 'string' , 'Display Current Process Status');

warning( 'off' );

% ADD COMMENTS ON CONTROLS
set(handles.radioT1 , 'TooltipString' , 'Minimize Misclassification' );

set(handles.radioT2 , 'TooltipString' , 'Equivalent Misclassification');

set(handles.radioEm , 'TooltipString' , 'Experimental Threshold By Users');

set(handles.checkboxDEF , 'TooltipString' , 'Default Threshold: -4');

% ******************************************************************************************************
% Update handles structure
guidata(hObject, handles);

function varargout = CalculateFVC_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function File_Callback(hObject, eventdata, handles)

% MAIN FUNCTION
function btnBatchProcessImg_Callback(hObject, eventdata, handles)

% UPDATE STATUS
 UpdateStatus( handles.tboxLog , 'Running¡­¡­' ,  hObject , handles  );
 
 warning('off','all');
 
% CREAT FOLDERS
if(get(handles.cbHistSave,'value')==1)

    mkdir(handles.outputfilePath,'Histogram Images');
	
end

if get(handles.checkboxIA,'value')==1

    mkdir(handles.outputfilePath,'Stretched Images');
	
end

if (get(handles.cbSummarySave,'value')==1)

    mkdir(handles.outputfilePath,'Summary Images');
	
end

mkdir(handles.outputfilePath,'Binary Images');

mkdir(handles.outputfilePath,'Classification Images');

mkdir(handles.outputfilePath,'MeanSearch Illustration');

numFile=length(handles.filelist);

% PREDEFINED MATRIXS
strFilename=cell(numFile,1); 
   
dFVC = zeros( numFile , 1 );     dThreshold = zeros( numFile , 1 );

dMuVegIni = zeros( numFile , 1 );    dMuSoilIni = zeros( numFile , 1 );

dMuVeg = zeros( numFile , 1 );    dMuSoil = zeros( numFile , 1 );

dVarVeg = zeros( numFile , 1 );    dVarSoil = zeros( numFile , 1 );

dWeightVeg = zeros( numFile , 1 );    dWeightSoil = zeros( numFile , 1 );

dFractionM = zeros( numFile , 1 );    dFractionUC = zeros( numFile , 1 );

hbar = parfor_progressbar(numFile,'PARFOR HAGFVC ALGORITHM TO ESTIMATE FVC...'); 

parfor i=1 : numFile
    
    %% ********************************    READ IMAGES    ************************************

    ImageFullName = [ handles.filePath ,  '\' , handles.filelist(i).name ];
	
    ImageDefaultName = handles.filelist(i).name( 1 : length(handles.filelist(i).name ) - 4 );
	 
    Img = imread( ImageFullName );

    strInfo = [ num2str(i) , ': ' , 'Processing  ' , num2str(i) , '/' ,...
        num2str(numFile) , '[' , handles.filelist(i).name ']' ', Please Wait...'];
		
    UpdateStatus( handles.tboxLog , strInfo ,  hObject , handles  );
    
   %% *********************************    CROP IMAGES    *************************************
    
	ImgCrop  = CutImage( Img , handles.height , handles.width );
	
    ImgCropNOStretched = ImgCrop;
	
    if ( get( handles.cbSummarySave , 'value') == 1 )
	
        mkdir( handles.outputfilePath , 'Cropped_Images');
		
        CropImagePath = [ handles.outputfilePath , '\' , 'Cropped_Images' , '\' ,...
            '\' , handles.filelist(i).name(1:end-4) , '_CROP.jpg' ];
			
        imwrite( ImgCrop , CropImagePath , 'jpg' );
		
    end
    
    %% *******************************    LINEARAL 2% AJUSTMENT    ****************************
   
    if get( handles.checkboxIA , 'value') == 1 
        
		ImgCropStretched = TwoPercentLinStch( ImgCrop );
        
		% SAVE STRETCHED IMAGES
        ImgCropStretched_SPName =[handles.outputfilePath, '\',...
            'Stretched Images', '\',ImageDefaultName '_Stretched.jpg' ];
        
		imwrite( ImgCropStretched , ImgCropStretched_SPName , 'jpg');
        ImgCrop = ImgCropStretched;

    end
    
    %% ***************************  CONVERT RGB TO LAB AND HISTOGRAM  *****************************
	
	[ImgCropLABdbl_A, NumA, XA, NumL, XL] = Convert2A( ImgCrop );
    
    % JUST FOR SUMMARY
	
	[~, NumNSA, XNSA, NumNSL, XNSL] = Convert2A( ImgCropNOStretched );

    %% ********************************   FIND MEANS OF VEG AND BACKGROUND   ************************
    
    % REMOVE 0 VALUE POINTS(AVERAGED)
	
%     dZeroIdxOfA = find( XA == 0 );
	
%     NumA( dZeroIdxOfA ) = ( NumA ( dZeroIdxOfA + 1 ) + NumA( dZeroIdxOfA - 1 ) ) / 2;  
	
    % GAUSSIAN KERNAL SMOOTH
	
    XA_kernal = zeros( length(XA) , 1 );   
	
	NumASmoothed = zeros( length(XA) , 1 );
	
    for p = 1 : 101
	
        XA_kernal(p) = p - 51;
		
        NumASmoothed(p) = Gaussian_kern_reg( XA_kernal(p) , XA ,  NumA / sum( NumA ) , 1 );
		
    end
	
    
    % FIND INITIAL MEANS - method03
    
    window_v  = 8; 

    [ muVeg_initial , muSoil_initial , beginVMat , CuVCell ] = FindMean_m3(  NumA , XA , NumASmoothed , window_v);

    
    %% ***********************   GAUSSIAN MIXTURE MODEL PARAMETER ESTIMATION   *****************************
   
   [weightVeg, weightSoil, muVeg, muSoil, varVeg, varSoil] = EstiGaussian (ImgCropLABdbl_A, muVeg_initial, muSoil_initial, XA, NumASmoothed);
     
    %% *****************************    THRESHOLD CALCULATION AND SETTING  *********************************
    
    % UPDATE STATUS
    UpdateStatus( handles.tboxLog , [num2str(i),': ','Estimating Threshold¡­¡­'] ,  hObject , handles  );

    if ( get ( handles.radioT1 , 'Value' ) == 1)       
		
		flag = 1;
		
		Threshold = CalThresh(flag, muVeg, varVeg, muSoil, varSoil);
		
    elseif ( get( handles.radioT2 , 'Value' ) == 1)    
		
		flag = 2;
		
		Threshold = CalThresh(flag, muVeg, varVeg, weightVeg, muSoil, varSoil, weightSoil);
		
    elseif ( get( handles.checkboxDEF , 'Value' ) == 1)
		
		% CUSTOMER THRESHOLD
        Threshold = handles.threshold;    
    else
		
		% EXPERIMENTAL THRESHOLD  
        Threshold = handles.threshold;    
		
    end
    
    %% **********************************    GREEN COVER  CALCULATION   ******************************
    
    % UPDATE STATUS
    str = [ num2str( i ) , ': ' , 'Calculating Green Vegetation Cover ¡­¡­' ];
    UpdateStatus( handles.tboxLog , str ,  hObject , handles  );
    
	[BW, FalseColor, GreenVegCover] = FClassifier(ImgCropLABdbl_A, Threshold);

    %% ***************************    FRACTION OF UNCERTAINTY PIXELS CALCULATION   *******************
   
    [fr_m , fr_uc] = CalFraction(muVeg , muSoil , ImgCropLABdbl_A);
     
    %% **********************************    PLOT MEAN SEARCHING    **************************

    MESE_V_Name = [ ImageDefaultName  '_MESE_V.png' ];
	
    MESE_V_PathName = [ handles.outputfilePath , '\' , 'MeanSearch Illustration' , '\' , MESE_V_Name ];
    
    PlotMeanSearch( muVeg_initial , beginVMat , CuVCell , Threshold , MESE_V_PathName);
    
    %% ***************************    SAVE CLASSFICATION IMAGES AND HISTOGRAM    *********************
    
    % SAVE BINARY IMAGES
    BWName = [ ImageDefaultName  '_BW.png' ];
	
    BWPathName = [ handles.outputfilePath , '\' , 'Binary Images' , '\' , BWName ];
	
    imwrite( BW , BWPathName , 'png' );
	
    % SAVE CLASSFICATION IMAGES
    FalseColorName = [ ImageDefaultName  '_CLASSIFY.png' ];
	
    FalseColorPathName = [ handles.outputfilePath , '\' , 'Classification Images' , '\' , FalseColorName ];
	
    imwrite( FalseColor , FalseColorPathName , 'png' );
	
    % SAVE HISTOGRAM, FITTING CURVE AND THRESHOLD
    if ( get( handles.cbHistSave , 'value' ) == 1 )
	
        SaveIllusPath = fullfile( handles.outputfilePath , '\' , 'Histogram Images' ,...
            '\' , [ handles.filelist( i ).name( 1 : end - 4 ) , '_Hist' ] );
			
		PlotIllus(XA, NumA, NumASmoothed, ImgCropLABdbl_A, muVeg, varVeg, weightVeg, muSoil, varSoil, weightSoil, Threshold, SaveIllusPath);
				
    end 
    
     %% ******************    SAVE SUMMARY IMAGES OF CIE A&L (ORIGION & STRETCHED)    ********************
    SaveSumPath = fullfile( handles.outputfilePath , '\' , 'Summary Images' ,...
            '\' , [ handles.filelist( i ).name( 1 : end - 4 ) , '_Summary' ] );
			
    if ( get( handles.cbSummarySave , 'value' ) == 1 )
        
		PlotSummary(XNSA, NumNSA, XNSL, NumNSL);
		
        if get(handles.checkboxIA,'value')==1
			
			PlotSummary(XA, NumA, XL, NumL);
			
        end  
		
		saveas( gcf , SaveSumPath , 'png' );
		close( gcf );  
		
    end
    
    %% *********************************    DEFINE VARIABLES STORED    *********************************
    strFilename{ i } = handles.filelist( i ).name;
    
    dFVC( i ) = GreenVegCover;    
    
	dThreshold( i ) = Threshold;    
    
	dMuVegIni( i ) = muVeg_initial;   dMuSoilIni( i ) = muSoil_initial;
    
    dMuVeg( i ) = muVeg; dMuSoil( i ) = muSoil;  
    
	dVarVeg( i ) = varVeg;  dVarSoil( i ) = varSoil;
    
    dWeightVeg( i ) = weightVeg; dWeightSoil( i ) = weightSoil;
    
    dFractionUC( i ) = fr_uc;   dFractionM( i ) = fr_m;
    
    
    %% **********************************   EMBED PROCESS BAR    *********************************
    
    hbar.iterate(1); % update progress by one iteration 

    %*************************************************************************************************
end           
    close(hbar);
    
    %% ******************************FINAL: SAVE RESULTS TO EXCEL *************************************

    % UPDATE STATUS
    str = 'Exporting Results to EXCEL, Please Waiting¡­¡­ ';
	
     UpdateStatus( handles.tboxLog , str ,  hObject , handles  );
	 
    % SAVE RESULTS TO EXCEL
	SaveFVCSheet(handles.outputfilePath,strFilename,dFVC,dThreshold,dMuVegIni,dMuSoilIni,dMuVeg,dMuSoil,dVarVeg,dVarSoil,dWeightVeg,dWeightSoil,dFractionUC,dFractionM);
    
    % UPDATE STATUS
    UpdateStatus( handles.tboxLog , 'Finished Processing' ,  hObject , handles  );
	
    load gong.mat;
    
    sound(y);
    
    clear 

%% ******************************  CONTROLS SETTINGS ***********************************************

function cbHistSave_Callback(hObject, eventdata, handles)
function cbSummarySave_Callback(hObject, eventdata, handles)

function tboxLog_Callback(hObject, eventdata, handles)
function tboxLog_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set( hObject , 'BackgroundColor' , 'white' );
end

function txtOutputPath_Callback(hObject, eventdata, handles)
function txtOutputPath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtFilePath_Callback(hObject, eventdata, handles)
function txtFilePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtWidth_Callback(hObject, eventdata, handles)
handles.width=str2double(get(handles.txtWidth,'string'));
guidata(hObject,handles);

function txtWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtHeight_Callback(hObject, eventdata, handles)
handles.height=str2double(get(handles.txtHeight,'string'));
guidata(hObject,handles);

function txtHeight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function txtThreshold_Callback(hObject, eventdata, handles)

handles.threshold=str2double(get(handles.txtThreshold,'string'));

guidata(hObject,handles);

function txtThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function btnFilePath_ButtonDownFcn(hObject, eventdata, handles)

function btnFilePath_Callback(hObject, eventdata, handles)

filePath = uigetdir( 'I:' , 'Select An Input Folder......' );

filelist = [ dir( [ filePath , '\' , '*.jpg' ] ); dir( [ filePath , '\' , '*.png' ] );...
    dir( [ filePath , '\' , '*.bmp' ] ); dir( [ filePath , '\' , '*.tif' ] );...
    dir( [ filePath , '\' , '*.tiff' ] ); dir( [ filePath , '\' , '*.gif' ] );...
    dir( [ filePath , '\' , '*.jpeg' ] ) ];
	
handles.filelist = filelist;    

handles.filePath = filePath;

set( handles.txtFilePath , 'string' , handles.filePath );

guidata(hObject,handles);

function btnOutputPath_Callback(hObject, eventdata, handles)
% OUTPUT PATH

opath = uigetdir( 'I:' , 'Select An Output Folder......' );

handles.outputfilePath = opath;

set( handles.txtOutputPath , 'string' , handles.outputfilePath );

guidata(hObject,handles);

function btnBWThreshold_Callback(hObject, eventdata, handles)
fileFullPathName=[handles.filePath '\' handles.filelist(1).name];
CalculateThreshold(fileFullPathName);

function radioT1_Callback(hObject, eventdata, handles)
set(handles.radioT1,'value',1);
set(handles.radioT2,'value',0);
set(handles.radioEm,'value',0);

function radioT2_Callback(hObject, eventdata, handles)
set(handles.radioT1,'value',0);
set(handles.radioT2,'value',1);
set(handles.radioEm,'value',0);

function checkboxDEF_Callback(hObject, eventdata, handles)
if get(handles.checkboxDEF,'value')==1
    set(handles.checkboxDEF,'value',1);
    set(handles.txtThreshold,'enable','on');
else
    set(handles.checkboxDEF,'value',0);
    set(handles.txtThreshold,'enable','off');
end

function radioEm_Callback(hObject, eventdata, handles)
set(handles.radioT1,'value',0);
set(handles.radioT2,'value',0);
set(handles.radioEm,'value',1);
set(handles.checkboxDEF,'value',1);
set(handles.txtThreshold,'enable','on');

function checkboxIA_Callback(hObject, eventdata, handles)
if get(handles.checkboxIA,'value')==1
    set(handles.checkboxIA,'value',1);
else
    set(handles.checkboxIA,'value',0);
end
