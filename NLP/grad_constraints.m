function [ JC ] = grad_constraints( Points, GradT, X )
%% CONSTRAINTSGRADIENT is the gradient of the constraints function.
% @todo: Verify Gradients: http://de.mathworks.com/help/optim/ug/checking-validity-of-gradients-or-jacobians.html
Points = movePoints(Points, X);
if length(X) == 3
    JC = -sparse([GradT{1}(Points), GradT{2}(Points), GradT{3}(Points)]);
elseif length(X) == 2
    JC = -sparse([GradT{1}(Points), GradT{2}(Points)]);
end
end