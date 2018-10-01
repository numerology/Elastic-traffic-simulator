function [ userWeights ] = getweightallocation( userActive, userDemands, ...
    shares, weightStrata, capacities, sliceUsers )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
V = size(shares, 1);
if(strcmp(weightStrata, 'equal'))
    userWeights = userActive;
    for v = 1:V
        weightPerUser = shares(v)/size(sliceUsers{v}, 2);
        for id = sliceUsers{v}
            userWeights(id) = weightPerUser;
        end
    end
end
    
if(strcmp(weightStrata, 'nhops'))
    userWeights = userActive;
    % Need to consider each type, how many inverse resources is required.
    for v = 1:V
        totalDemands = 0;
        for id = sliceUsers{v}
            totalDemands = totalDemands + 1 ...
                / size(find(userDemands(:, id)), 1);
        end
        for id = sliceUsers{v}
            userWeights(id) = shares(v) * (1 ...
                / size(find(userDemands(:, id)), 1)) / totalDemands;
        end
    end
end

if(strcmp(weightStrata, 'nresources'))
    userWeights = userActive;
    for v = 1:V
        totalResc = 0;
        for id = sliceUsers{v}
            totalResc = totalResc + 1/sum(userDemands(:, id));
        end
        for id = sliceUsers{v}
            userWeights(id) = shares(v) * (1 ...
                / sum(userDemands(:, id))) / totalResc;
        end
    end
end

if(strcmp(weightStrata, 'inverseresources'))
    userWeights = userActive;
    for v = 1:V
        totalInverseResc = 0;
        for id = sliceUsers{v}
            totalInverseResc = totalInverseResc ...
                + sum(userDemands(:, id));
        end
        for id = sliceUsers{v}
            userWeights(id) = shares(v) * (sum(userDemands(:, id))) ...
                / totalInverseResc;
        end
    end        
end

if(strcmp(weightStrata, 'inverseresc-sqrt'))
    userWeights = userActive;
    for v = 1:V
        totalInverseRescSqrt = 0;
        for id = sliceUsers{v}
            totalInverseRescSqrt = totalInverseRescSqrt ...
                + sqrt(sum(userDemands(:, id)));
        end
        for id = sliceUsers{v}
            userWeights(id) = shares(v) * (sqrt(sum(userDemands(:, id))))...
                / totalInverseRescSqrt;
        end
    end
end

if(strcmp(weightStrata, 'inverseresc-square'))
    userWeights = userActive;
    for v = 1:V
        totalInverseRescSquare = 0;
        for id = sliceUsers{v}
            totalInverseRescSquare = totalInverseRescSquare ...
                + (sum(userDemands(:, id))) ^ 2;
        end
        for id = sliceUsers{v}
            userWeights(id) = shares(v) * (sum(userDemands(:, id))) ^ 2 ...
                / totalInverseRescSquare;
        end
    end
end
    

if(strcmp(weightStrata, 'drf'))
    userWeights = userActive;
    for v = 1:V
        totalInverseDominantShares = 0;
        for id = sliceUsers{v}
            % find the relative ratio of demanding vectors against total
            % capacities.
            dominantSharesVec = userDemands(:, id) ./ capacities;
            dominantShare = max(dominantSharesVec);
            totalInverseDominantShares = totalInverseDominantShares + ...
                1 / dominantShare;
        end
        for id = sliceUsers{v}
            dominantSharesVec = userDemands(:, id) ./ capacities;
            dominantShare = max(dominantSharesVec);
            userWeights(id) = shares(v) * (1/dominantShare) ...
                / totalInverseDominantShares;
        end
    end
end

