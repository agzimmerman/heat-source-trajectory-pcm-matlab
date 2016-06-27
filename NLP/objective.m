function [ E, GradE ] = objective( Config, CenterOfMass, Panels,...
    Pressure, Grad_Pressure, X0, X)
%% OBJECTIVE is the objective function for optimization.
%   This objective is to minimize the energy.
%
%   Config.ConservativeForce is a vector representing a uniform
%   conservative force field.
%
%   CenterOfMass is the vector position of the center of mass of the 
%   moving body.
%
%   X, the vector of design variables, is the transformation vector, 
%   [\Delta\X, \Delta\Y, \Delta\theta]

%% Vectorize the interface.
SampleSize = size(X, 1);
DesignVariableCount = size(X, 2);
if SampleSize > 1
    E = NaN(SampleSize, 1);
    GradE = NaN(SampleSize, DesignVariableCount);
    for i = 1:SampleSize % @todo: Vectorize this efficiently (the MATLAB way!)
        [E(i), GradE(i,:)] = objective(Config, CenterOfMass, Panels,...
            Pressure, Grad_Pressure, X0, X(i,:));
    end
    return
end
%% Rename some things for convenience.
CM = CenterOfMass;
%% Accumulate the actual objective function value.
E = 0;
%
if ~all(Config.NLP.Objective.ConservativeForces == [0 0])
    Potential = -dot(movePoints(CM, X) - CM,...
        Config.NLP.Objective.ConservativeForces);
    E = E + Potential;
end
%
if Config.NLP.Objective.PressureLoad
    Force0 = integratePressureLoad(Pressure, Panels, X0);
    Force = integratePressureLoad(Pressure, Panels, X);
    DeltaCM = movePoints(CM, X) - movePoints(CM, X0); % Only consider the movement of the center of mass.
    Work = dot(-(Force0 + Force)/2, DeltaCM); % Alternatively one could integrate over the path.
    E = E + Work; % Scaling this was necessary to get the example to work.
end
if Config.NLP.UseGradients
    GradE = grad_objective(Config, CM, Panels, Pressure, Grad_Pressure, X0, X)';
else
    GradE = NaN(1, DesignVariableCount);
end
end