filez =uigetfile('*.h5','MultiSelect','on');

for ii=1:length(filez)
   genAviH5(filez{ii});
    fprintf('Saved movie %s',filez{ii});
end