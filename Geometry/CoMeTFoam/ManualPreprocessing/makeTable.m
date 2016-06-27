Table = readtable('InnerWall_t12000.csv');
Table = Table(Table.Points_2 == 0,:);
Table.Position = [Table.Points_0, Table.Points_1];
Table = Table(:,{'Position'}); % Throw away non-geometric data
%%
Table = [Table; Table(1,:)]; % Close the body by repeating the first point.
%%
Hull = Table;
save('Hull.mat', 'Hull')
%%
Hull = Hull([13 37 61 85 13],:);
save('FourPoint_Hull.mat', 'Hull')