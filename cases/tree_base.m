% Script to test performance under different sharing criteria
% Examine the trade-off for two-slice setting

% balanced network config and load profile.
addpath('../');
clear;

% Set the environment to send email of results.
mail = 'jxzheng39@gmail.com';
pw = 'password';
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',pw);
setpref('Internet', 'E_mail', mail);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
setpref('Internet','SMTP_Server','smtp.gmail.com');

capacities = [5 1.67 1.67 1.67 5/6 5/6 5/6 5/6 5/6 5/6]';
typeDemands = [1 1 0 0 1 0 0 0 0 0;
               1 1 0 0 0 1 0 0 0 0;
               1 0 1 0 0 0 1 0 0 0;
               1 0 1 0 0 0 0 1 0 0;
               1 0 0 1 0 0 0 0 1 0;
               1 0 0 1 0 0 0 0 0 1]';
duration = 50;
relativeArrivalRates = 0.4 * [1 1 1 0 0 0; 
                              0 0 0 1 1 1];

verbose = 0;
workloads = 1 * [1,1,1,1,1,1]';
repetition = 10;
shareVec = 0.1:0.05:0.9;
T = size(relativeArrivalRates, 2);
V = 2;
gcp;

target = 'equal';
% To prevent cofounding issue, need to separate the iteration for slice 1
% and 2

disp(strcat('testing weight allocation: ', target));
ppm = ParforProgMon('For SCPF progress : ', 2 * repetition);
delayEqualMat = zeros(repetition, size(shareVec, 2), V);
throughputEqualMat = zeros(repetition, size(shareVec, 2), V);
delaySamples1 = cell(repetition, V);
delaySamples2 = cell(repetition, V);
for i = 1:repetition
    delayEqual = zeros(size(shareVec, 2), V);
    throughputEqual = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, sliceRates, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'equal', [share_1, 1 - share_1]', ...
            relativeArrivalRates, verbose);
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

for i = 1:repetition
    delayEqual = zeros(size(shareVec, 2), V);
    throughputEqual = zeros(size(shareVec, 2), V);
    for share_1 = shareVec
        [sliceDelay, sliceRates, meanDelay, sliceDelaySamples] = ...
            getdelayunderdynamic(duration, capacities, ...
            typeDemands, workloads, 'equal', [share_1, 1 - share_1]', ...
            relativeArrivalRates, verbose);
        delayEqual(shareVec == share_1, :) =  sliceDelay;
        throughputEqual(shareVec == share_1, :) = sliceRates;
        if (share_1 == shareVec(1))
            delaySamples1{i, 2} = sliceDelaySamples{2};
        end
        if (share_1 == 0.5)
            delaySamples2{i, 2} = sliceDelaySamples{2};
        end
    end
    ppm.increment();
    delayEqualMat(i, :, 2) = delayEqual(:, 2);
    throughputEqualMat(i, :, 2) = throughputEqual(:, 2);
end

delayEqual = reshape(nanmean(delayEqualMat, 1), [size(shareVec, 2), 2]);
throughputEqual = reshape(nanmean(throughputEqualMat, 1), [size(shareVec, 2), 2]);

sendmail(mail, strcat('Result for: ', target), strcat('delay mat:    ', mat2str(delayEqual)));
sendmail(mail, strcat('Result for: ', target), strcat('throughput mat:    ', mat2str(throughputEqual)));