function [ event_lists, user_demands, user_types, user_slices ]...
    = fake_initialization( arrival_rates, duration, workloads, type_demands )
% Mock of initialization method used for testing, no randomness is
% involved.

[V, T] = size(arrival_rates);
B = size(type_demands, 1);

arrival_time = cell(V, T);
disp('Generating fake arrival times')
for v = 1:V
    for t = 1:T
        ctt = 0;
        arrival_time_vt = [];
        if (arrival_rates(v, t) == 0)
            continue % Otherwise get stuck
        end
        while(ctt <= duration)
            ctt = ctt + 1/arrival_rates(v, t);   
            if(ctt <= duration)
                arrival_time_vt = [arrival_time_vt, ctt];
            end

        end
        arrival_time{v,t} = arrival_time_vt;
    end
end
disp('Finish generating fake arrival times')

event_lists = {};
idxs = ones(1, V * T);

[flag, remaining_idx] = isFinished(idxs, arrival_time);
id_cnt = 1;

disp('Merging arrival times')
while(flag)
    % merge the earlist events in the remaining queues into result
    minimalt = duration + 1;
    v = -1;
    t = -1;
    minidx = -1;
    for idx = remaining_idx
        if(arrival_time{idx}(idxs(idx)) < minimalt)
            minimalt = arrival_time{idx}(idxs(idx));
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
    event.workload = workloads(t);
    event_lists{end + 1} = event;  
    
    idxs(minidx) = idxs(minidx) + 1;
    id_cnt = id_cnt + 1;
    
    [flag, remaining_idx] = isFinished(idxs, arrival_time);
end
disp('Finish merging arrival times')

nUsers = size(event_lists, 2);
% Need to establish the big user_demands matrix, of B x U
user_demands = zeros(B, nUsers);
user_types = zeros(1, nUsers);
user_slices = zeros(1, nUsers);
for u = 1:nUsers
    user_demands(:, u) = type_demands(:, event_lists{u}.type);
    user_types(u) = event_lists{u}.type;
    user_slices(u) = event_lists{u}.slice;
end

end

