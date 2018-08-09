function [ fr_m , fr_uc ] = CalFraction(muVeg , muSoil , ImgA)
% CALCULATE THE FRACTION OF PURE VEGETATION PIXELS, PURE SOIL PIXELS
% AND UNCERTAINTY PIXELS (SUGGESTED BY Craig Macfarlane)
% fr_v , fr_b, , mode

    vinx = find( ImgA <= muVeg );
    fr_v = numel(vinx)/numel(ImgA);

    binx = find( ImgA >= muSoil );
    fr_b = numel(binx)/numel(ImgA);
    
    fr_uc = 1 - fr_v - fr_b;
    
    fr_m = 1 - 2 * fr_v - 2 * fr_b;
             
%     if strcmp(mode , 'uc')
% 
%         fr_m_uc = 1 - fr_v - fr_b;
% 
%     elseif strcmp(mode , 'm')
%     
%         fr_m_uc = 1 - 2 * fr_v - 2 * fr_b;
% 
%     end


end