function [ eventLists, userDemands, userTypes, userSlices ] = ...
    initialization( arrivalRates, duration, workloads, typeDemands, verbose)
%Generate the intial event queue
%   Detailed explanation goes here
[V, T] = size(arrivalRates);
B = size(typeDemands, 1);
% for each type x slice, generate the series of arrival times
arrivalTime = cell(V, T);
if(verbose > 0)
    fprintf('\n');
    disp('Generating arrival times')
end
for v = 1:V
    for t = 1:T
        ctt = 0;
        arrivalTimeVt = [];
        if (arrivalRates(v, t) == 0)
            continue % Otherwise get stuck
        end
        while(ctt <= duration)
            ctt = ctt + exprnd(1/arrivalRates(v, t));   
            if(ctt <= duration)
                arrivalTimeVt = [arrivalTimeVt, ctt];
            end

        end
        arrivalTime{v,t} = arrivalTimeVt;
    end
end
if(verbose > 0)
    disp('Finish generating arrival times')
end
% merge lists to form an event queue
eventLists = {};
% indices for current arrival time for each v x t.
idxs = ones(1, V*T);

[flag, remainingIdx] = isFinished(idxs, arrivalTime);
id_cnt = 1;

if(verbose > 0)
    disp('Merging arrival times')
end
while(flag)
    % merge the earlist events in the remaining queues into result
    minimalt = duration + 1;
    v = -1;
    t = -1;
    minidx = -1;
    for idx = remainingIdx
        if(arrivalTime{idx}(idxs(idx)) < minimalt)
            minimalt = arrivalTime{idx}(idxs(idx));
            v = mod(idx - 1, V) + 1;
            t = floor((idx - 1)/V) + 1;
            minidx = idx;
        end
    end
    
    event.time = minimalt;
    event.type = t;
    event.slice = v;
    event.tag = 'arrival';
    event.userID = id_cnt;
    event.workload = exprnd(workloads(t));
    eventLists{end + 1} = event;  
    
    idxs(minidx) = idxs(minidx) + 1;
    id_cnt = id_cnt + 1;
    
    [flag, remainingIdx] = isFinished(idxs, arrivalTime);
end
if(verbose > 0)
    disp('Finish merging arrival times')
end

nUsers = size(eventLists, 2);
% Need to establish the big user_demands matrix, of B x U
userDemands = zeros(B, nUsers);
userTypes = zeros(1, nUsers);
userSlices = zeros(1, nUsers);
for u = 1:nUsers
    userDemands(:, u) = typeDemands(:, eventLists{u}.type);
    userTypes(u) = eventLists{u}.type;
    userSlices(u) = eventLists{u}.slice;
end

end

