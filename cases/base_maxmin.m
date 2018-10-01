% Script to study mean delay under different
% weighting schemes.
clear;
capacities = [1;1];
type_demands = [.1 1;1 .1;1 1]';
duration = 300;
relative_arrival_rates = 0.1 * [4 1 1];
shares = [1]';
verbose = 0;
workloads = 10 * [1,1,1]';
repetition = 50;
scale_vec = 0.2:0.05:0.5;
T = size(relative_arrival_rates, 2);
%%
disp('testing inverse weight square alloca');
result_inverse_square_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_inverse_square = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] =  GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'inverseresc-square', shares, ...
            scale * relative_arrival_rates, verbose);
        result_inverse_square(scale_vec == scale, :) = type_delay;
    end
    result_inverse_square_mat(i, :, :) = result_inverse_square;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_inverse_square = nanmean(result_inverse_square_mat, 1);
%%
disp('testing inverse weight sqrt alloca');
result_inver_sqrt_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_inverse_sqrt = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] =  GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'inverseresc-sqrt', shares, ...
            scale * relative_arrival_rates, verbose);
        result_inverse_sqrt(scale_vec == scale, :) = type_delay;
    end
    result_inver_sqrt_mat(i, :, :) = result_inverse_sqrt;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_inverse_sqrt = nanmean(result_inver_sqrt_mat, 1);

%%
disp('testing equal weight alloc - PF');
result_equalpf_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_equalpf = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] = GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'equal', shares, ...
            scale * relative_arrival_rates, verbose);
        result_equalpf(scale_vec == scale, :) =  type_delay;
    end
    result_equalpf_mat(i, :, :) = result_equalpf;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_equalpf = nanmean(result_equalpf_mat, 1);
%%
disp('testing inverse resource weight alloc - PF');
result_inversepf_mat = zeros(repetition, size(scale_vec, 2), T);
reverseStr = '';
for i = 1:repetition
    result_inversepf = zeros(size(scale_vec, 2), T);
    for scale = scale_vec
        [type_delay, mean_delay] = GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'inverseresources', shares, ...
            scale * relative_arrival_rates, verbose);
        result_inversepf(scale_vec == scale, :) =  type_delay;
    end
    result_inversepf_mat(i, :, :) = result_inversepf;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_inversepf = nanmean(result_inversepf_mat, 1);

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
%% Plot average mean delay
figure()
hold on
title('Mean delay under different weighting')
plot(scale_vec, nanmean(result_inversepf, 3), 'b+-');
plot(scale_vec, nanmean(result_inverse_square, 3), 'ko--');
plot(scale_vec, nanmean(result_inverse_sqrt, 3), 'cd--');
plot(scale_vec, nanmean(result_equalpf, 3), 'rv-.');
plot(scale_vec, nanmean(result_nresources, 3), 'g^:');
legend('inverse resource - pf', 'inverse resource square - pf', 'inverse resource sqrt - pf' , 'equal-pf', 'Resource demand - pf');
%% Plot normalized service rate
figure()
hold on 
title('Normalized service rate under different weighting')
plot(scale_vec, 10./nanmean(result_inversepf, 3), 'b+-');
plot(scale_vec, 10./nanmean(result_inverse_square, 3), 'ko--');
plot(scale_vec, 10./nanmean(result_inverse_sqrt, 3), 'cd--');
plot(scale_vec, 10./nanmean(result_equalpf, 3), 'rv-.');
plot(scale_vec, 10./nanmean(result_nresources, 3), 'g^:');
legend('inverse resource - pf', 'inverse resource square - pf', 'inverse resource sqrt - pf' , 'equal-pf', 'Resource demand - pf');
