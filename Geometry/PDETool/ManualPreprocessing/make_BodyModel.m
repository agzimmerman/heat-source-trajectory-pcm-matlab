% This was exported from the pdetool after deleting the outer boundary.
load('BodyModel_struct.mat')
BodyModel = createpde();
geometryFromEdges(BodyModel, BodyModel_struct.Decomposed.Geometry);
save('BodyModel.mat', 'BodyModel')