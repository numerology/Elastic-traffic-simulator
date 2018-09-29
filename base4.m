%% Single slice, what will be the difference if we scale the arrival rates.
clear;
capacities = [1;1;];
type_demands = [0.5 0;0 1;1 1]';
duration = 500;
relative_arrival_rates = 0.1 * [1 0.5 0;0 0.5 0.5];
shares = [0.5 0.5]';
verbose = 0;
workloads = 10 * [1,1,1]';
repetition = 1;
scale_vec = 0.60:0.05:0.80;
T = size(relative_arrival_rates, 2);
%%
disp('testing DRF weight alloca');
result_drf_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_drf = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] =  GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'drf', shares, ...
            scale * relative_arrival_rates, verbose);
        result_drf(scale_vec == scale, :) = type_delay;
    end
    result_drf_mat(i, :, :) = result_drf;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_drf = nanmean(result_drf_mat, 1);

%% 
disp('testing equal weight alloc');
result_equal_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_equal = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] = GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'equal', shares, ...
            scale * relative_arrival_rates, verbose);
        result_equal(scale_vec == scale, :) =  type_delay;
    end
    result_equal_mat(i, :, :) = result_equal;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_equal = nanmean(result_equal_mat, 1);

%%
% disp('testing nhops weight alloca');
% result_nhops_mat = zeros(repetition, size(scale_vec, 2), T);
% reverseStr = '';
% for i = 1:repetition
%     result_nhops = zeros(size(scale_vec, 2), T);
%     for scale = scale_vec
%         [type_delay, mean_delay] = GetDelayUnderDynamic(duration, capacities, ...
%             type_demands, workloads, 'nhops', shares, scale * relative_arrival_rates, verbose);
%         result_nhops(scale_vec == scale, :) = type_delay; 
%     end
%     result_nhops_mat(i, :, :) = result_nhops;
%     msg = sprintf('Number of iterations done: %d', i);
%     fprintf([reverseStr, msg]);
%     reverseStr = repmat(sprintf('\b'), 1, length(msg));
% end
% 
% result_nhops = nanmean(result_nhops_mat, 1);

%%
disp('testing nresources weight alloca');
result_nresources_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_nresources = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] = GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'nresources', shares, ...
            scale * relative_arrival_rates, verbose);
        result_nresources(scale_vec == scale, :) = type_delay;  
    end
    result_nresources_mat(i, :, :) = result_nresources;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_nresources = nanmean(result_nresources_mat, 1);
%% Plot
% plot the equal weight allocation
figure()
subplot(2,2,1)
hold on
title('Equal weight allocation')
plot(scale_vec, result_equal(:, :, 1), 'b+-');
plot(scale_vec, result_equal(:, :, 2), 'b^:');
plot(scale_vec, result_equal(:, :, 3), 'bo--');
%plot(scale_vec, result_equal(:, :, 4), 'bv-.');
legend('[0 0 1]', '[0 1 0]', '[1 0 1]', '[0.2 0.2 0.2]');

% subplot(2,2,2)
% hold on
% title('Nhops weight allocation')
% plot(scale_vec, result_nhops(:, :, 1), 'r+-');
% plot(scale_vec, result_nhops(:, :, 2), 'r^:');
% plot(scale_vec, result_nhops(:, :, 3), 'ro--');
% plot(scale_vec, result_nhops(:, :, 4), 'rv-.');
% legend('[0 0 1]', '[0 1 0]', '[1 0 1]', '[0.2 0.2 0.2]');

subplot(2,2,3)
hold on
title('Amount of resource weight allocation')
plot(scale_vec, result_nresources(:, :, 1), 'c+-');
plot(scale_vec, result_nresources(:, :, 2), 'c^:');
plot(scale_vec, result_nresources(:, :, 3), 'co--');
%plot(scale_vec, result_nresources(:, :, 4), 'cv-.');
legend('[0 0 1]', '[0 1 0]', '[1 0 1]', '[0.2 0.2 0.2]');

subplot(2,2,4)
hold on
title('DRF weight allocation')
plot(scale_vec, result_drf(:, :, 1), 'b+-');
plot(scale_vec, result_drf(:, :, 2), 'b^:');
plot(scale_vec, result_drf(:, :, 3), 'bo--');
%plot(scale_vec, result_drf(:, :, 4), 'bv-.');
legend('[0 0 1]', '[0 1 0]', '[1 0 1]', '[0.2 0.2 0.2]');

%% Plot average mean delay
figure()
hold on
title('Mean delay under different weighting')
plot(scale_vec, nanmean(result_equal, 3), 'b+-');
plot(scale_vec, nanmean(result_drf, 3), 'ko--');
%plot(scale_vec, nanmean(result_nhops, 3), 'rv-.');
plot(scale_vec, nanmean(result_nresources, 3), 'g^:');
legend('equal', 'DRF', 'Resource demand');
%% Plot normalized service rate
figure()
hold on 
title('Normalized service rate under different weighting')
plot(scale_vec, 10./nanmean(result_equal, 3), 'b+-');
plot(scale_vec, 10./nanmean(result_drf, 3), 'ko--');
%plot(scale_vec, nanmean(result_nhops, 3), 'rv-.');
plot(scale_vec, 10./nanmean(result_nresources, 3), 'g^:');
legend('equal', 'DRF', 'Resource demand');

