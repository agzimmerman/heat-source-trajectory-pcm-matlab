function [ GradI] = moveGradient(GradI, X)
for i = 1:length(X)
    GradI{i}.Points = movePoints(GradI{i}.Points, X);
end
if length(X) < 3 || X(3) ~= 0
    return
end
theta = X(3);
R = [cos(theta) sin(theta); -sin(theta) cos(theta)]; % Positive theta induces counter-clockwise rotation.
V = [GradI{1}.Values, GradI{2}.Values];
V = V*R;
for i = 1:2
    GradI{i}.Values = V(:,i);
end
GradI{3}.Values = computeThetaGradient(GradI{1}.Points,...
    [GradI{1}.Values, GradI{2}.Values]);
end