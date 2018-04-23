function [img]=get_volume(fname,volume,lasers,piezo,img_idx,res,volumes,img)
    vol_mem=img(:,:,:,volume,:);
    if all(vol_mem(:)==0) %data not yet loaded
        [~,~,int_piezo]=unique(piezo);
        volumes_data=volumes(img_idx);
        frames=find(volumes==volume);
       
        offset=prod(res)*(frames-1)+1;
        start=[1,offset(1)];
        count=[1,prod(res)*length(frames)];
        
        data=(h5read(fname,'/img',start,count));

        unique_lasers=find(any(lasers,1));
        
        data=reshape(data,res(1),res(2),length(frames));
        
        for ii=1:length(unique_lasers)
            laser_id=find(lasers(frames,unique_lasers(ii)));    
            [~,idx]=sort(piezo(frames(laser_id)));
            img(:,:,int_piezo(laser_id(idx)),volume,ii)=data(:,:,laser_id(idx));            
        end
    end