function plotTransformedBodyAndCM( BodyPoints,...
    CenterOfMass, X, Color)
%%PLOTTRANSFORMEDBODYANDCM transforms the body and CM by X and plots them.
plotTransformedBody(BodyPoints, X, Color)
CenterOfMass = movePoints(CenterOfMass, X);
scatter(CenterOfMass(1), CenterOfMass(2), 'MarkerEdgeColor', Color)
end