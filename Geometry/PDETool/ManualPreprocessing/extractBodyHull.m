load('BodyModel.mat')
% Extract reference points from the body.
% We only need the convex hull and the center of mass.
generateMesh(BodyModel, 'Hmax', Config.PDE.MaxElementSize);
BodyPoints = BodyModel.Mesh.Nodes;
Position = BodyPoints(:,convhull(BodyPoints(1,:),BodyPoints(2,:)))'; % These would otherwise be repeatedly transposed when evaluating nonlinear constraints.
Hull = table(Position); 
save('Hull.mat', 'Hull');