function [ ThetaGrad ] = computeThetaGradient( Points, XYGrad )
% The theta component of the gradient by the chain rule is 
%   dT/dtheta = dT/dx*dx/dtheta + dT/dy*dy/dtheta
%             = dT/dx*(-r*sin(theta)) + dT/dy*(r*cos(theta))
%             = dT/dy*x - dT/dx*y
ThetaGrad = XYGrad(:,2).*Points(:,1) - XYGrad(:,1).*Points(:,2);
end