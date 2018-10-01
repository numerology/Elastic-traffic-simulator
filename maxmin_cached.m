function [ rate, lambda ] = maxmin_cached(user_types, weights, capacities, ...
    demands, cache)

% First need to filter out the zeroes in the input
non_zero_idx = find(weights);
filtered_weights = weights(non_zero_idx);
% Adjust the order according to the order of user_weights
[ordered_filtered_weights, weights_index] = sort(filtered_weights);
[tmp, sort_back] = sort(weights_index);
sorted_demands = demands(:, weights_index);

T = max(user_types);
num_user_types = zeros(1,T);
for t = user_types
    num_user_types(t) = num_user_types(t) + 1;
end

key_generated = key_gen(num_user_types);
if(cache.isKey(key_generated))
    ordered_filtered_rate = cache(key_generated);
    lambda = -1;
    %disp('cache hit');
else
    ordered_filtered_rate = maxmin_solve(ordered_filtered_weights, ...
        capacities, sorted_demands);
    
    assert(all(ordered_filtered_rate >= 0));
end
% change back to the original order
filtered_rate = ordered_filtered_rate(sort_back);
rate = zeros(size(weights))';
rate(non_zero_idx) = filtered_rate;

lambda = 1; % REDUNDANT, but want to mimic the behavior of fminimax for 
% compatibility.
end

