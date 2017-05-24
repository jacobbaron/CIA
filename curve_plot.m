function leg=curve_plot(signal, image_times, odor_seq,varargin)

global neuron_list;
%global odor_list odor_concentration_list odor_colormap;
load odor_inf.mat

colorset = varycolor(length(signal));

%% input the neuron name
 if isempty(varargin)   
    neuron_list = cell(1,2);
    
    for i =1:length(signal)
        neuron_list{i}=input(['Please enter the name of neurons #', num2str(i), ':'],'s');
    end
 else
     neuron_list=varargin{1};
 end
 
 


%% plot curves
figure
for i =1:length(signal)
%     smooth_signal = smooth(signal{i},30);
%     plot(image_times, smooth_signal,'Color', colorset(i,:));
    plot(image_times, signal{i},'Color', colorset(i,:));
    hold on
end
hold off

axis tight
ax = axis;
axis([0 ax(2) ax(3) ax(4)])
% axis([0 ax(2) ax(3) ceil(ax(4))])
ax= axis;
set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',1.5);


%% calculate X Y and C for patch.
X(1,1) = image_times(1);
C = odor_seq(1);
j = 1; 

for i = 2:1: length(odor_seq)
    if odor_seq(i) ~= C(j)
        X(2,j) = image_times(i-1);
        j =j+1;
        C(j)  = odor_seq(i);    X(1,j) = image_times(i-1); 
    end
    if i == length(odor_seq)
        X(2,j) = image_times(i);
    end
end

X(3,:) = X(2,:);    X(4,:) = X(1,:);

Y = X;
Y(1, :) = ax(3);    Y(2, :) = ax(3);    Y(3, :) = ax(4);    Y(4, :) = ax(4);
     
%% XX YY and CC_color
cm = odor_colormap;     

CC = unique(odor_seq, 'stable');
XX = cell(1,length(CC));
YY = XX;

for i =1: length(CC)
    temp = find(C==CC(i));
    XX{i}= X(:,temp);
    YY{i}= Y(:,temp);
end

CC_color = zeros(length(CC) ,3);
for i =1:length(CC)
    if CC(i) == 0
        CC_color(i,:)=[1 1 1];
    else
        try
        CC_color(i,:) = cm(CC(i),:);
        catch
            1;
        end
    end    
end


%% patch
p = zeros(length(CC), 1);
for i =1:length(CC)
    p(i) = patch(XX{i}, YY{i}, CC_color(i,:), ...
        'FaceAlpha', 0.5);
end

%% label, legand and position
text_size = 10;
xlabel('Time(s)', 'FontSize',text_size);  ylabel('\delta F/F', 'FontSize',text_size);
% title([fname, '-', neuron_type],'FontSize',text_size);

% legend_text = cell(1, length(normalized_signal)+length(CC));
% for i = 1:length(normalized_signal)
%     legend_text(i) = neuron_list(i);
% end
% for j = 1:1:length(CC)
%     legend_text(j+i) = odor_seq_list(CC(j)+1);
% end

dim = size(signal);
legend_text = cell(1, dim(2)+length(CC));
for i = 1:dim(2)
    legend_text(i) = neuron_list(i);
end
for j = 1:1:length(CC)
    if CC(j)==0
        l_str = {'Water'};
    else
        ind_odor = floor(CC(j)/length(odor_concentration_list))+1;
        ind_conc = rem(CC(j), length(odor_concentration_list));
        if ind_conc ==0 % added Sep 24, fix bug when rem==0
            ind_conc = length(odor_concentration_list);
        end
        
        str_odor = odor_list{ind_odor};

        str_conc = odor_concentration_list{ind_conc};
        
        l_str = {[str_conc, ' ', str_odor]};
    end
    
    legend_text(j+dim(2)) = l_str;
end

leg=legend(legend_text, 'Location','NorthEastOutside', 'FontSize', text_size);

post = get(gcf, 'Position');
set(gcf, 'Position', [post(1), post(2), 960, 250])
xlim([image_times(1),image_times(end)])
% %% save figure
% saveas(gcf,[pathname, filename, '-', neuron_type,'.fig']);
end
