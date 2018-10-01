% Scripts to test the behavior of different components.
% Very simple setting is adopted.

% Script to test the behavior of resource allocation under
% SCPF weighting scheme and weighted maxmin
% when share allocation among slices is tuned.
addpath('../');
clear;
capacities = ones(1,1);
typeDemands = [1;1]';
duration = 50;
relativeArrivalRates = [1 0; 
                          0 1];
verbose = 0;
workloads = 1 * [1,1]';
repetition = 10;
shareVec = 0.1:0.1:0.9;
T = size(relativeArrivalRates, 2);
V = 2;
gcp;
ppm = ParforProgMon('Progress 1:', repetition);

% To prevent cofounding issue, need to separate the iteration for slice 1
% and 2
%% 
disp('testing equal weight alloc');
resultEqualMat = zeros(repetition, size(shareVec, 2), V);
delaySamples1 = cell(repetition, V);
delaySamples2 = cell(repetition, V);
parfor i = 1:repetition
    resultEqual = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'equal', [share_1, 1 - share_1]', ...
            0.4 * relativeArrivalRates, verbose);
        resultEqual(shareVec == share_1, :) =  sliceDelay;
        if (share_1 == shareVec(1))
            delaySamples1{i, 1} = sliceDelaySamples{1};
        end
        if (share_1 == shareVec(end))
            delaySamples2{i, 1} = sliceDelaySamples{1};
        end
    end
    ppm.increment();
    resultEqualMat(i, :, 1) = resultEqual(:, 1);
end



ppm2 = ParforProgMon('Progress 2:', repetition);
parfor i = 1:repetition
    resultEqual = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, meanDelay, sliceDelaySamples] = getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'equal', [share_1, 1 - share_1]', ...
            0.4 * relativeArrivalRates, verbose);
        resultEqual(shareVec == share_1, :) =  sliceDelay;
        if (share_1 == shareVec(1))
            delaySamples1{i, 2} = sliceDelaySamples{2};
        end
        if (share_1 == shareVec(end))
            delaySamples2{i, 2} = sliceDelaySamples{2};
        end
    end
    ppm2.increment();
    resultEqualMat(i, :, 2) = resultEqual(:, 2);
end

resultEqual = nanmean(resultEqualMat, 1);

%% Plot normalized service rate
figure()
hold on 
title('Normalized service rate under different shares')
plot(1./resultEqual(:,:,1), 1./resultEqual(:,:,2), 'b+-');
xlabel('Slice 1');
ylabel('Slice 2');
%% Plot delay
figure()
hold on 
title('Mean delay under different shares')
plot(resultEqual(:,:,1), resultEqual(:,:,2), 'b+-');
xlabel('Slice 1');
ylabel('Slice 2');
%%
for share = [shareVec(1) shareVec(end)]
    delayVec1 = [];
    for i = 1:repetition
        if (share == shareVec(1))
            delayVec1 = [delayVec1 delaySamples1{i, 1}];
        end
        if (share == shareVec(end))
            delayVec1 = [delayVec1 delaySamples2{i, 1}];
        end
    end

    delayVec2 = [];
    for i = 1:repetition
        if (share == shareVec(1))
            delayVec2 = [delayVec2 delaySamples1{i, 2}];
        end
        if (share == shareVec(end))
            delayVec2 = [delayVec2 delaySamples2{i, 2}];
        end
    end
    
    disp(strcat('Under share 1 = ', num2str(share)))
    mean_log_delay_1 = mean(log(delayVec1))
    mean_log_delay_2 = mean(log(delayVec2))
    
    figure()
    histogram(log(delayVec1),30);
    hold on
    histogram(log(delayVec2),30);
    title(strcat('Histogram of log delay for each slice under share_1 = ', num2str(share)));
    legend('slice 1', 'slice 2')
end
