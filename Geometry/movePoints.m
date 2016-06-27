function [ Points ] = movePoints( Points, X )
%% MOVEPOINTS tranforms the points per the transformation vector.
%
%   Points are the points to be moved.
%
%   X is the transformation vector, [\Delta\X, \Delta\Y, \Delta\theta]
XTrans = X(1);
YTrans = X(2);
%% Translate and rotate the body.
if length(X) == 3
    theta = X(3);
    R = [cos(theta) sin(theta); -sin(theta) cos(theta)]; % Positive theta induces counter-clockwise rotation.
    Points = Points*R; 
end
Points(:,1) = Points(:,1) + XTrans;
Points(:,2) = Points(:,2) + YTrans;
end