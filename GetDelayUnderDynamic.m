function [slice_delays, mean_delay, slice_delay_samples] = GetDelayUnderDynamic(duration, capacities, ... 
    type_demands, workloads, weight_strata, shares, arrival_rates, verbose)
% The function version of the main script, getting the average delay of
% different users under a dynamic setting.
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
T = size(type_demands, 2); % num of types
V = size(shares, 1); % num of slices

assert(isequal(size(capacities), [B, 1]));
assert(isequal(size(type_demands), [B, T]));
assert(isequal(size(workloads), [T, 1]));
assert(isequal(size(shares), [V, 1]));
assert(isequal(size(arrival_rates), [V, T]));
assert(strcmp(weight_strata, 'equal') || strcmp(weight_strata, 'nhops') ...
    || strcmp(weight_strata, 'nresources') || strcmp(weight_strata, 'inverseresources') ...
    || strcmp(weight_strata, 'drf') || strcmp(weight_strata, 'pf') ...
    || strcmp(weight_strata, 'inverseresc-square') || strcmp(weight_strata, 'inverseresc-sqrt'));

if(verbose > 0)
    fprintf('\n');
    disp('Start initialization');
end
[event_list, user_demands, user_types, user_slices] = ...
    initialization(arrival_rates, duration, workloads, type_demands, verbose);
%[event_list, user_demands, user_types, user_slices] = ...
%    fake_initialization(arrival_rates, duration, inv_workloads, type_demands);
num_users = size(event_list, 2);
cache = containers.Map; % cache of maxmin solution
if(verbose > 0)
    disp('Finish initialization');
end

user_rates = zeros(1, num_users); 
% track current transmission rate each user is perceiving
user_workloads = zeros(1, num_users); % track remaining workloads

for u = 1:num_users
    user_workloads(u) = event_list{u}.workload;
end
user_active = zeros(1, num_users);
user_timing = -1 * ones(2, num_users); % -1 = uninitialized
slice_users = cell(1, V);
last_time = 0;

reverseStr = '';
while(size(event_list, 2) > 0)
    % Update the event and do the allocation
    [new_event_list, user_rates, user_workloads, user_active, ...
        user_timing, slice_users, last_time] = ...
        eventUpdate(event_list, user_rates, user_workloads, user_active, ...
        weight_strata, user_timing, slice_users, shares, capacities, ...
        user_demands, last_time, user_types, user_slices, cache);
    event_list = new_event_list;
    if(verbose > 0)
        msg = sprintf('Time simulated: %3.1f', last_time);
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

mean_delay = mean(user_timing(2, :) - user_timing(1, :));

% Get mean delay for each type of users
user_arrival_time = user_timing(1,:);
user_departure_time = user_timing(2, :);
slice_delays = zeros(1, V);
slice_delay_samples = cell(1, V);

for i = 1:V
    slice_arrival_time = user_arrival_time(user_slices == i);
    slice_departure_time = user_departure_time(user_slices == i);
    slice_delay_samples{i} = slice_departure_time - slice_arrival_time;
    slice_delays(i) = mean(slice_delay_samples{i});
end


end

