clearvars;
filelist=dir;
problem_files={};
for l=1:length(filelist)
    if filelist(l).isdir
        dirpath=strcat('.\',filelist(l).name,'\');
        matfilez=dir(strcat(dirpath,'*.mat'));
        txtfilez=dir(strcat(dirpath,'*.txt'));
        for m=1:length(matfilez)
            matfile2open=strcat(dirpath,matfilez(m).name);
            deets=whos(matfile(matfile2open));
            deet_names={deets.name};
            if (~str_exist_in_cell_array('odor_inf',deet_names) &&...
                str_exist_in_cell_array('acq_start_time',deet_names))
                [date, global_animal_num,local_animal_num,run_number] = ...
                    generate_animal_number(dirpath,matfilez(m).name);
                load(matfile2open)
                logfilename_idx=cellfun(@(x)~isempty(x),strfind({txtfilez.name},...
                    strcat('run',num2str(run_number))));
                logfile=strcat(dirpath,txtfilez(logfilename_idx).name);
                
                if any(logfilename_idx)
                    fname_log = [dirpath txtfilez(logfilename_idx).name];

                    % number of lines
                    fid = fopen(fname_log);
                    allText = textscan(fid,'%s','delimiter','\n');
                    fclose(fid);

                    % strain name
                    numberOfLines = length(allText{1});
                    neuron_type = allText{1,1}{1,1};

                    % the odor information
                    num_ = 3;
                    odor_inf = cell(numberOfLines-num_, 2);
                    fmt='%s\t %d\t';
                    for i = 1:numberOfLines-num_
                        odor_inf(i, :) = textscan(allText{1,1}{i+num_,1}, ...
                            fmt, 'Delimiter','\t');
                    end
                    tseq=cell2mat(odor_inf(:,2));
                    cum_tseq=cumsum(tseq);
                    odor_start_time_rel=cum_tseq(1);
                    odor_end_time_rel=cum_tseq(end-1);
                    odor_start_time=acq_start_time+seconds(odor_start_time_rel);
                    odor_end_time=acq_start_time+seconds(odor_end_time_rel);
                    save(matfile2open)
                    fprintf('Saved %s\n',matfile2open);
                else
                    fprintf('No logfile found for %s\n',matfile2open);
                    problem_files{end+1}=matfile2open;
                end
               
                clearvars -except dirpath matfilez txtfilez m l filelist problem_files
            end
        end
    end
end