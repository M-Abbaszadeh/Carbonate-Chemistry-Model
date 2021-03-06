% author: Deborah Sills
% date: 01-26-2013
% file name: calc_alpha2.m
% output: Calculate alpha 2

function alpha2 = calc_alpha2(pH, pK1, pK2)

alpha2 = 1/(1 + 10^(-pH)/10^(-pK2) + (10^(-pH))^ 2/10^(-pK1)/10^(-pK2));



