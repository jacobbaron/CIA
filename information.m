%% %odor list
odor_list = [{'1-pentanol'}; ...        %alcohol 
    {'3-pentanol'}; ...
    {'trans-3-hexen-1-ol'}; ...
    {'6-methyl-5-hepten-2-ol' }; ...
    {'3-octanol'}; ...                  
    {'methyl phenyl sulfide'}; ...      %phenyl group
    {'anisole'}; ...
    {'2-acetylpyridine'}; ...
    {'2,5-dimethylpyrazine'}; ...   
    {'pentyl acetate'}; ...             %acetate
    {'geranyl acetate'}; ...
    {'2-methoxyphenyl acetate'}; ...
    {'trans-2-hexen-1-al'}; ...         %aldehyde
    {'trans,trans-2,4-nonadienal'}; ...
    {'4-methyl-5-vinylthiazole'}; ...   %thiazole
    {'4,5-dimethylthiazole'}; ...
    {'4-hexen-3-one'}; ...              %ketone
    {'2-nonanone'}; ...                 
    {'acetal'}];                        %acetal

%% %concentration list
odor_concentration_list = [{'10^-8'}; {'10^-7'}; {'10^-6'}; {'10^-5'}; {'10^-4'}; {'10^-3'}];    %concentrations

%% %colormap
odor_num = length(odor_list);
con_num = length(odor_concentration_list);

color_num = odor_num*con_num;
if color_num<128
    color_num = 128;
elseif color_num<256
    color_num = 256;
elseif color_num<512
    color_num = 512;
end

odor_colormap = colorcube(color_num); 
odor_colormap = odor_colormap(1:odor_num*con_num,:); 

%% %show colormap
data_show = 1:odor_num*con_num;
data_show = reshape(data_show,con_num, odor_num)';

figure
imagesc(data_show); 
colormap(odor_colormap);

title('Odor Colormap')
set(gca,'XTick',1:con_num);
set(gca,'XTickLabel',odor_concentration_list)
xlabel('Concentration');
set(gca,'YTick',1:odor_num);
set(gca,'YTickLabel',odor_list);
ylabel('Odor Type');

%% Save data and figure
currentFolder = pwd;
path = [currentFolder, '\data\'];
if ~exist(path, 'dir');
    mkdir(path);
end
save([path, 'odor_inf'], 'odor_list', 'odor_concentration_list', 'odor_colormap');
saveas(gcf,[path, 'odor_colormap.fig']);