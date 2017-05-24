function [img,time]=get_all_volumes(fname,lasers,piezo,img_idx,res,volumes,t,img)
    
        use_frames=volumes~=0;
        [~,~,int_piezo]=unique(piezo);
        volumes_data=volumes(img_idx);
        %frames=find(volumes==volume);
       
        %offset=prod(res)*(frames-1)+1;
        %start=[1,offset(1)];
        %count=[1,prod(res)*length(];
        
        data=h5read(fname,'/img');

        unique_lasers=find(any(lasers,1));
        
        data3d=reshape(data,res(1),res(2),length(img_idx));
        
        which_lasers=zeros(size(lasers,1),1);
        for ii=1:length(lasers)
            tmp=find(lasers(ii,:));
            if ~isempty(tmp)
                which_lasers(ii)=find(lasers(ii,:));
            end
        end
        
        [~,~,which_laser_idx]=unique(which_lasers(use_frames));
        data3d_use=data3d(:,:,use_frames);
        int_piezo_use=int_piezo(use_frames);
        volumes_use=volumes(use_frames);
        for ii=1:length(which_laser_idx)
            img(:,:,int_piezo_use(ii),volumes_use(ii),which_laser_idx(ii))=...
                data3d_use(:,:,ii);
        end
        unique_volumes=unique(volumes(volumes>0));
        for ii=1:length(unique_volumes)
           time(ii)=mean(t(volumes==unique_volumes(ii)));
            
        end
    