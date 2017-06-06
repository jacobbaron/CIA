function [piezo,volumes,lasers,t,img_idx,res,...
    start_time]=LoadImgProperties(fname)
    img_idx=double(h5read(fname,'/img_idx'));
    DAQ=h5read(fname,'/DAQ');
    res=h5readatt(fname,'/','Resolution');
    t=double(h5read(fname,'/t'))/1e9;
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