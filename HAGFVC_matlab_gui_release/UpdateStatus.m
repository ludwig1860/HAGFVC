function UpdateStatus( Log , str , hObject , handles )
% updateStatus - Update status of workflow
%   str - string
    set( Log , 'string' , str );
	
    guidata( hObject , handles );
	
    pause( 0.01 );
	
end

