function [ Grad_Obj] = grad_objective( Config, CenterOfMass, Panels,...
    Pressure, Grad_Pressure, X0, X )
%% GRAD_OBJECTIVE is the gradient of the objective function.
% @todo: Verify Gradients: http://de.mathworks.com/help/optim/ug/checking-validity-of-gradients-or-jacobians.html
%%
CM = CenterOfMass;
%%
Grad_Obj = zeros(1, length(X));
%%
if ~all(Config.NLP.Objective.ConservativeForces == [0 0])
    Grad_Potential = -Config.NLP.Objective.ConservativeForces*...
        grad_moveCM(CM, X);
    % Potential = -dot(movePoints(CM, X) - CM,...
    %   Config.NLP.Objective.ConservativeForces);
    Grad_Obj = Grad_Obj + Grad_Potential;
    %   E = E + Potential;
end
%%
if Config.NLP.Objective.PressureLoad
    %Grad_Force0 = 0;
    %Force0 = integratePressureLoad(Pressure, Panels, X0);
    Grad_DeltaCM = grad_moveCM(CM, X);
    % DeltaCM = movePoints(CM, X) - movePoints(CM, X0);
    for i = 1:length(X)
        %Grad_Force0 = [0 0 0];
        Force0 = integratePressureLoad(Pressure, Panels, X0);
        % Grad_Force = ? % I'm not yet sure how to differentiate this term and we don't really gain anything here.
        Force = integratePressureLoad(Pressure, Panels, X);
        % By the chain rule
        %   Grad_Work = dot(-(Force0 + Force)/2, Grad_DeltaCM) 
        %               + dot(-Grad_Force/2, DeltaCM);
        % So we are neglecting the second term.
        Grad_Work = dot(-(Force0 + Force)/2, Grad_DeltaCM(i,:));
        % Work = dot(-(Force0 + Force)/2, DeltaCM);
        Grad_Obj(i) = Grad_Obj(i) + Grad_Work;
        % Obj = Obj + Work;
    end
end
end

function [ Grad_CM ] = grad_moveCM( CenterOfMass, X )
% See movePoints.m
if length(X) == 2
    Grad_CM = diag(ones(2,1));
    return
end
Grad_CM = zeros(length(CenterOfMass), length(X));
if length(X) == 3
    theta = X(3);
    dR_over_dtheta = [-sin(theta) -cos(theta); cos(theta) -sin(theta)]; % R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
end
dCM_over_dR = CenterOfMass; % CG = CG*R
dCM_over_dtheta = dCM_over_dR*dR_over_dtheta;
Grad_CM(1,1) = 1; % dx/dx
Grad_CM(2,2) = 1; % dy/dy
Grad_CM(:,3) = dCM_over_dtheta;
end