clearvars;
filelist=dir;
problem_files={};
for l=1:length(filelist)
    if filelist(l).isdir
        dirpath=strcat('.\',filelist(l).name,'\');
        matfilez=dir(strcat(dirpath,'*.mat'));
        for m=1:length(matfilez)
            matfile2open=strcat(dirpath,matfilez(m).name);
            deets=whos(matfile(matfile2open));
            deet_names={deets.name};
            if ~str_exist_in_cell_array('odor_start_time',deet_names) ||...
                ~str_exist_in_cell_array('odor_end_time',deet_names)
                try 
                    [odor_start_time, odor_end_time]=...
                        calculate_odor_start_end_time(matfile2open);
                    save(matfile2open,'odor_start_time','odor_end_time','-append')
                    fprintf('Added odor time info to file %s\n',matfile2open);
                catch
                    fprintf('Cannot Load %s\n',matfile2open);
                    problem_files{end+1}=matfile2open;
                end
            end
        end
    end
end