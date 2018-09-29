% Single slice, what will be the difference if we scale the arrival rates.
clear;
capacities = [1;1];
type_demands = [0 1; 1 0; 0.1 0.1]';
duration = 1000;
relative_arrival_rates = 0.1 * [4, 1, 1];
shares = [1];
verbose = 0;
workloads = 10 * [1,1,1]';
repetition = 1000;
scale_vec = 0.20:0.01:0.30;

disp('testing equal weight alloc');
result_equal_mat = zeros(repetition, size(scale_vec, 2));
reverseStr = '';
for i = 1:repetition
    result_equal = [];
    for scale = scale_vec
        result_equal(end + 1) =  GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'equal', shares, ...
            scale * relative_arrival_rates, verbose);
    end
    result_equal_mat(i, :) = result_equal;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_equal = nanmean(result_equal_mat, 1);

% disp('testing nhops weight alloca');
% result_nhops_mat = zeros(repetition, size(scale_vec, 2));
% reverseStr = '';
% for i = 1:repetition
%     result_nhops = [];
%     for scale = scale_vec
%         result_nhops(end + 1) =  GetDelayUnderDynamic(duration, capacities, ...
%             type_demands, workloads, 'nhops', shares, scale * relative_arrival_rates, verbose);
%     end
%     result_nhops_mat(i, :) = result_nhops;
%     msg = sprintf('Number of iterations done: %d', i);
%     fprintf([reverseStr, msg]);
%     reverseStr = repmat(sprintf('\b'), 1, length(msg));
% end

% result_nhops = mean(result_nhops_mat, 1);

disp('testing nresources weight alloca');
result_nresources_mat = zeros(repetition, size(scale_vec, 2));
reverseStr = '';
for i = 1:repetition
    result_nresources = [];
    for scale = scale_vec
        result_nresources(end + 1) =  GetDelayUnderDynamic(duration, capacities, ...
            type_demands, workloads, 'nresources', shares, ...
            scale * relative_arrival_rates, verbose);
    end
    result_nresources_mat(i, :) = result_nresources;
    msg = sprintf('Number of iterations done: %d', i);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

result_nresources = nanmean(result_nresources_mat, 1);