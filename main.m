% main script for the simulation under dynamic settings
% ---------------
% PARAMS SETUP
% ---------------
% System-wise:
duration = 50; % duration of the simulation, longer duration will be slower
capacities = [1, 1, 1, 1]'; % capacities of each resource
B = size(capacities, 1); % number of resources
% define the demanding vector for each user types
% each column is a demanding vector of one type of user
type_demands = [1 2 0 0; 0 1 2 0; 0 2 0 1; 1 1 1 1]';
T = size(type_demands, 2);
assert(size(type_demands, 1) == B)
workloads = [2, 2, 2, 2]; % inverse mean work loads of each type

% Traffic-wise
weight_strata = 'equal'; % weighting strategy: equal, nhops, nresources
shares = [1/2, 1/2]'; % slice shares
V = size(shares, 1);
% matrix of arrival rate: (V * T)
% arrival_rate(v, t) is the arrival rate of user of type t on slice v
arrival_rate = [1 1 0 0; 0 0 1 1];

% Generate the intial event queue
% Obviously, the intial event queue only contains arrival events
% Thus the total number of user could be inferred
disp('Start initialization');
[event_list, user_demands, user_types, user_slices] = initialization(arrival_rate, duration, workloads, type_demands);
nUser = size(event_list, 2);
disp('Finish initialization');

% Use a big vector to track the rate of all users. Inactive users are set
% to 0.
% Use another big vector to track the remaining workload of all users. When
% the user's workload is running out, update the event queue
% Use another big 0-1 vector to record which users are active at current
% time.
% Use a 2 x nUser matrix to record the timing
% First row: time when a user arrives
% Second row: time when it leaves, initialized at -1
% User a cell vector of V to store the set of ACTIVE users of each slice
user_rates = zeros(1, nUser);
user_workloads = zeros(1, nUser);
for u = 1:nUser % Note that the way I assigned ID is according to the order in event_list
    user_workloads(u) = event_list{u}.workload;
end
user_active = zeros(1, nUser);
user_timing = -1 * ones(2, nUser);
slice_users = cell(1, V);
last_time = 0;

% -------------------
% TRACKING QUANTITIES
% -------------------
% For the purpose of study we want to track: the perceived user rates,
% the delayed perceived by users

reverseStr = '';
while(size(event_list, 2) > 0)
    % Update the event and do the allocation
    [new_event_list, user_rates, user_workloads, user_active, user_timing, slice_users, last_time] = ...
        eventUpdate(event_list, user_rates, user_workloads, user_active, ...
        weight_strata, user_timing, slice_users, shares, capacities, user_demands, ...
        last_time, user_types, user_slices);
    event_list = new_event_list;   
    msg = sprintf('Time simulated: %3.1f', last_time); %Don't forget this semicolon
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end






