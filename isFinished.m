function [ flag, remaining ] = isFinished( indices, queues )
%Determine whether there is still some elements to merge
%   Params:
%    indices: current ending indices for each queue
%    queues: cell of lists of arrival times for each v x t.
%   Returns:
%    flag: True if there is still some queues remaining unfinished
%    remaining: vector of indices of remaining queues

[V, T] = size(queues);
assert(size(indices,2) == V * T)

remaining = [];
flag = false;
for q = 1:(V * T)
    if (indices(q) <= size(queues{q}, 2))
        % still have elements
        remaining = [remaining, q];
        flag = true;
    end
end

end

