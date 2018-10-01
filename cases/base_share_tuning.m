% Script to test the behavior of resource allocation under
% SCPF weighting scheme and weighted maxmin
% when share allocation among slices is tuned.
addpath('../');
clear;
capacities = ones(6,1);
type_demands = [1 0 0.5 0 0 0; 
                0 1 0.5 0 0 0; 
                0 0 0.5 0 0 0.5; 
                0 0 0 1 0 0.5;
                0 0 0 0 1 0.5;
                0 0 0.5 0 0 0.5]';
duration = 20;
relative_arrival_rates = [1 1 0.7 0 0 0; 
                          0 0 0 1 1 0.7];
%shares = [0.4 0.4 0.2]';
verbose = 0;
workloads = 1 * [1,1,1,1,1,1]';
repetition = 100;
share_vec = [0.01 0.1 0.5 0.9 0.99];
T = size(relative_arrival_rates, 2);
V = 2;
parpool;
ppm = ParforProgMon('Progress 1:', repetition);

% To prevent cofounding issue, need to separate the iteration for slice 1
% and 2
%% 
disp('testing equal weight alloc');
result_equal_mat = zeros(repetition, size(share_vec, 2), V);
delay_samples_1 = cell(repetition, V);
delay_samples_2 = cell(repetition, V);
parfor i = 1:repetition
    result_equal = zeros(size(share_vec, 2), V);
    for share_1 = share_vec
        [slice_delay, mean_delay, slice_delay_samples] = GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'equal', [share_1, 1 - share_1]', ...
            0.4 * relative_arrival_rates, verbose);
        result_equal(share_vec == share_1, :) =  slice_delay;
        if (share_1 == 0.01)
            delay_samples_1{i, 1} = slice_delay_samples{1};
        end
        if (share_1 == 0.99)
            delay_samples_2{i, 1} = slice_delay_samples{1};
        end
    end
    ppm.increment();
    result_equal_mat(i, :, 1) = result_equal(:, 2);
end



ppm2 = ParforProgMon('Progress 2:', repetition);
parfor i = 1:repetition
    result_equal = zeros(size(share_vec, 2), V);
    for share_1 = share_vec
        [slice_delay, mean_delay, slice_delay_samples] = GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'equal', [share_1, 1 - share_1]', ...
            0.4 * relative_arrival_rates, verbose);
        result_equal(share_vec == share_1, :) =  slice_delay;
        if (share_1 == 0.01)
            delay_samples_1{i, 2} = slice_delay_samples{2};
        end
        if (share_1 == 0.09)
            delay_samples_2{i, 2} = slice_delay_samples{2};
        end
    end
    ppm2.increment();
    result_equal_mat(i, :, 2) = result_equal(:, 2);
end

result_equal = nanmean(result_equal_mat, 1);

%% Plot normalized service rate
figure()
hold on 
title('Normalized service rate under different shares')
plot(1./result_equal(:,:,1), 1./result_equal(:,:,2), 'b+-');
%%
for share = [0.01 0.09]
    delay_vec_1 = [];
    for i = 1:repetition
        if (share == 0.01)
            delay_vec_1 = [delay_vec_1 delay_samples_1{i, 1}];
        end
        if (share == 0.09)
            delay_vec_1 = [delay_vec_1 delay_samples_2{i, 1}];
        end
    end

    delay_vec_2 = [];
    for i = 1:repetition
        if (share == 0.01)
            delay_vec_2 = [delay_vec_2 delay_samples_1{i, 2}];
        end
        if (share == 0.09)
            delay_vec_2 = [delay_vec_2 delay_samples_2{i, 2}];
        end
    end
    
    disp(strcat('Under share 1 = ', num2str(share)))
    mean_log_delay_1 = mean(log(delay_vec_1))
    mean_log_delay_2 = mean(log(delay_vec_2))
    
    figure()
    histogram(log(delay_vec_1),30);
    hold on
    histogram(log(delay_vec_2),30);
    title(strcat('Histogram of log delay for each slice under share_1 = ', num2str(share)));
    legend('slice 1', 'slice 2')
end
delete(gcp('nocreate'))
