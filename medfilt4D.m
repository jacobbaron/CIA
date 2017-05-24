function [img_stack,h]=medfilt4D(img_stack,n,m,h,idx,maxiter,txt)
    if nargin==1 
        n=3;
        m=3;
    elseif isempty(n) && isempty (m)
        n=3;
        m=3;
        
    end
    if ~exist('h','var')
        h=waitbar(0,'Median filtering...');
        idx=1;
        maxiter=1;
        txt='';
        single=1;
    elseif isempty(h)
        h=waitbar(0,'Median filtering...');
        
        txt='';
        single=1;
    else
        single=0;
    end
    
    
    %img_stack_filt=img_stack;
    kk=0;
    for ii=1:size(img_stack,4)
        for jj=1:size(img_stack,3)
            
            img_stack(:,:,jj,ii)=medfilt2(img_stack(:,:,jj,ii),[n,m]);
            kk=kk+1;
            waitbar((idx-1)/maxiter+kk/(maxiter*size(img_stack,4)*size(img_stack,3)),...
                h,sprintf('Median filtering %s image, iteration %0.0f of %0.0f.',txt,idx,maxiter));
        end
    end
    if single==1
        close(h);
    end      
end