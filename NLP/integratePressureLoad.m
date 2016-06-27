function [ L ] = integratePressureLoad(Pressure, Panels, X)
ReferencePanels = Panels;
assert(size(X, 2) == 2) % @todo: Rotation not yet supported. Panels.UnitNormal and Panels.DeltaP must be rotated.
Panels.Center = movePoints(ReferencePanels.Center, X);
L = integrateOverPanels(Panels, @(panels) pressureLoads(Pressure, panels));
function [ P ] = pressureLoads(Pressure, Panels)
    P = bsxfun(@times, Pressure(Panels.Center), -Panels.UnitNormal);
end
end