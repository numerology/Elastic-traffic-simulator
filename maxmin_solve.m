function [ rates ] = maxmin_solve( weights, capacities, demands)
%maxmin_solve: 
% solve a specific type of maxmin problem: max min_i r_i/w_i
% s.t. sum_i d(i, j) r_i <= c_j for each j

capacities = capacities';

N = size(weights, 2); % number of users.
R = size(capacities, 2); % number of resources.
assert(size(demands, 1) == R && size(demands, 2) == N);

rates = zeros(1, N);
remaining_cap = capacities;
bottlenecked = zeros(1,N); % none of the users are bottlenecked
bottlenecked_resource = zeros(1,R);

while(max(remaining_cap) > 1e-7 && min(bottlenecked) == 0 && min(bottlenecked_resource) == 0)
    active_remaining_cap = remaining_cap;
    active_remaining_cap(bottlenecked_resource > 0) = inf;
    weighted_demands = zeros(1, R);
    for i = 1:N
        if (bottlenecked(i) > 0)
            continue;
        end
        for r = 1:R
            weighted_demands(r) = weighted_demands(r) + weights(i) * demands(r, i);
        end
    end
    [increment, minidx] = min(active_remaining_cap./weighted_demands);
    if(increment == inf) % to deal with the case demand orthogonal to remaining capacity
        break
    end
    bottlenecked_resource(minidx) = 1;
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
        if(remaining_cap == 0)
            continue;
        end
        remaining_cap(r) = remaining_cap(r) - weighted_demands(r) * increment;
        if(abs(remaining_cap(r)) < 1e-10)
            bottlenecked_resource(r) = 1; % needed if two resources get BNed at the same time.
        end
    end      
end

end

