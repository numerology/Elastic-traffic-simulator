function [sliceDelays, sliceThroughputs, meanDelay, sliceDelaySamples] = getdelayunderdynamic...
    (duration, capacities, ... 
    typeDemands, workloads, weightStrata, shares, arrivalRates, verbose)
% The function getting the average delay of different users under a dynamic 
% setting. The rate allocation is according to proportionally fair.
% --------------------------------
% Parameters:
% --------------------------------
% - duration: duration of the simulation, longer duration will be slower
% and more accurate. This will not be exactly the same as the duration of
% the simulated run, but the latest arrival could be.
% - capacities: capacities of each resource.
% - type_demands: define the demanding vector for each user types. Each 
% column is a demanding vector of one type of user.
% - workloads: mean work loads of each type.
% - weight_strata: weighting strategy: equal, nhops, nresources.
% - shares: slice shares
% - arrival_rates: matrix of arrival rates, arrival_rates(v, t) is the
% arrival rate of user of type t on slice v.
% - verbose: level of log info: 0 = display off, 1 = log displayed.

% -----------------------
% Argument checking
% -----------------------
B = size(capacities, 1); % num of resources
T = size(typeDemands, 2); % num of types
V = size(shares, 1); % num of slices

assert(isequal(size(capacities), [B, 1]));
assert(isequal(size(typeDemands), [B, T]));
assert(isequal(size(workloads), [T, 1]));
assert(isequal(size(shares), [V, 1]));
assert(isequal(size(arrivalRates), [V, T]));
assert(strcmp(weightStrata, 'equal') || strcmp(weightStrata, 'nhops') ...
    || strcmp(weightStrata, 'nresources') ...
    || strcmp(weightStrata, 'inverseresources') ...
    || strcmp(weightStrata, 'drf') ...
    || strcmp(weightStrata, 'pf') ...
    || strcmp(weightStrata, 'inverseresc-square') ...
    || strcmp(weightStrata, 'inverseresc-sqrt'));

if(verbose > 0)
    fprintf('\n');
    disp('Start initialization');
end
[eventList, userDemands, userTypes, userSlices] = ...
    initialization(arrivalRates, duration, workloads, typeDemands, verbose);
%[event_list, user_demands, user_types, user_slices] = ...
%    fake_initialization(arrival_rates, duration, inv_workloads, type_demands);
nUsers = size(eventList, 2);
cache = containers.Map; % cache of maxmin solution
if(verbose > 0)
    disp('Finish initialization');
end

userRates = zeros(1, nUsers); 
% track current transmission rate each user is perceiving
userWorkloads = zeros(1, nUsers); % track remaining workloads

for u = 1:nUsers
    userWorkloads(u) = eventList{u}.workload;
end
userActive = zeros(1, nUsers);
userTiming = -1 * ones(2, nUsers); % -1 = uninitialized
sliceUsers = cell(1, V);
lastTime = 0;

reverseStr = '';
initWorkLoads = userWorkloads;
while(size(eventList, 2) > 0)
    % Update the event and do the allocation
    [newEventList, userRates, userWorkloads, userActive, ...
        userTiming, sliceUsers, lastTime] = ...
        eventupdate(eventList, userRates, userWorkloads, userActive, ...
        weightStrata, userTiming, sliceUsers, shares, capacities, ...
        userDemands, lastTime, userTypes, userSlices, cache);
    eventList = newEventList;
    if(verbose > 0)
        msg = sprintf('Time simulated: %3.1f', lastTime);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end

% -----------------------------------
% Tracking quantities:
% -----------------------------------
% In the end we expect the user_timing matrix to be the following:
% -----------------------------------
% arrival time of user 1 | arrival time of user 2 | ...
% ------------------------------------------------------
% departure time of u1   | departure time of u2   | ...
% ------------------------------------------------------

meanDelay = mean(userTiming(2, :) - userTiming(1, :));

% Get mean delay for each type of users
userArrivalTime = userTiming(1,:);
userDepartureTime = userTiming(2, :);
sliceDelays = zeros(1, V);
sliceThroughputs = zeros(1, V);
sliceDelaySamples = cell(1, V);

for i = 1:V
    sliceArrivalTime = userArrivalTime(userSlices == i);
    sliceDepartureTime = userDepartureTime(userSlices == i);
    sliceDelaySamples{i} = sliceDepartureTime - sliceArrivalTime;
    sliceDelays(i) = mean(sliceDelaySamples{i});
    sliceThroughputs(i) = mean(initWorkLoads(userSlices == i) ...
        ./ sliceDelaySamples{i});
end


end

