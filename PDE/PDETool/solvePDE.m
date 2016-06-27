function [ Field ] = solvePDE(Config)
%% Create and solve the PDE Model.
% Load geometry PDE model that was created with pdetool.
load('PDE/PDETool/ManualPreprocessing/PDEModel.mat')
% Specify coefficients for the elliptic PDE.
specifyCoefficients(PDEModel, 'm', 0, 'd', 0, 'c', 1, 'a', 0, 'f', 0);
% Apply the PDE Dirichlet boundary conditions.
applyBoundaryCondition(PDEModel, 'edge', 3:6, 'r',...
    Config.PDE.PDETool.BC.T_OuterBoundary);
applyBoundaryCondition(PDEModel, 'edge', [1 2 7], 'r',...
    Config.PDE.PDETool.BC.T_Wall);
applyBoundaryCondition(PDEModel, 'edge', 8, 'r',...
    Config.PDE.PDETool.BC.T_LeftNose);
applyBoundaryCondition(PDEModel, 'edge', 9, 'r',...
    Config.PDE.PDETool.BC.T_RightNose);
% Make the mesh.
generateMesh(PDEModel, 'Hmax', Config.PDE.PDETool.MaxElementSize);
% Solve the PDE.
Results = solvepde(PDEModel);
if Config.Display.PlotAll
    % Plot the solution with a contour line marking the melt interface.
    figure('Name', 'PDETool Solution')
    pdeplot(PDEModel, 'xydata', Results.NodalSolution,...
        'contour', 'on', 'levels', [Config.PDE.T_Melt ...
        Config.PDE.T_Melt]);
    axis equal
    xlabel('x')
    ylabel('y')
    title({'Temperature Field', 'with contour line for T = T_{melt}'})
    if Config.Display.SavePNG
        saveas(gcf, [Config.Display.OutDir, '/PDESolution.png'])
    end
end
%% Return the solution as a table of scattered data.
Field = table([PDEModel.Mesh.Nodes(1,:)', PDEModel.Mesh.Nodes(2,:)'],...
    Results.NodalSolution, [Results.XGradients, Results.YGradients]);
Field.Properties.VariableNames = {'Position', 'Temperature',...
    'TemperatureGradient'};
end