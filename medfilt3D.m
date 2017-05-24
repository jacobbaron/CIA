function [img_stack_filt]=medfilt3D(img_stack,n,m)
    if nargin==1
        n=3;
        m=3;
    end
    img_stack_filt=zeros(size(img_stack));
    kk=0;
    h=waitbar(0,'Median Filtering');
    for ii=1:size(img_stack,4)
        for jj=1:size(img_stack,3)
            
            
            img_stack_filt(:,:,jj,ii)=medfilt2(img_stack(:,:,jj,ii),[n,m]);
            kk=kk+1;
            waitbar(kk/(size(img_stack,4)*size(img_stack,3)),h);
        end
    end
    close(h);
end