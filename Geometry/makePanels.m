function [ Panels ] = makePanels( Config, Hull )
%MAKEPANELS tabulates panels corresponding to the points in Hull.
%   A panel is defined as a line connecting two adjacted points.
%   This calculates the centers and out of body unit normals of each panel.

%%
Centroid = integrateCentroid(Hull.Position);
%%
Center = (Hull.Position(2:end,:) + Hull.Position(1:end-1,:))/2;
DeltaP = Hull.Position(2:end,:) - Hull.Position(1:end-1,:);
Normal_One = [-DeltaP(:,2), DeltaP(:,1)];
Normal_Two = [DeltaP(:,2), -DeltaP(:,1)];
Normal_OutOfBody = NaN(size(Normal_One, 1), 2);
% Crudely base the "out of body" normal on the position of the panel
% relative to the body centroid. More complex geometries will require a
% better algorithm, which will probably require some information from the
% computational grid.
for i = 1:length(Normal_OutOfBody) % This is done in a loop to preserve the order of points.
    Normal_OutOfBody(i,:) = Normal_One(i,:);
    if dot(Normal_Two(i,:), Center(i,:) - Centroid) >...
            dot(Normal_One(i,:), Center(i,:) - Centroid)
        Normal_OutOfBody(i,:) = Normal_Two(i,:);
    end
end
Normal = Normal_OutOfBody;
UnitNormal = Normal./repmat(sqrt(Normal(:,1).^2 + Normal(:,2).^2), 1, 2);
Length = sqrt(DeltaP(:,1).^2 + DeltaP(:,2).^2);
Panels = table(Center, DeltaP, UnitNormal, Length);
%%
if Config.Display.PlotAll
    figure('Name', 'Hull Panels')
    plot(Hull.Position(:,1), Hull.Position(:,2));
    hold on
    plotPanels(Panels)
    hold off
end
end