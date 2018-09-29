function [ rate, lambda ] = maxmin( weights, capacities, demands, init_guess )
% find the maxmin rate allocatin, given the following parameters.
% Basically, this is a wrapper of fminmax function
%   Params:
%    weights: vector (U), weight of each user
%    capacities: vector (B), capacity of each resource
%    demands: matrix (B * U), demand of each from each resource per unit
%    rate
%   Out:
%    rate: vector (U)
weights = weights';
% ---------------
% SUB FUNCTION
% ---------------

    function f = neg_weighted_rates(rate, weight)
        assert(size(rate,1) == size(weight,1))
        f = -rate./weight;
    end

% First need to filter out the zeroes in the input
non_zero_idx = find(weights);
filtered_init_guess = init_guess(non_zero_idx);
filtered_weights = weights(non_zero_idx);
filtered_demands = demands(:, non_zero_idx);

options = optimoptions('fminimax','Display','off');
% iterating from above can guarantee use up the capacities
% init_guess = 10 * max(capacities) * ones(size(weights));
[filtered_rate, fval, maxfval, exitflag, output, lambda] = fminimax(@(x) ... 
    neg_weighted_rates(x, filtered_weights), filtered_init_guess, ...
    filtered_demands, capacities,[],[],[],[], [], options);

%Then need to add zeros properly
rate = zeros(size(init_guess));
rate(non_zero_idx) = filtered_rate;

end

