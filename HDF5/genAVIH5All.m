filez = dir('*.h5');



for ii=1:length(filez)
    [~,nm] = fileparts(filez(ii).name);
    
    if ~(exist([nm,'.avi'],'file')==2)
        
        fprintf('Converting file %s...',filez(ii).name);

        genAviH5(filez(ii).name);
        fprintf('done\n');
    end
    
    
end