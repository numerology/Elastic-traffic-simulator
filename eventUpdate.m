function [newEventList, newUserRates, newUserWorkloads, ...
    newUserActive, newUserTiming, newSliceUsers, currentTime] = ...
    eventupdate(eventList, userRates, userWorkloads,...
    userActive, weightStrata, userTiming, sliceUsers, shares, ...
    capacities, userDemands, lastTime, userTypes, userSlices, cache)
% Update the configuration according to the first/earliest event in the
% event queue.
% --------------------------------
% Parameters:
% --------------------------------
% - eventList: current list of events to be simulated.
% - userRates: current rate allcation for each user. 1 x nUsers
% - userWorkLoads: amount of workloads associated with each user. 1 x
% nUsers.
% - userActive: if a user is active currently, 1, otherwise 0. 1 x nUsers.
% - weightStrate: weighting scheme
% - userTiming: recording the users departure (first row) and arrival 
% (second row)time, -1 stands for N/A. 2 x nUsers.
% - sliceUsers: 1 x V cell array tracking set of user ids under each slice.
% - shares: 1 x V share allocation vector.
% - capacities: capacity of each resource. R x 1 
% - userDemands: R x nUsers matrix tracking demand vector for each users.
% - lastTime: timestamp of last event processed.
% - userTypes: 1 x nUsers matrix tracking type of each user.
% - userSlices: 1 x nUsers tracking the slice id for each user.
% - cache: cache storing existing optimization result.
% --------------------------------
% Ret:
% --------------------------------
% new version (after processing the current event) of eventList, userRates,
% userWorkLoads, userActive, userTiming, sliceUsers and timestamp for this
% event.

V = size(sliceUsers, 2);
B = size(capacities, 1);
nUsers = size(userRates, 2);

cEvent = eventList{1}; % fetch the first event
newUserTiming = userTiming;

if (strcmp(cEvent.tag, 'invalid'))
    % If the event has been revoked. Then return all parameters as they are
    newUserRates = userRates;
    newUserWorkloads = userWorkloads;
    newUserTiming = userTiming;
    newSliceUsers = sliceUsers;
    currentTime = lastTime;
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
    assert(userActive(cID) == 0);
    userActive(cID) = 1;
    newUserTiming(1, cID) = cTime;
    currentTime = cTime;
    sliceUsers{cSlice}(end + 1) = cID;
    % adjust weight allocation among users
    
    userWeights =  getweightallocation(userActive, userDemands, shares, ...
        weightStrata, capacities, sliceUsers);
    % revoke all the departure event associated with current active
    % users
    % Inorder to update the remaining workload, use the previous user_rates
    % and the difference b/w last_time and cTime
    eid = 1;
    while(eid <= size(eventList, 2))
        if(strcmp(eventList{eid}.tag, 'departure') && ...
                userActive(eventList{eid}.userID) == 1)
            % remove event_list{eid}
            eventList = {eventList{1:(eid - 1)}, eventList{(eid + 1):end}};
        else
            eid = eid + 1;
        end
    end 
    
    % According to the logic there should be no negative workloads
    newUserWorkloads = userWorkloads - userActive .* userRates ...
        * (cTime - lastTime);
    [cRate, lambda] = maxmincached(userTypes, userWeights, capacities, ...
        userDemands, cache);
    %update rate allocation
    newUserRates = cRate';
    assert(all(cRate >= 0));
    assert(all(cRate < inf));
    
    % Update/insert new departure events
    for cuser = 1:nUsers
        if(userActive(cuser) == 1)
            % Predict when it will be departing
            estimateDepartureTime = newUserWorkloads(cuser) / ...
                newUserRates(cuser) + cTime;
            assert(estimateDepartureTime > 0)
            % Looking forward to seek for a place to insert
            inserted = false;
            for eid = 1:size(eventList, 2)
                if (eventList{eid}.time > estimateDepartureTime)
                    event.time = estimateDepartureTime;
                    event.type = userTypes(cuser);
                    event.slice = userSlices(cuser);
                    event.tag = 'departure';
                    event.userID = cuser;
                    event.workload = 0;
                    eventList = {eventList{1:(eid - 1)}, event, ...
                        eventList{eid:end}};
                    inserted = true;
                    break;
                end
            end
            if(~inserted)
                % append to the end of the list
                event.time = estimateDepartureTime;
                event.type = userTypes(cuser);
                event.slice = userSlices(cuser);
                event.tag = 'departure';
                event.userID = cuser;
                event.workload = 0;
                eventList{end + 1} = event;
            end
        end
    end
    
    currentTime = cTime;
    newSliceUsers = sliceUsers;
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
    assert(userActive(cID) == 1);
    userActive(cID) = 0;
    newUserTiming(2, cID) = cTime;

    currentTime = cTime;
    % Remove the current user from the slice_user set
    for i = 1:size(sliceUsers{cSlice}, 2)
        if(sliceUsers{cSlice}(i) == cID)
            sliceUsers{cSlice} = sliceUsers{cSlice}([1:(i - 1), ...
                (i + 1):end]);
            break
        end
    end
    
    userWeights = getweightallocation(userActive, userDemands, shares, ...
        weightStrata, capacities, sliceUsers);
  
    % revoke all the departure event associated with current active
    % users
    % TODO: improve this part....
    % Inorder to update the remaining workload, use the previous user_rates
    % and the difference b/w last_time and cTime
    eid = 1;
    while(eid <= size(eventList, 2))
        if(strcmp(eventList{eid}.tag, 'departure') && ...
                userActive(eventList{eid}.userID) == 1)
            % remove event_list{eid}
            eventList = {eventList{1:(eid - 1)}, eventList{(eid + 1):end}};
        else
            eid = eid + 1;
        end
    end 
    
    % According to the logic there should be no negative workloads
    newUserWorkloads = userWorkloads - userActive .* userRates * (cTime ...
        - lastTime);
    newUserWorkloads(cID) = 0;
    
    % if there is no active user at this time, there is no need to do
    % maxmin
    if (sum(userActive) > 0)
        [cRate, lambda] = maxmincached(userTypes, userWeights, ...
            capacities, userDemands, cache);
    else
        cRate = zeros(nUsers, 1);
    end
    %update rate allocation
    newUserRates = cRate';
    
    % Update/insert new departure events
    for cuser = 1:nUsers
        if(userActive(cuser) == 1)
            % Predict when it will be departing
            estimateDepartureTime = newUserWorkloads(cuser) / ...
                newUserRates(cuser) + cTime;
            assert(estimateDepartureTime > 0)
            % Looking forward to seek for a place to insert
            inserted = false;
            for eid = 1:size(eventList, 2)
                if (eventList{eid}.time > estimateDepartureTime)
                    event.time = estimateDepartureTime;
                    event.type = userTypes(cuser);
                    event.slice = userSlices(cuser);
                    event.tag = 'departure';
                    event.userID = cuser;
                    event.workload = 0;
                    eventList = {eventList{1:(eid - 1)}, event, ...
                        eventList{eid:end}};
                    inserted = true;
                    break;
                end
            end
            if(~inserted)
                % append to the end of the list
                event.time = estimateDepartureTime;
                event.type = userTypes(cuser);
                event.slice = userSlices(cuser);
                event.tag = 'departure';
                event.userID = cuser;
                event.workload = 0;
                eventList{end + 1} = event;
            end
        end
    end
    
    currentTime = cTime;
    newSliceUsers = sliceUsers;  
end

newUserActive = userActive;
newEventList = eventList(2:end); %deque
end

