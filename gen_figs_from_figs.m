function gen_figs_from_figs(figlist)
    bigfig=figure;
    for ii=1:length(figlist)
        h(ii)=openfig(strcat(figlist{ii},'.fig'),'reuse');
        ax(ii)=gca;
        s(ii)=subplot(ceil(length(figlist)/2),2,ii);
        fig(ii)=get(ax(ii),'children')
        copyobj(fig(ii),s(ii))
    end

    
end