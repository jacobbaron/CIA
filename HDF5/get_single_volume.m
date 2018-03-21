function [greenImg,redImg]=get_single_volume(fname,volumes,lasers,piezo,img_idx,res,d3,volume)
%output index: (i,j,k), green is c=1, red is c=2   

%vol_mem=img(:,:,:,volume,:);
    %if all(vol_mem(:)==0) %data not yet loaded
        [~,~,int_piezo]=unique(piezo);
        %volumes_data=volumes(img_idx);
        
        frames=find(volumes==volume);
       
        offset=prod(res)*(frames-1)+1;
        start=[1,offset(1)];
        count=[1,prod(res)*length(frames)];
        
        data=(h5read(fname,'/img',start,count));

        unique_lasers=find(any(lasers,1));
        
        data3d=reshape(data,res(1),res(2),length(frames));       
        redImg = zeros(res(1),res(2),d3,'uint16');
        greenImg = zeros(res(1),res(2),d3,'uint16');
        for ii=1:length(unique_lasers)
            laser_id=find(lasers(frames,unique_lasers(ii)));
            [~,idx]=sort(piezo(frames(laser_id)));
            if ii==1
                greenImg(:,:,int_piezo(laser_id(idx)))=...
                    flip(flip(permute(data3d(:,:,laser_id(idx)),[2,1,3]),1),3);
            else
                redImg(:,:,int_piezo(laser_id(idx)))=...
                    flip(flip(permute(data3d(:,:,laser_id(idx)),[2,1,3]),1),3);
            end
        end
        
        
   % end