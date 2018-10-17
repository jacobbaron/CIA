function [redFiltImg] = form_mov_mat(filename)

[piezo,volumes,lasers,t,img_idx,res,...
    acq_start_time]=LoadImgProperties(filename);
piezo=piezo(1:length(img_idx));
volumes=volumes(1:length(img_idx));
lasers=lasers(1:length(img_idx),:);
image_times=zeros(max(volumes),1);
for ii=1:max(volumes)
    image_times(ii)=mean(t(volumes==ii));
end

which_lasers=find(any(lasers,1));
zstack_pos=20*(piezo(volumes==1 & lasers(:,which_lasers(1))));
zdiff_size=diff(zstack_pos);

unique_lasers=find(any(lasers,1));
    num_lasers=length(find(any(lasers,1)));    
    
    for ii=1:size(lasers,2)
        zdepth(ii)=length(find(lasers(volumes==1,ii)));
    end


movSize = double([res(1),res(2),max(zdepth),length(unique(volumes(volumes>0)))]);

start_time_str=h5readatt(filename,'/','Start Time');

[pth,newFname] = fileparts(filename);
%%
newFname = [newFname,'.mat'];
% redFname = fullfile(pth,newFname,[newFname,'_red.h5']);
% %redFiltName = fullfile(pth,newFname,[newFname,'_redHPfilt.h5']);
% greenFname = fullfile(pth,newFname,[newFname,'_green.h5']);
% deetFname =  fullfile(pth,newFname,[newFname,'_deets.h5']);
% h5create(redFname ,'/redImg',movSize,'ChunkSize',[movSize(1:3),1],'Datatype','uint16');
% h5create(greenFname ,'/greenImg',movSize,'ChunkSize',[movSize(1:3),1],'Datatype','uint16');
% %h5create(redFiltName ,'/redFiltImg',movSize,'ChunkSize',[movSize(1:3),1],'Datatype','single');
Yg = zeros(res(2),res(1),max(zdepth),2,'uint16');
Yr = zeros(res(2),res(1),max(zdepth),2,'uint16');
t = image_times;
save(newFname,'Yg','Yr','t','-v7.3','-nocompression');
m = matfile(newFname,'Writable',true);
h=waitbar(0,'Transforming and saving...');

%redFiltImg = zeros(movSize([1,2,4]),'single');
for ii=1:length(image_times)
    [greenImg,redImg] = get_single_volume(filename,volumes,lasers,piezo,img_idx,res,max(zdepth),ii);
    m.Yg(:,:,:,ii) = greenImg;
    m.Yr(:,:,:,ii) = redImg;
    waitbar(ii/length(image_times),h);
%    filt1 = medfilt2(max(redImg,[],3));
%    redFiltImg(:,:,ii) = filt1-imgaussfilt(filt1,3);
%    h5write(redFname, '/redImg',redImg,[1,1,1,ii],[movSize(1:3),1]);
%    h5write(greenFname, '/greenImg',greenImg,[1,1,1,ii],[movSize(1:3),1]);
    %h5write(redFiltName, '/redFiltImg',redFiltImg,[1,1,1,ii],[movSize(1:3),1]);
%    fprintf('iter %d/%d\n',ii,length(image_times))
end

close(h)
% 
% h5create(deetFname,'/t',length(image_times));
% h5write(deetFname,'/t',image_times);
% h5writeatt(deetFname,'/','Start Time',start_time_str{1});