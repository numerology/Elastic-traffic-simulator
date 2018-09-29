function [ user_weights ] = get_weight_allocation( user_active, user_demands, shares, weight_strata, capacities, slice_users )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
V = size(shares, 1);
if(strcmp(weight_strata, 'equal'))
    user_weights = user_active;
    for v = 1:V
        weight_per_user = shares(v)/size(slice_users{v}, 2);
        for id = slice_users{v}
            user_weights(id) = weight_per_user;
        end
    end
end
    
if(strcmp(weight_strata, 'nhops'))
    user_weights = user_active;
    % Need to consider each type, how many inverse resources is required.
    for v = 1:V
        total_demands = 0;
        for id = slice_users{v}
            total_demands = total_demands + 1/size(find(user_demands(:, id)), 1);
        end
        for id = slice_users{v}
            user_weights(id) = shares(v) * (1/size(find(user_demands(:, id)), 1))/total_demands;
        end
    end
end

if(strcmp(weight_strata, 'nresources'))
    user_weights = user_active;
    for v = 1:V
        total_resc = 0;
        for id = slice_users{v}
            total_resc = total_resc + 1/sum(user_demands(:, id));
        end
        for id = slice_users{v}
            user_weights(id) = shares(v) * (1/sum(user_demands(:, id)))/total_resc;
        end
    end
end

if(strcmp(weight_strata, 'inverseresources'))
    user_weights = user_active;
    for v = 1:V
        total_inverse_resc = 0;
        for id = slice_users{v}
            total_inverse_resc = total_inverse_resc + sum(user_demands(:, id));
        end
        for id = slice_users{v}
            user_weights(id) = shares(v) * (sum(user_demands(:, id)))/total_inverse_resc;
        end
    end        
end

if(strcmp(weight_strata, 'inverseresc-sqrt'))
    user_weights = user_active;
    for v = 1:V
        total_inverse_resc_sqrt = 0;
        for id = slice_users{v}
            total_inverse_resc_sqrt = total_inverse_resc_sqrt + sqrt(sum(user_demands(:, id)));
        end
        for id = slice_users{v}
            user_weights(id) = shares(v) * (sqrt(sum(user_demands(:, id))))/total_inverse_resc_sqrt;
        end
    end
end

if(strcmp(weight_strata, 'inverseresc-square'))
    user_weights = user_active;
    for v = 1:V
        total_inverse_resc_square = 0;
        for id = slice_users{v}
            total_inverse_resc_square = total_inverse_resc_square + (sum(user_demands(:, id)))^2;
        end
        for id = slice_users{v}
            user_weights(id) = shares(v) * (sum(user_demands(:, id)))^2/total_inverse_resc_square;
        end
    end
end
    

if(strcmp(weight_strata, 'drf'))
    user_weights = user_active;
    for v = 1:V
        total_inverse_dominant_shares = 0;
        for id = slice_users{v}
            % find the relative ratio of demanding vectors against total
            % capacities.
            dominant_shares_vec = user_demands(:, id)./capacities;
            dominant_share = max(dominant_shares_vec);
            total_inverse_dominant_shares = total_inverse_dominant_shares + 1/dominant_share;
        end
        for id = slice_users{v}
            dominant_shares_vec = user_demands(:, id)./capacities;
            dominant_share = max(dominant_shares_vec);
            user_weights(id) = shares(v) * (1/dominant_share) / total_inverse_dominant_shares;
        end
    end
end

