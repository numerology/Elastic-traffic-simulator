% Scripts to compare the performance of SCPF against other weighting schemes
% Very simple setting is adopted.
addpath('../');
clear;
capacities = ones(1,1);
typeDemands = [1;1]';
duration = 100;
relativeArrivalRates = [1 0; 
                        0 1];
verbose = 0;
workloads = 1 * [1,1]';
repetition = 1000;
shareVec = 0.1:0.05:0.9;
T = size(relativeArrivalRates, 2);
V = 2;
gcp;

% To prevent cofounding issue, need to separate the iteration for slice 1
% and 2
%% 
disp('testing equal weight alloc');
ppm = ParforProgMon('For SCPF progress 1: ', repetition);
delayEqualMat = zeros(repetition, size(shareVec, 2), V);
throughputEqualMat = zeros(repetition, size(shareVec, 2), V);
delaySamples1 = cell(repetition, V);
delaySamples2 = cell(repetition, V);
parfor i = 1:repetition
    delayEqual = zeros(size(shareVec, 2), V);
    throughputEqual = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, sliceRates, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'equal', [share_1, 1 - share_1]', ...
            0.4 * relativeArrivalRates, verbose);
        delayEqual(shareVec == share_1, :) =  sliceDelay;
        throughputEqual(shareVec == share_1, :) = sliceRates;
        if (share_1 == shareVec(1))
            delaySamples1{i, 1} = sliceDelaySamples{1};
        end
        if (share_1 == 0.5)
            delaySamples2{i, 1} = sliceDelaySamples{1};
        end
    end
    ppm.increment();
    delayEqualMat(i, :, 1) = delayEqual(:, 1);
    throughputEqualMat(i, :, 1) = throughputEqual(:, 1);
end

ppm2 = ParforProgMon('For scpf progress 2: ', repetition);
parfor i = 1:repetition
    delayEqual = zeros(size(shareVec, 2), V);
    throughputEqual = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, sliceRates, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'equal', [share_1, 1 - share_1]', ...
            0.4 * relativeArrivalRates, verbose);
        delayEqual(shareVec == share_1, :) =  sliceDelay;
        throughputEqual(shareVec == share_1, :) = sliceRates;
        if (share_1 == shareVec(1))
            delaySamples1{i, 2} = sliceDelaySamples{2};
        end
        if (share_1 == 0.5)
            delaySamples2{i, 2} = sliceDelaySamples{2};
        end
    end
    ppm2.increment();
    delayEqualMat(i, :, 2) = delayEqual(:, 2);
    throughputEqualMat(i, :, 2) = throughputEqual(:, 2);
end

delayEqual = nanmean(delayEqualMat, 1);
throughputEqual = nanmean(throughputEqualMat, 1);
%% 
disp('testing equal weight alloc');
ppm3 = ParforProgMon('For DPS progress 1: ', repetition);
delayPsMat = zeros(repetition, size(shareVec, 2), V);
throughputPsMat = zeros(repetition, size(shareVec, 2), V);

parfor i = 1:repetition
    delayPs = zeros(size(shareVec, 2), V);
    throughputPs = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, sliceRates, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'dps', [share_1, 1 - share_1]', ...
            0.4 * relativeArrivalRates, verbose);
        delayPs(shareVec == share_1, :) =  sliceDelay;
        throughputPs(shareVec == share_1, :) = sliceRates;
    end
    ppm3.increment();
    delayPsMat(i, :, 1) = delayPs(:, 1);
    throughputPsMat(i, :, 1) = throughputPs(:, 1);
end

ppm4 = ParforProgMon('For DPS progress 2: ', repetition);
parfor i = 1:repetition
    delayPs = zeros(size(shareVec, 2), V);
    throughputPs = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, sliceRates, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'dps', [share_1, 1 - share_1]', ...
            0.4 * relativeArrivalRates, verbose);
        delayPs(shareVec == share_1, :) =  sliceDelay;
        throughputPs(shareVec == share_1, :) = sliceRates;
    end
    ppm4.increment();
    delayPsMat(i, :, 2) = delayPs(:, 2);
    throughputPsMat(i, :, 2) = throughputPs(:, 2);
end

delayPs = nanmean(delayPsMat, 1);
throughputPs = nanmean(throughputPsMat, 1);
%% Plot normalized service rate
figure()
hold on 
title('Normalized service rate under different shares')
plot(throughputEqual(:,:,1), throughputEqual(:,:,2), 'b+-');
plot(throughputPs(:,:,1), throughputPs(:,:,2), 'rd-');
legend('Under SCPF sharing', 'Under DPS');
xlabel('Slice 1');
ylabel('Slice 2');
%% Plot normalized service rate
figure()
hold on 
title('Inversed mean delay under different shares')
plot(1./delayEqual(:,:,1), 1./delayEqual(:,:,2), 'b+-');
plot(1./delayPs(:,:,1), 1./delayPs(:,:,2), 'rd-');
legend('Under SCPF sharing', 'Under DPS');
xlabel('Slice 1');
ylabel('Slice 2');
%% Plot delay
figure()
hold on 
title('Mean delay under different shares')
plot(delayEqual(:,:,1), delayEqual(:,:,2), 'b+-');
plot(delayPs(:,:,1), delayPs(:,:,2), 'rd-');
legend('Under SCPF sharing', 'Under DPS');
xlabel('Slice 1');
ylabel('Slice 2');
%%
for share = [shareVec(1) 0.5]
    delayVec1 = [];
    for i = 1:repetition
        if (share == shareVec(1))
            delayVec1 = [delayVec1 delaySamples1{i, 1}];
        end
        if (share == 0.5)
            delayVec1 = [delayVec1 delaySamples2{i, 1}];
        end
    end

    delayVec2 = [];
    for i = 1:repetition
        if (share == shareVec(1))
            delayVec2 = [delayVec2 delaySamples1{i, 2}];
        end
        if (share == 0.5)
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
    title(strcat('Histogram of log delay for each slice under share_1 ...= ', ...
        num2str(share)));
    legend('slice 1', 'slice 2')
end
