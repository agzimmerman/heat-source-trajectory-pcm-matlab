function plotObjective( Problem, Resolution )
%PLOTOBJECTIVE visualizes the unconstrained objective function.
%   Problem is the same struct provided to the nonlinear solver.
%   Resolution is a 1xN double, where N is the number of design variables.
%   By default each element of Resolution equals 10.
NX = length(Problem.x0);
assert(NX <= 3);
if ~exist('Resolution', 'var')
    Resolution = zeros(1, NX) + 10;
end
if NX > 1 && length(Resolution) == 1
    Resolution = zeros(1, NX) + Resolution;
end
assert(length(Resolution) == NX)
X = cell(1, NX);
for i = 1:length(X)
    X{i} = linspace(Problem.lb(i), Problem.ub(i), Resolution(i));
end
figure('Name', ['Objective Function Sample with Resolution N = [',...
    sprintf('%g ', Resolution), ']'])
hold on
xlabel('x_1')
if NX > 1
    ylabel('x_2')
    if NX > 2
        zlabel('x_3')
    end
end
grid on
switch NX
    case 1
        warning('case 1 has not been tested yet.')
        X = X{1};
        scatter(X, objective(X));
    case 2
        warning('case 2 has not been tested yet.')
        [X1, X2] = meshgrid(X{1}, X{2});
        X = [reshape(X1, numel(X1), 1), reshape(X2, numel(X2), 1)];
        scatter(X(:,1), X2(:,2), [], Problem.objective(X), 'filled');
    case 3
        [X1, X2, X3] = meshgrid(X{1}, X{2}, X{3});
        X = [reshape(X1, numel(X1), 1), reshape(X2, numel(X2), 1),...
            reshape(X3, numel(X3), 1)];
        scatter3(X(:,1), X(:,2), X(:,3), [], Problem.objective(X),...
            'filled');
end
view([45 -45])
CHandle = colorbar;
CHandle.Label.String = 'F (X)';
hold off
end