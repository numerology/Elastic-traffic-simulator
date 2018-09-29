function [ rate ] = pf_cached_gpu( weights, capacities, demands, init_guess, cache )
% Compute the rate allocation according to the weighted proportional
% fairness criterion

weights = weights';

% ---------------
% SUB FUNCTION
% ---------------
% Define the objective function of weighted pf:
% weighted sum of log rate across all users
% params:
% rate: n_user x 1 sized
% weight: n_user x 1 sized
% return: f - evaluated obj function, g - gradient.
function [f, g, h] = weighted_log_rates(rate, weight)
    assert(size(rate, 1) == size(weight, 1));
    gWeight = gpuArray(weight);
    gRate = gpuArray(rate);
    gf = - sum(gWeight .* log(complex(gRate)));
    gg = - gWeight./gRate;
    gh = diag(-gWeight./(gRate .* gRate));
    f = gather(real(gf));
    g = gather(gg);
    h = gather(gh);
end

function h = weighted_log_rates_hessian(rate, weight, lambda)
    % We do not have nonlinear constraint here.
    gWeight = gpuArray(weight);
    gRate = gpuArray(rate);
    gh = diag(gWeight./(gRate .* gRate));
    h = gather(gh);
end

% First need to filter out the zeroes in the input
non_zero_idx = find(weights);
filtered_init_guess = init_guess(non_zero_idx);
filtered_weights = weights(non_zero_idx);
% Adjust the order according to the order of user_weights
[ordered_filtered_weights, weights_index] = sort(filtered_weights);
[tmp, sort_back] = sort(weights_index);
filtered_demands = demands(:, non_zero_idx);

key_generated = key_gen(ordered_filtered_weights');
if(cache.isKey(key_generated))
    unordered_filtered_rate = cache(key_generated);
else
    fh = @(x) (weighted_log_rates(x, ordered_filtered_weights));
    hh = @(x, lambda) (weighted_log_rates_hessian(x, ordered_filtered_weights, lambda));
    options = optimoptions('fmincon','Display','off', 'SpecifyObjectiveGradient', ... 
        true, 'Algorithm', 'interior-point','Hessian', 'user-supplied', 'HessianFcn', ...
        hh, 'MaxIterations', 15, 'OptimalityTolerance', 1e-2, 'UseParallel', true, ...
        'SpecifyConstraintGradient', true, 'MaxFunctionEvaluations', 100, 'StepTolerance', ...
        1e-3, 'HonorBounds', false);
        
    [unordered_filtered_rate, fval, exitflag, output] = fmincon(fh, filtered_init_guess, ...
    filtered_demands(:, weights_index), capacities,[],[],[],[], [], options);
    cnt = 0;
    while(~all(unordered_filtered_rate >= 0))
        filtered_init_guess = 0.8 * filtered_init_guess;
        [unordered_filtered_rate, fval, exitflag, output] = fmincon(fh, filtered_init_guess, ...
            filtered_demands(:, weights_index), capacities,[],[],[],[], [], options);
        cnt = cnt + 1;
        if(cnt > 10)
            disp('warning: PF solver get trapped in nonpositive solution.')
            filtered_demands(:, weights_index)
            ordered_filtered_weights;
        end
    end

    % also, add cache
    cache(key_generated) = unordered_filtered_rate;
    
    
end

filtered_rate = unordered_filtered_rate(sort_back);
rate = zeros(size(init_guess));
rate(non_zero_idx) = filtered_rate;

% change back to the original order

end

