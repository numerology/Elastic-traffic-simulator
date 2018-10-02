function [ keyStr ] = keygen(nUsersPerType )
% Generate string key for a hashmap access to cache the maxmin result.
% Because if this vector takes the same value, then the distribution of
% user weight must be the same. Then the result of maxmin problem should
% be the same.
% --------------------------------
% Parameters:
% --------------------------------
% - nUsersPerType: vector of number of users per slice x type.
% --------------------------------
% Ret:
% --------------------------------%   
% keyStr: key string

keyStr = '';
for number = nUsersPerType
    keyStr = [keyStr, '-', num2str(number)];
end
end

