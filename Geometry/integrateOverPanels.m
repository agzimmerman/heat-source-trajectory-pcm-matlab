function [ I ] = integrateOverPanels(Panels, Function, NormalComponent)
%% INTEGRATEOVERPANELS performs a line integral over the hull panels.
%
%   Function must be a vectorized function of Panels.Center.
%
%   I = INTEGRATEOVERPANELS(Panels, Function) returns the integral of the 
%   Function over the piece-wise linear polyline described by 
%   Panels.Center and Panels.Length. I is size 1 x N, where N is the 
%   dimensionality of the possibly vector valued Function, i.e. 
%   size(Function(Panels.Center), 2).
%
%   I = INTEGRATEOVERPANELS(Panels, Function, true) returns the integral of
%   the body-normal component of the two-dimensional vector-valued Function
%   Panels.UnitNormal must have two columns (for the 2D space).
F = Function(Panels);
if ~exist('NormalComponent', 'var')
    NormalComponent = false;
end
if NormalComponent
    assert(size(F, 2) == size(Panels.UnitNormal, 2))
    for i = 1:height(Panels)
        F(i) = dot(F(i,:), Panels.UnitNormal(i,:));
    end
end
%I = NaN(1, size(F, 2));
%for j = 1:size(F, 2)
%    I(j) = dot(F(:,j), Panels.Length);
%end
I = zeros(1, size(F, 2));
for i = 1:size(F, 1)
    I = I + F(i,:)*Panels.Length(i);
end
end