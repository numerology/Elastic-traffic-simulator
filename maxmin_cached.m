function [ rate, lambda ] = maxmin_cached(user_active, user_types, weights, capacities, demands, init_guess, cache)

% TODO: deprecate the usage of init_guess

% First need to filter out the zeroes in the input
non_zero_idx = find(weights);
filtered_init_guess = init_guess(non_zero_idx);
filtered_weights = weights(non_zero_idx);
% Adjust the order according to the order of user_weights
[ordered_filtered_weights, weights_index] = sort(filtered_weights);
[tmp, sort_back] = sort(weights_index);
filtered_demands = demands(:, non_zero_idx);

T = max(user_types);
num_user_types = zeros(1,T);
for t = user_types
    num_user_types(t) = num_user_types(t) + 1;
end

key_generated = key_gen(num_user_types);
if(cache.isKey(key_generated))
%if (false)
    unordered_filtered_rate = cache(key_generated);
    lambda = -1;
    %disp('cache hit');
else
    unordered_filtered_rate = maxmin_solve(filtered_weights, capacities, filtered_demands);
    
    assert(all(unordered_filtered_rate >= 0));
%     while(~all(unordered_filtered_rate >= 0))
%         filtered_init_guess =  0.8 * filtered_init_guess;
%         [unordered_filtered_rate, fval, maxfval, exitflag, output, lambda] = fminimax(@(x) ... 
%             neg_weighted_rates(x, ordered_filtered_weights), filtered_init_guess, ...
%             filtered_demands(:, weights_index), capacities,[],[],[],[], [], options);
%         cnt = cnt + 1;
%         if(cnt > 100)
%             disp('warning: maxmin solver get trapped in nonpositive solution.')
%             filtered_demands(:, weights_index)
%             ordered_filtered_weights
%         end
%     end

    % also, add cache
    %cache(key_generated) = unordered_filtered_rate;
end

filtered_rate = unordered_filtered_rate(sort_back);
rate = zeros(size(init_guess));
rate(non_zero_idx) = filtered_rate;

lambda = 1; % REDUNDANT
% change back to the original order

end

