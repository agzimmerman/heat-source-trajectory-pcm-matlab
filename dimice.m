function [ Results ] = dimice(Config)
%%DIMICE demonstrates the modeling and simulation of heat source trajectories
%      through phase-change materials.
%
%   DIMICE(Config) runs the demo with the settings in Config.
%   DIMICE() loads the settings from Config.mat in the working directory.
addpath('General')
if ~exist('Config', 'var')
    Config = loadVar('DefaultConfig.mat', 'Config');
end
Config = init(Config);
%% Initialize the design variables.
% This vector will be referenced throughout this function.
X = [0 0 0]; % X = [/DeltaX, /DeltaY, /Delta/theta], Initial guess: No movement.
if ~Config.Trajectory.EnableRotation
    X = X(1:2);
end
%% Load body geometry.
Hull = loadVar(['Geometry/', Config.Geometry.HullPath], 'Hull');
CM = Config.NLP.Objective.CenterOfMass;
if ischar(CM) && strcmp(CM, 'Centroid')
    CM = integrateCentroid(Hull.Position);
end
Panels = makePanels(Config, Hull); % These panels are needed to integrate over the hull.
%% Get PDE solution field.
SolverDir = ['PDE/', Config.PDE.Solver, '/'];
SolutionFileName = [SolverDir, 'Field.mat']; 
if exist(SolutionFileName, 'file')
    Field = loadVar(SolutionFileName, 'Field');
else
    addpath(SolverDir)
    Field = solvePDE(Config);
end
if ~any(strcmp(Field.Properties.VariableNames, 'Pressure'))
    Field.Pressure = NaN(height(Field), 1); % Simply setting the non-existent pressure to NaN simplifies the programs control flow.
end
% @todo: Try to remove this ad-hoc scaling. So far without it the pressure
% gradient isn't large enough for the optimizer to track it.
Field.Pressure = Field.Pressure*Config.NLP.Objective.PressureScaleFactor;
%
if Config.NLP.UseGradients
    if ~any(strcmp(Field.Properties.VariableNames, 'PressureGradient'))
        Field.PressureGradient = NaN(height(Field), 2); % Simply setting the non-existent pressure to NaN simplifies the programs control flow.
    end
    Field.PressureGradient = ...
        Field.PressureGradient*Config.NLP.Objective.PressureScaleFactor;    
end
if Config.NLP.UseGradients && Config.Trajectory.EnableRotation
    Field.TemperatureGradient(:,3) = ...
        computeThetaGradient(Field.Position, Field.TemperatureGradient);
    Field.PressureGradient(:,3) = ...
        computeThetaGradient(Field.Position, Field.PressureGradient);
end
%% Interpolate the temperature and pressure fields, and their gradients.
InterpMethod = 'natural'; % Natural Neighbor required for C1 continuity (needed for gradient).
ExtrapMethod = 'linear';
T = scatteredInterpolant(Field.Position(:,1), Field.Position(:,2),...
    Field.Temperature, InterpMethod, ExtrapMethod);
P = scatteredInterpolant(Field.Position(:,1), Field.Position(:,2),...
    Field.Pressure, InterpMethod, ExtrapMethod);
if Config.NLP.UseGradients
    for i = 1:length(X)
        GradT{i} = scatteredInterpolant(Field.Position(:,1),...
                Field.Position(:,2), Field.TemperatureGradient(:,i),...
                InterpMethod, ExtrapMethod); %#ok<AGROW>
        GradP{i} = scatteredInterpolant(Field.Position(:,1),...
            Field.Position(:,2), Field.PressureGradient(:,i),...
            InterpMethod, ExtrapMethod); %#ok<AGROW>
    end
else
    GradT = [];
    GradP = [];
end
if Config.Display.PlotAll
    plotInterpolantsAndHull(Config, Hull, T, P, GradT, GradP)
end
%% Define the optimization problem
Solver = Config.NLP.Solver;
Problem.solver = Solver;
if any(strcmp(Solver, {'fmincon', 'ga'}))
    Problem.options = optimoptions(Solver, 'Display', 'Iter');
end
MaxTurnAngle = pi/4;
Problem.Custom.SearchRegion = [...
    (min(Field.Position) - min(Hull.Position)), -MaxTurnAngle;...
    (max(Field.Position) - max(Hull.Position)),  MaxTurnAngle];
