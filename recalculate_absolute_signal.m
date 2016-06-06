clear all
filelist=dir;
for l=1:length(filelist)
    if filelist(l).isdir
        dirpath=strcat('.\',filelist(l).name,'\');
        matfilez=dir(strcat(dirpath,'*.mat'));
        for m=1:length(matfilez)
                        fprintf('Loading file %s\n',matfilez(m).name);
            file2open=strcat(dirpath,matfilez(m).name);
            deets=whos(matfile(file2open));
            deet_names={deets.name};
            
            
            if (any(strcmp('normalized_signal',deet_names)) &&...
               any(strcmp('img_stack_maxintensity',deet_names)) &&...     
               any(strcmp('dual_position_data',deet_names)) &&...     
               ~any(strcmp('signal',deet_names)))
                load(file2open);
            
            
                r=40;%radius of circle
                img_size=size(img_stack_maxintensity);
                signal=normalized_signal;
                for k=1:length(neuron_list)
                    for ii=1:length(image_times)
                        x=dual_position_data{ii,k}(1);
                        y=dual_position_data{ii,k}(2);
                        c_mask=circle_mask(img_size(2),img_size(1),x,y,r);
                        img=img_stack_maxintensity(:,:,ii);
                        signal{k}(ii)=calculate_intensity(img(c_mask));
                    end
                end
                curve_plot(signal,image_times,odor_seq,neuron_list)
                saveas(gcf,[pathname, filename, '_',num2str(istart),'-',num2str(iend),'-', neuron_list{1} ,'.fig']);
                disp('saving!')
                save(fnamemat,'signal','r','-append')
                
                close all
            end
            clearvars -except filelist folderz matfilez l m dirpath
        end
    end
    
end