function plotScatteredInterpolant( Interpolant )
%%PLOTSCATTEREDINTERPOLANT plots a dense sample of a scattered interpolant.
X = sort(unique(Interpolant.Points(:,1)));
Y = sort(unique(Interpolant.Points(:,2)));
[XGrid, YGrid] = meshgrid(X, Y);
I = Interpolant(XGrid, YGrid);
Handle = surf(XGrid, YGrid, I);
set(Handle, 'Facecolor', 'interp', 'Edgecolor', 'none')
view([0 90])
CHandle = colorbar();
CHandle.Label.String = 'Interpolant Value';
end