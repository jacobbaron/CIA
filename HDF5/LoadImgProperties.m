function [piezo,volumes,lasers,t,img_idx,res,...
    start_time]=LoadImgProperties(fname)
    
    %double(h5read(fname,'/img_idx'));
    DAQ=h5read(fname,'/DAQ');
    res=h5readatt(fname,'/','Resolution');
    tinfo = h5info(fname,'/t');
    tstart = double(h5read(fname,'/t',1,2))/1e9;
    dt = diff(tstart);
    t = (0:dt:(dt*(tinfo.Dataspace.Size-1)))';
    %t=double(h5read(fname,'/t'))/1e9;
    img_idx = 1:length(t);
    piezo=DAQ(img_idx,1);
   
    lasers=DAQ(img_idx,2:end-1);
    volumes=DAQ(img_idx,end);
    start_time_str=h5readatt(fname,'/','Start Time');
    start_time=datetime(start_time_str{1},'InputFormat','yyyyMMdd HH:mm:ss');
%     if length(img_idx)<length(volumes)
%         lasers=lasers(img_idx,:);
%         piezo=piezo(img_idx);
%         volumes=volumes(img_idx);
%     end
%     img_idx=(1:length(img_idx))';