Table = readtable('simpleFixedCylinder_FieldData_t119410.csv');
%%
Table = Table(Table.Points_2 == 0,:);
Table.Velocity = [Table.U_0, Table.U_1];
Table.Position = [Table.Points_0, Table.Points_1];
Table.PressureGradient = [Table.pGrad_0, Table.pGrad_1];
Table.TemperatureGradient = [Table.TGrad_0, Table.TGrad_1];
%%
Table = Table(:,{'Position', 'p', 'T', 'Velocity', 'PressureGradient', 'TemperatureGradient'});
Table.Properties.VariableNames(2:3) = {'Pressure', 'Temperature'};
%%
Table.Temperature = Table.Temperature - 273.15; % Convert from Kelvin to degrees Celsius.
Table.Pressure = Table.Pressure - min(Table.Pressure); %   Normalize pressures
%%
Field = Table;
save('Field.mat', 'Field')