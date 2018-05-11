function normalized_signal = nm_signal( signal, odor_seq,t)

%normalized_signal = signal;

%f0_left  = -10;
%f0_right = -2;
tfirst = odor_seq.time_first_odor;
index = find(t > tfirst,1);

% left  = max(1, index+f0_left);
% right = max(1, index+f0_right);
f0 = cellfun(@(x)mean(x(1:index)),signal,'UniformOutput',false);
normalized_signal = cellfun(@(f,f0) (f-f0)/f0, signal, f0,'UniformOutput',false);

% for k =1:length(signal)
%     f0 = mean(signal{k}(left : right));
%     normalized_signal{k} = (signal{k}-f0)/f0;
% end

end
