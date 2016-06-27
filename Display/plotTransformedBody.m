function plotTransformedBody( BodyPoints, X, Color)
%%PLOTTRANSFORMEDBODY transforms the body according to X and plots it.
BodyPoints = movePoints(BodyPoints, X);
if exist('Color', 'var')
    plot(BodyPoints(:,1), BodyPoints(:,2), 'Color', Color)
else
    plot(BodyPoints(:,1), BodyPoints(:,2))
end
end