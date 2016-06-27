%% Examples of using dimice.m

%% Run regression tests
test
%% Run regression tests with plotting trajectories
test('Default', 'Plot')

%%

%% Run with default configuration.
dimice
%% Run with a nose temperature differential (to turn).
load('DefaultConfig.mat')
Config.PDE.PDETool.BC.T_LeftNose = Config.PDE.PDETool.BC.T_Wall;
dimice(Config)
%% Also turn back the other direction.
load('DefaultConfig.mat')
Config.PDE.PDETool.BC.T_LeftNose = Config.PDE.PDETool.BC.T_Wall;
Config.Trajectory.ReverseTurn = true;
dimice(Config)
%% Run with a non-vertical force vector.
load('DefaultConfig.mat')
Config.NLP.Objective.ConservativeForces = [-10 -5];
dimice(Config)
%% Specify the center of mass instead of calculating centroid.
load('DefaultConfig.mat')
Config.NLP.Objective.CenterOfMass = [0 0.3];
Config.PDE.PDETool.BC.T_LeftNose = Config.PDE.PDETool.BC.T_Wall;
Config.Trajectory.ReverseTurn = true;
dimice(Config);
%% Provide gradients to fmincon.
load('DefaultConfig.mat')
Config.PDE.PDETool.BC.T_LeftNose = Config.PDE.PDETool.BC.T_Wall;
Config.NLP.UseGradients = true;
Config.Display.PlotAll = false;
Config.Trajectory.ReverseTurn = true;
dimice(Config)

%%

%% Save images from figures.
load('DefaultConfig.mat')
Config.Display.SavePNG = true;
dimice(Config)

%%

%% Run with ipopt instead of fmincon.
% Note: ipopt refuses to reverse the turn, so fmincon is doing something different.
if any(3:6 == exist('ipopt', 'file')) % see "doc exist" for why "3:6" was chosen.
    load('DefaultConfig.mat')
    Config.PDE.PDETool.BC.T_LeftNose = Config.PDE.PDETool.BC.T_Wall;
    Config.Trajectory.ReverseTurn = true;
    Config.NLP.UseGradients = true;
    Config.NLP.Solver = 'ipopt';
    dimice(Config)
else
    warning('Skipping example because ipopt is not in path.')
end

%%

%% Use a geometry and solution from CoMeTFoam
load('DefaultConfig.mat')
Config.Geometry.HullPath = 'CoMeTFoam/Hull.mat';
Config.PDE.Solver = 'CoMeTFoam';
Config.Trajectory.EnableRotation = false;
dimice(Config)
%% Use general surface integration function to integrate pressure loads.
load('DefaultConfig.mat')
Config.Geometry.HullPath = 'CoMeTFoam/Hull.mat';
Config.PDE.Solver = 'CoMeTFoam'; % CoMeTFoam is the only option that will provide a pressure field.
Config.NLP.Objective.PressureLoad = true;
Config.NLP.Objective.ConservativeForces = [0 0]; % Disable body force so the probe will float.
Config.Trajectory.EnableRotation = false;
dimice(Config)
%% Provide gradients when integrating pressure.
load('DefaultConfig.mat')
Config.Geometry.HullPath = 'CoMeTFoam/Hull.mat';
Config.PDE.Solver = 'CoMeTFoam'; % CoMeTFoam is the only option that will provide a pressure field.
Config.NLP.Objective.PressureLoad = true;
Config.NLP.Objective.ConservativeForces = [0 0]; % Disable body force so the probe will float.
Config.Trajectory.EnableRotation = false;
Config.NLP.UseGradients = true;
dimice(Config)

%%

%% Visualize the objective function (ignore nonlinear constraints)
load('DefaultConfig.mat')
Config.Display.PlotObjective = true;
dimice(Config)
%%

%% Use a genetic algorithm (GA).
load('DefaultConfig.mat')
Config.PDE.PDETool.BC.T_LeftNose = Config.PDE.PDETool.BC.T_Wall;
Config.Trajectory.ReverseTurn = true;
Config.NLP.Solver = 'ga';
Config.Display.PlotAll = false;
dimice(Config)
%% Visualize the objective function with GA.
load('DefaultConfig.mat')
Config.NLP.Solver = 'ga';
Config.NLP.PlotFcn = {@ga_scatterPopulation};
Config.Display.PlotAll = false;
dimice(Config)