function [ key_str ] = key_gen(num_users_per_types )
%Generate string key for a hashmap access to cache the maxmin result.
%
%   num_users_per_types: vector of number of users per slice x type.
%   because if this vector takes the same value, then the distribution of
%   user weight must be the same. Then the result of maxmin problem should
%   be the same.

%   key string
key_str = '';
for number = num_users_per_types
    key_str = [key_str, '-', num2str(number)];
end
end

