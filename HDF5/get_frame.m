function [img]=get_frame(fname,volume,z,lasers,z_idx,img_idx,res,volumes,img)
    vol_mem=img(:,:,z,volume,:);
    if all(vol_mem(:)==0) %data not yet loaded
        %[~,~,int_z_idx]=unique(z_idx);
        volumes_data=volumes(img_idx);
        frames=find(volumes==volume & z_idx==z);
       unique_lasers=find(any(lasers,1));
        offset=prod(res)*(frames(1)-1)+1;
        start=[1,offset];
        count=[1,prod(res)*length(unique_lasers)];
        
        data=(h5read(fname,'/img',start,count));

        unique_lasers=find(any(lasers,1));
        
        data3d=reshape(data,res(1),res(2),length(frames));
        
        for ii=1:length(unique_lasers)
            laser_id=find(lasers(frames,unique_lasers(ii)));    
            [~,idx]=sort(z_idx(frames(laser_id)));
            img(:,:,z,volume,ii)=data3d(:,:,laser_id(idx));       
        end
    end