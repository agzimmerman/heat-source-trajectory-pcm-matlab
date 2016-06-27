function [ InequalityConstraints, EqualityConstraints, GI, GE ] = ...
    constraints( Config, BodyPoints, Temperature, GradT, X )
%%CONSTRAINTS is the nonlinear constraints function for optimization.
%   Constrain the body to not penetrate the T <= T_melt domain.
%
%   BodyPoints are the discrete points on the body to be constrained.
%
%   Temperature is the scatteredInterpolant of the temperature field.
%
%   X, the vector of design variables, is the transformation vector,
%   [\Delta\X, \Delta\Y, \Delta\theta]
%
%   Config.PDE.T_Melt is the melting temperature of the phase change
%   material.
T = Temperature(movePoints(BodyPoints, X));
InequalityConstraints = Config.PDE.T_Melt - T; % The constraints C <= 0 must be satisified.
EqualityConstraints = []; % There are no equality constraints.
%%
if Config.NLP.UseGradients
    GI = grad_constraints(BodyPoints, GradT, X)';
else
    GI = [];
end
GE = [];
end