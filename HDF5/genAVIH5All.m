filez = dir('*.h5');

for ii=1:length(filez)
   genAviH5(filez(ii).name);
    
    
end