if (Config.NLP.Objective.ConservativeForces(2)) < 0
    Problem.Custom.SearchRegion(2,2) = 0; % @todo: Why does the routine break if we don't bound this?
end
if Config.NLP.UseGradients
    Problem.options.SpecifyObjectiveGradient = true;
    Problem.options.SpecifyConstraintGradient = true;
end
if ~Config.NLP.Display
    Problem.options.Display = 'off';
end
if strcmp(Problem.solver, 'ipopt')
    Problem = setIpoptOptions(Config, Problem, Hull, X);
end
if isfield(Config.NLP, 'PlotFcn') && ~isempty(Config.NLP.PlotFcn)
    Problem.options.PlotFcn = Config.NLP.PlotFcn;
end
%% Initialize the trajectory.
Steps = Config.Trajectory.Steps;
if Config.Trajectory.ReverseTurn
    TurnStep = Steps;
    Steps = 2*Steps;
end
if Config.Display.PlotTrajectory
    % Annotate the trajectory figure.
    TrajectoryFigure = figure('Name', 'Trajectory');
    axis equal
    xlabel('x')
    ylabel('y')
    hold on
    plotTransformedBodyAndCM(Hull.Position, CM, X, [0 0 0])
    LegendStrings = {'Step 0: Hull', 'Step 0: CM'};
    Config.Display.Colors = cool(Steps);
else
    TrajectoryFigure = [];
    LegendStrings = {};
end
%% Simulate the trajectory.
Results = table(X);
for Step = 1:Steps
    [X, LegendStrings] = stepTrajectory(Config, Problem, Hull, CM,...
        Panels, T, P, GradT, GradP, X, Step,...
        TrajectoryFigure, LegendStrings);
    Results = [Results; table(X)]; %#ok<AGROW>
    if Config.Trajectory.ReverseTurn && Step == TurnStep
        [T, P, GradT, GradP] = mirrorInterpolants(T, P, GradT, GradP);
    end
end
Results.Properties.UserData.Computer = computer;
if Config.Display.PlotTrajectory && Config.Display.SavePNG
    saveas(gcf, [Config.Display.OutDir, '/Trajectory.png']);
end
end

function [ Config ] = init(Config)
%% Initialize.
addpath('Display', 'Geometry', 'PDE', 'NLP');
if Config.Display.SavePNG && ~exist(Config.Display.OutDir, 'dir')
    mkdir(Config.Display.OutDir)
end
if ~strcmp(Config.PDE.Solver, 'PDETool')
    Config.PDE.PDETool = [];
end
if ~isfield(Config.Display, 'DisplayConfig') ||...
        Config.Display.DisplayConfig
    displayStruct(Config)
end
if strcmp(Config.NLP.Solver, 'ipopt') || strcmp(Config.NLP.Solver, 'worhp')
    if ~(exist(Config.NLP.Solver, 'file') == 3)
        error(['Cannot find ', Config.NLP.Solver, ' MEX-file. ',...
            'Make sure to add it with addpath.'])
    end
    if ~Config.NLP.UseGradients
        Config.NLP.UseGradients = true;
        warning(['Changed Config.NLP.UseGradients to true to enable ',...
            Config.NLP.Solver])
    end
end
end

function [ X, LStrings ] = stepTrajectory(Config,...
    Problem, Hull, CM, Panels, T, P, GradT, GradP, X0, Step,...
    TrajectoryFigure, LStrings)
%% STEPTRAJECTORY moves the body through one trajectory step.
%   An optimization problem is solved to minimize the potential energy of
%   the body within a conservative force field, while meeting the no
%   penetration constraints.
T.Points = movePoints(T.Points, X0);
P.Points = movePoints(P.Points, X0);
if Config.NLP.UseGradients
    GradT = moveGradient(GradT, X0);
    GradP = moveGradient(GradP, X0);
end
Problem.objective = @(x) objective(Config, CM, Panels, P, GradP, X0, x);
if strcmp(Config.NLP.Solver, 'ipopt')
    Problem.Custom.ipopt.funcs.objective =  Problem.objective;
    Problem.Custom.ipopt.funcs.gradient = @(x) grad_objective(...
        Config, CM, Panels, P, GradP, X0, x);
