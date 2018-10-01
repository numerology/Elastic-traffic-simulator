function [new_event_list, new_user_rates, new_user_workloads, ...
    new_user_active, new_user_timing, new_slice_users, current_time] = eventUpdate( event_list, user_rates, user_workloads,...
    user_active, weight_strata, user_timing, slice_users, shares, capacities, ...
    user_demands, last_time, user_types, user_slices, cache)
%Update the configuration according to the first/earliest event in the
%event queue
%   Params are self-explanary
V = size(slice_users, 2);
B = size(capacities, 1);
nUsers = size(user_rates, 2);

cEvent = event_list{1}; % fetch the first event
new_user_timing = user_timing;

if (strcmp(cEvent.tag, 'invalid'))
    % If the event has been revoked. Then return all parameters as they are
    new_user_rates = user_rates;
    new_user_workloads = user_workloads;
    new_user_timing = user_timing;
    new_slice_users = slice_users;
    current_time = last_time;
end
if (strcmp(cEvent.tag, 'arrival'))
    % When a new customer arrives, add it to the active users set, and
    % reallocate the user rates. Also reestimate the departure time for
    % users if needed, and replace the departure event in the queue if
    % needed.
    cID = cEvent.userID;
    cTime = cEvent.time;
    cType = cEvent.type;
    cSlice = cEvent.slice;
    cWL = cEvent.workload;
    assert(user_active(cID) == 0);
    user_active(cID) = 1;
    new_user_timing(1, cID) = cTime;
    current_time = cTime;
    slice_users{cSlice}(end + 1) = cID;
    % adjust weight allocation among users

    
    user_weights =  get_weight_allocation(user_active, user_demands, shares, weight_strata, capacities, slice_users);
    % revoke all the departure event associated with current active
    % users
    % Inorder to update the remaining workload, use the previous user_rates
    % and the difference b/w last_time and cTime
    eid = 1;
    while(eid <= size(event_list, 2))
        if(strcmp(event_list{eid}.tag, 'departure') && user_active(event_list{eid}.userID) == 1)
            % remove event_list{eid}
            event_list = {event_list{1:(eid - 1)}, event_list{(eid + 1):end}};
        else
            eid = eid + 1;
        end
    end 
    
    % According to the logic there should be no negative workloads
    new_user_workloads = user_workloads - user_active .* user_rates * (cTime - last_time);
    
    % The initial guess is such that, all inactive users are set to 0 and
    % all active users get something definitely surpasses the capacity.
    init_guess = 10 * max(capacities) * ones(nUsers, 1);
    init_guess = init_guess .* user_active';
    [cRate, lambda] = maxmin_cached(user_types, user_weights, capacities, user_demands, cache);
    %update rate allocation
    new_user_rates = cRate';
    assert(all(cRate >= 0));
    assert(all(cRate < inf));
    
    % Update/insert new departure events
    for cuser = 1:nUsers
        if(user_active(cuser) == 1)
            % Predict when it will be departing
            estimate_departure_time = new_user_workloads(cuser) / ...
                new_user_rates(cuser) + cTime;
            assert(estimate_departure_time > 0)
            % Looking forward to seek for a place to insert
            inserted = false;
            for eid = 1:size(event_list, 2)
                if (event_list{eid}.time > estimate_departure_time)
                    event.time = estimate_departure_time;
                    event.type = user_types(cuser);
                    event.slice = user_slices(cuser);
                    event.tag = 'departure';
                    event.userID = cuser;
                    event.workload = 0;
                    event_list = {event_list{1:(eid - 1)}, event, event_list{eid:end}};
                    inserted = true;
                    break;
                end
            end
            if(~inserted)
                % append to the end of the list
                event.time = estimate_departure_time;
                event.type = user_types(cuser);
                event.slice = user_slices(cuser);
                event.tag = 'departure';
                event.userID = cuser;
                event.workload = 0;
                event_list{end + 1} = event;
            end
        end
    end
    
    current_time = cTime;
    new_slice_users = slice_users;
end

if (strcmp(cEvent.tag, 'departure'))
    % If the current event is one user leaving the system, need to remove
    % it from the current active user set, and reallocate the user rates.
    % Also, for other users, reassign the departure events as needed.
    cID = cEvent.userID;
    cTime = cEvent.time;
    cType = cEvent.type;
    cSlice = cEvent.slice;
    cWL = cEvent.workload;
    assert(user_active(cID) == 1);
    user_active(cID) = 0;
    new_user_timing(2, cID) = cTime;

    current_time = cTime;
    % Remove the current user from the slice_user set
    for i = 1:size(slice_users{cSlice}, 2)
        if(slice_users{cSlice}(i) == cID)
            slice_users{cSlice} = slice_users{cSlice}([1:(i - 1), (i + 1):end]);
            break
        end
    end
    
    user_weights = get_weight_allocation(user_active, user_demands, shares, weight_strata, capacities, slice_users);
  
    % revoke all the departure event associated with current active
    % users
    % TODO: improve this part....
    % Inorder to update the remaining workload, use the previous user_rates
    % and the difference b/w last_time and cTime
    eid = 1;
    while(eid <= size(event_list, 2))
        if(strcmp(event_list{eid}.tag, 'departure') && user_active(event_list{eid}.userID) == 1)
            % remove event_list{eid}
            event_list = {event_list{1:(eid - 1)}, event_list{(eid + 1):end}};
        else
            eid = eid + 1;
        end
    end 
    
    % According to the logic there should be no negative workloads
    new_user_workloads = user_workloads - user_active .* user_rates * (cTime - last_time);
    new_user_workloads(cID) = 0;
    
    % The initial guess is such that, all inactive users are set to 0 and
    % all active users get something definitely surpasses the capacity.
    init_guess = 10 * max(capacities) * ones(nUsers, 1);
    init_guess = init_guess .* user_active';
    
    % if there is no active user at this time, there is no need to do
    % maxmin
    if (sum(user_active) > 0)
        [cRate, lambda] = maxmin_cached(user_types, user_weights, capacities, user_demands, cache);
    else
        cRate = zeros(nUsers, 1);
    end
    %update rate allocation
    new_user_rates = cRate';
    
    % Update/insert new departure events
    for cuser = 1:nUsers
        if(user_active(cuser) == 1)
            % Predict when it will be departing
            estimate_departure_time = new_user_workloads(cuser) / ...
                new_user_rates(cuser) + cTime;
            assert(estimate_departure_time > 0)
            % Looking forward to seek for a place to insert
            inserted = false;
            for eid = 1:size(event_list, 2)
                if (event_list{eid}.time > estimate_departure_time)
                    event.time = estimate_departure_time;
                    event.type = user_types(cuser);
                    event.slice = user_slices(cuser);
                    event.tag = 'departure';
                    event.userID = cuser;
                    event.workload = 0;
                    event_list = {event_list{1:(eid - 1)}, event, event_list{eid:end}};
                    inserted = true;
                    break;
                end
            end
            if(~inserted)
                % append to the end of the list
                event.time = estimate_departure_time;
                event.type = user_types(cuser);
                event.slice = user_slices(cuser);
                event.tag = 'departure';
                event.userID = cuser;
                event.workload = 0;
                event_list{end + 1} = event;
            end
        end
    end
    
    current_time = cTime;
    new_slice_users = slice_users;  
end

new_user_active = user_active;
new_event_list = event_list(2:end); %deque
end

