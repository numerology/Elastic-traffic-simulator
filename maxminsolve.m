function [ rates ] = maxminsolve( weights, capacities, demands)
% Solve the maxmin rate allocation problem under the resource constraint.
% 
% max  min_i r_i/w_i
% s.t. sum_i d(i, j) r_i <= c_j for each j
%
% Assuming everyone has nonzero weights and demands.
% --------------------------------
% Parameters:
% --------------------------------
% - weights: array of user weights, nUsers x 1 matrix
% - capacities: array of resources capacities, 1 x R matrix
% - demands: resource demands per user, R x nUsers matrix
% --------------------------------
% Ret:
% --------------------------------
% - rate: rate allocation to each user, 1 x nUsers matrix

capacities = capacities';

N = size(weights, 2); % number of users.
R = size(capacities, 2); % number of resources.
assert(size(demands, 1) == R && size(demands, 2) == N);

rates = zeros(1, N);
remainingCap = capacities;
bottlenecked = zeros(1,N); % none of the users are bottlenecked
bottleneckedResource = zeros(1,R);

while(max(remainingCap) > 1e-7 && min(bottlenecked) == 0 && ...
        min(bottleneckedResource) == 0)
    activeRemainingCap = remainingCap;
    activeRemainingCap(bottleneckedResource > 0) = inf;
    weightedDemands = zeros(1, R);
    for i = 1:N
        if (bottlenecked(i) > 0)
            continue;
        end
        for r = 1:R
            weightedDemands(r) = weightedDemands(r) + weights(i) ...
                * demands(r, i);
        end
    end
    [increment, minidx] = min(activeRemainingCap ./ weightedDemands);
    if(increment == inf) % to deal with the case demand orthogonal to remaining capacity
        break
    end
    bottleneckedResource(minidx) = 1;
    for i = 1:N
        if(bottlenecked(i) > 0)
            continue;
        end
        rates(i) = rates(i) + increment * weights(i);
        % all the users have demand in minidx are bned
        if(demands(minidx, i) > 0)
            bottlenecked(i) = 1;
        end
    end
    
    for r = 1:R
        if(remainingCap == 0)
            continue;
        end
        remainingCap(r) = remainingCap(r) - weightedDemands(r) * increment;
        if(abs(remainingCap(r)) < 1e-10)
            bottleneckedResource(r) = 1; 
            % needed if two resources get BNed at the same time.
        end
    end      
end

end

