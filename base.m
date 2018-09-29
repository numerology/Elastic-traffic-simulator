% Base script to try out different settings.
clear;
capacities = [3, 1, 1, 2]';
type_demands = [1 2 0 0; 1 1 1 1]';
i_workloads = [5, 10]';
shares = [1]';
arrival_rates = [1 0.5];

duration = 100;
result_vec_nhops = zeros(1,10);
for i = 1:20
    result_vec_nhops(i) = GetDelayUnderDynamic(100, capacities, type_demands, ...
        i_workloads, 'nhops', shares, arrival_rates, 1);
end

result_vec_equal = zeros(1, 10);
for i = 1:20
    result_vec_equal(i) = GetDelayUnderDynamic(100, capacities, type_demands, ...
        i_workloads, 'equal', shares, arrival_rates, 1);
end

result_vec_nresources = zeros(1,10);
for i = 1:20
    result_vec_nresources(i) = GetDelayUnderDynamic(100, capacities, type_demands, ...
        i_workloads, 'nresources', shares, arrival_rates, 1);
end

mean(result_vec_equal)
mean(result_vec_nhops)
mean(result_vec_nresources)