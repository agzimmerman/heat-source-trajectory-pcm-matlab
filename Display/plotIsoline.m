function [ LineHandle ] = plotIsoline( Interpolant, Isovalue,...
    LineStyle, LineColor)
%PLOTISOLINE plots an isoline of the Interpolant.
%
%   This is similar to 
%
%       FCONTOUR(@(x,y) Interpolant(x,y), 'LineStyle', '--',...
%           'LineColor', LineColor, 'LevelList', [T_Melt T_Melt])
%
%   FCONTOUR makes a contour plot easily, but the legend entry is incorrect
%   when only an isoline is needed.
X = unique(Interpolant.Points(:,1));
Y = unique(Interpolant.Points(:,2));
[XGrid, YGrid] = meshgrid(X, Y);
V = Interpolant(XGrid, YGrid);
C = contourc(X, Y, V, [Isovalue Isovalue]);
if exist('LineColor', 'var')
    LineHandle = plot(C(1,2:end), C(2,2:end), 'LineStyle', LineStyle,...
        'Color', LineColor);
elseif exist('LineStyle', 'var') % Combined style and color, e.g. '-k' for solid black line.
    LineHandle = plot(C(1,2:end), C(2,2:end), LineStyle);
else    
    LineHandle = plot(C(1,2:end), C(2,2:end));
end
end