end
if strcmp(Config.NLP.Solver, 'ga')
    Problem.fitnessfcn = Problem.objective;
    Problem.nvars = length(X0);
end
if Config.Display.PlotTrajectory
    %% Plot the updated T = T_{Melt} contour.
    figure(TrajectoryFigure)
    plotIsoline(T, Config.PDE.T_Melt, '--', Config.Display.Colors(Step,:));   
    LStrings = [LStrings, ['Step ', int2str(Step), ': T = T_{Melt}']];
    updateTrajectoryFigure(Config, LStrings,...
        [Config.Display.OutDir, 'Step_', int2str(Step), '-1_Field.png'])
end
%% Update the design space for the current body position.
Problem.x0 = X0;
Problem.lb = X0 + Problem.Custom.SearchRegion(1,1:length(X0));
Problem.ub = X0 + Problem.Custom.SearchRegion(2,1:length(X0));
%% Update the nonlinear constraints for the current interpolant.
Problem.nonlcon = @(x) constraints(Config, Hull.Position, T, GradT, x);
if strcmp(Config.NLP.Solver, 'ipopt')
    Problem.Custom.ipopt.funcs.constraints = Problem.nonlcon;
    Problem.Custom.ipopt.options.lb = Problem.lb;
    Problem.Custom.ipopt.options.ub = Problem.ub;
    Problem.Custom.ipopt.funcs.jacobian = @(x) grad_constraints(...
        Hull.Position, GradT, x);
end
%%
if isfield(Config.Display, 'PlotObjective') && Config.Display.PlotObjective
    plotObjective(Problem);
end
%% Solve the optimization problem.
switch Config.NLP.Solver
    case 'ga'
        X = ga(Problem);
    case 'fmincon'
        X = fmincon(Problem);    
    case 'ipopt'
        [X, ~] = ipopt(Problem.x0, Problem.Custom.ipopt.funcs,...
            Problem.Custom.ipopt.options);
    otherwise
        error('Config.NLP.Solver is invalid.')
end
if isfield(Config.Display, 'PlotObjective') && Config.Display.PlotObjective
    title({'Objective Function', ['Trajectory step ', int2str(Step)]})
end
if X == X0
    error('X did not change.')
end
if Config.Display.PlotTrajectory
    %% Plot the body in its new position.
    figure(TrajectoryFigure)
    plotTransformedBodyAndCM(Hull.Position, CM, X,...
        Config.Display.Colors(Step,:))
    LStrings = [LStrings, ['Step ', int2str(Step), ': Hull'],...
        ['Step ', int2str(Step), ': CM']];
    updateTrajectoryFigure(Config, LStrings,...
        [Config.Display.OutDir, 'Step_', int2str(Step), '-2_Body.png'])
end
end

function Problem = setIpoptOptions(Config, Problem, Hull, X)
% Set options for gradients.
Problem.Custom.ipopt.funcs.jacobianstructure = @() ... % ipopt requires that this function take no inputs, hence the "@()".
    sparse(ones(size(Hull.Position, 1), length(X)));
Problem.Custom.ipopt.options.ipopt.hessian_approximation = ...
    'limited-memory';
% Set bounds on nonlinear constraints.
NumberOfConstraints = size(Hull.Position, 1);
Problem.Custom.ipopt.options.cl = -Inf(NumberOfConstraints, 1);
Problem.Custom.ipopt.options.cu = zeros(NumberOfConstraints, 1);
% Set output options.
if ~Config.NLP.Display
    Problem.Custom.ipopt.options.ipopt.print_level = 0;
end
%
display('Note: There does not seem to be a way to suppress the ')
display('message "*** IPOPT DONE ***" from each ipopt call.')
end

function [T, P, GradT, GradP] = mirrorInterpolants(T, P, GradT, GradP)
T.Points(:,1) = -T.Points(:,1);
P.Points(:,1) = -P.Points(:,1);
GradT = mirrorGradient(GradT);
GradP = mirrorGradient(GradP);
function G = mirrorGradient(G)
    if isempty(G)
        return
    end
    for i = 1:length(G)
        G{i}.Points(:,1) = -G{i}.Points(:,1);
        if i == 1 || i == 3 % X and Theta gradients. The x-dependent gradient values must also be reversed.
            G{i}.Values = -G{i}.Values;
        end
    end
end
end