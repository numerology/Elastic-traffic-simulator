function [ key_str ] = new_key_gen()
%Generate string key for a hashmap access to cache the maxmin result.
%
%   num_users_per_types: cells of vectors of number of users per slice x type.
%   because if this vector takes the same value, then the distribution of
%   user weight must be the same. Then the result of maxmin problem should
%   be the same.

%   key string
key_str = '';
