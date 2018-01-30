function imgSize = get_h5_mov_size(fname)
[~,volumes,lasers,~,~,res,...
    ~]=LoadImgProperties(fname);

%unique_lasers=find(any(lasers,1));
 %   num_lasers=length(find(any(lasers,1)));    
    
    for ii=1:size(lasers,2)
        zdepth(ii)=length(find(lasers(volumes==1,ii)));
    end
     imgSize = [res(1),res(2),max(zdepth),length(unique(volumes(volumes>0)))];
    
    
    