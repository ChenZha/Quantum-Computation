function [ data ] = TestFunc( x,c )
%TESTFUNC Summary of this function goes here
%   Detailed explanation goes here
nx = length(x);
data = cell(1,nx);
for ii = 1:nx
    data{ii} = x{ii}*2;
end

end

