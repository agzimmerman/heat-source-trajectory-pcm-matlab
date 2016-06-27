function plotPanels(Panels)
%%PLOTPANELS plots the panels of the hull and unit normals.
hold on
scatter(Panels.Center(:,1), Panels.Center(:,2), 'r')
quiver(Panels.Center(:,1), Panels.Center(:,2), Panels.UnitNormal(:,1),...
    Panels.UnitNormal(:,2))
xlabel('x')
ylabel('y')
legend({'Hull', 'Panel Centers', 'Panel Unit Normals'});
axis equal
hold off
end