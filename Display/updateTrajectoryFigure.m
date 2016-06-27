function updateTrajectoryFigure(Config, LegendStrings, PNGName)
%%UPDATETRAJECTORYFIGURE is encapsulated here for frequent calling when
%%visualizing the trajectory.
if ~exist('LegendStrings', 'var')
    LegendStrings = {};
end
switch Config.PDE.Solver %@todo: Don't  hard code these limits.
    case 'PDETool' 
        xlim([-0.5 0.5])
        ylim([-0.75 1.25])
    case 'CoMeTFoam'
        xlim([-0.04 0.04])
        ylim([-0.07 0.03])
end
legend(LegendStrings, 'Location', 'NortheastOutside');
drawnow
if Config.Display.SavePNG
    saveas(gcf, PNGName);
end
end