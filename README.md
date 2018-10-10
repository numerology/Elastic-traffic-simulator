# Elastic-traffic-simulator

## Purpose:
An event-driven simulator for queueing system with elastic traffic. The main purpose
of the simulator is to examine/compare different weighting schemes across flows/users.

Implemented weighting scheme:
1. Share constrained proportional fairness (SCPF), 
[Statistical Multiplexing and Traffic Shaping Games for Network Slicing,
Jiaxiao Zheng, et al.](https://arxiv.org/pdf/1705.00582.pdf) (Also, variations
of SCPF when resource demands of each user/flow is used to differentiate users/flows)
2. Dominant resource fairness (DRF), 
[Dominant Resource Fairness: Fair Allocation of Multiple Resource Types,
A. Ghodsi, et al.](https://cs.stanford.edu/~matei/papers/2011/nsdi_drf.pdf)
3. ~~TODO: Bottleneck maximal fairness (BMF)~~,
[Multi-resource fairness: Objectives, algorithms and performance, T. Bonarld,
et al.](https://arxiv.org/abs/1410.0782).
Won't do due to complexity.
4. Processor sharing.
5. Discriminatory processor sharing.

## System model:
We are simulating a queueing networks. Take cellular network as an example. It consists
of B base stations, and supports a set of V slices. Each slice manages a set of flows
(or users, they will be used interchangeably), each of which requires a certain 
amount of resource from one or more base stations, in proportion. Also, we assumes 
that the flow  perceived rate will be proportional to the amount of resource allocated.
E.g., if the user's demand is [1, 2, 3], it will have a unit rate if given 1 resource
at base station 1, 2 at base station 2, 3 at base station 3. However, giving it resources
2, 2, 3 makes no improvement. Meanwhile, if it was allocated resource [2, 4, 6] at
base station 1, 2, 3, respectively, it perceives a rate of 2.

Each flows carries an exponentially distributed random workload, and arrives as an
Poisson process. It leaves the system after its workload is finished by its perceived
rate.

## Acknowledgement:
The progressive bar for parallel processing in Matlab is by DylanMuir 
[ParforProgMon](https://github.com/DylanMuir/ParforProgMon).

TODO: Finish the docs and comments
