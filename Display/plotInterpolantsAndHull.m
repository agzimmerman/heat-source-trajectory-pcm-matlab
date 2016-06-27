function plotInterpolantsAndHull(Config, Hull, T, P, GradT, GradP)
plotInterpolantAndHull(Config, Hull, T, 'Temperature')
plotInterpolantAndHull(Config, Hull, P, 'Pressure')
for i = 1:length(GradT)
    plotInterpolantAndHull(Config, Hull, GradT{i},...
        ['Temperature Gradient(', int2str(i), ')'])
end
for i = 1:length(GradP)
    plotInterpolantAndHull(Config, Hull, GradP{i},...
        ['Pressure Gradient(', int2str(i), ')'])
end
function plotInterpolantAndHull(Config, Hull, I, Name)
    figure('Name', [Name, ' Interpolant'])
    plotScatteredInterpolant(I);
    LStrings = {[Name, ' Interpolant']};
    hold on
    if strcmp(Name, 'T')
        plotIsoline(I, Config.PDE.T_Melt, '--', [0 0 0]);
        LStrings = [LStrings, 'T = T_{Melt}'];
    end
    plot3(Hull.Position(:,1), Hull.Position(:,2),... % Use plot3 to keep the hull line in front of the interpolant.
        zeros(size(Hull.Position, 1), 1) + max(I.Values) + 1, '-k');
    LStrings = [LStrings, 'Hull'];
    legend(LStrings)
    xlabel('x')
    ylabel('y')
    set(gca, 'DataAspectRatio', [diff(get(gca, 'XLim')) ... % "axis equal" doesn't work because of the usage of plot3 above.
        diff(get(gca, 'XLim')) diff(get(gca, 'ZLim'))])
    %%
    hold off    
end
end