function [img_stack_filt]=medfilt3D(img_stack)
    img_stack_filt=zeros(size(img_stack));
    for ii=1:size(img_stack,4)
        for jj=1:size(img_stack,3)
            img_stack_filt(:,:,jj,ii)=medfilt2(img_stack(:,:,jj,ii));
        end
    end
end