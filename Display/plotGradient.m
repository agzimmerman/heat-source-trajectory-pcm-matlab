function plotGradient( GradientInterpolant )
%PLOTGRADIENT makes a quiver plot of the gradient. Summary of this function goes here
%   GradientInterpolant is a cell array of scatteredInterpolants, one for
%   each dimension of the gradient.
figure('Name', 'Gradient')
X = GradientInterpolant{1}.Points(:,1);
Y = GradientInterpolant{1}.Points(:,2);
GradI = GradientInterpolant;
quiver(X, Y, GradI{1}(X, Y), GradI{2}(X, Y))
axis equal
xlabel('x')
ylabel('y')
end