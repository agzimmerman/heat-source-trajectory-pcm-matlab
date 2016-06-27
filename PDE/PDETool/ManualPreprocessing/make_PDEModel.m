% Data was manually exported out of pdetool and then structured.
load('PDEModel_struct.mat')
PDEModel = createpde;
geometryFromEdges(PDEModel, PDEModel_struct.Decomposed.Geometry);
save('PDEModel.mat', 'PDEModel')