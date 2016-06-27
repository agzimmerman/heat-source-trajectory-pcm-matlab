function [ State ] = ga_scatterPopulation( Options, State, Flag )
% This is a custom function for PlotFcn (in the Problem.options struct)
% The interface is as strictly required by PlotFcn.
if strcmp(Flag, 'init')
    xlabel('\DeltaX')
    ylabel('\DeltaY')
    zlabel('\Delta\theta')
    C = colorbar;
    C.Label.String = 'Fitness Function Value';
    view([-40 30])
    grid on
end
scatter3(State.Population(:,1), State.Population(:,2),...
    State.Population(:,3), [], State.Score);
end