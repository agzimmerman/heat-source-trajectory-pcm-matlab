function [ C ] = integrateCentroid(Points)
% http://mathworld.wolfram.com/GreensTheorem.html
% Assume linear interpolation between each point on the body.
Points = [Points; Points(end,:)]; % Close the curve.
x = Points(:,1);
y = Points(:,2);
xbar = (x(1:end-1) + x(2:end))/2;
ybar = (y(1:end-1) + y(2:end))/2;
dx = diff(x);
dy = diff(y);
ds = sqrt(dx.^2 + dy.^2);
A = dot(xbar.*dy, ds);
Mx = -0.5*dot(ybar.^2.*dx, ds);
My = -0.5*dot(xbar.^2.*dy, ds);
C = [My Mx]/A;
end