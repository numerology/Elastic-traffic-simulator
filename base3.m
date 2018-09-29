% Single slice, what will be the difference if we scale the arrival rates.
capacities = [1;1];
type_demands = [.1 1; 1 .1; 1 1]';
duration = 1000;
relative_arrival_rates = 0.1 * [4, 1, 1];
shares = [1];
verbose = 0;
workloads = 10 * [1,1,1]';
repetition = 20;
scale_vec = 0.30:0.01:0.35;

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