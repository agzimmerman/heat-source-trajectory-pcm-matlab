function displayStruct( Struct )
%DISPLAYSTRUCT displays Struct and recursively its fields that are structs.
%
%   DISPLAYSTRUCT(Struct) displays Struct and then recursively calls
%       DISPLAYSTRUCT(Field) on each Field that is a struct. It returns no
%       output.
Name = inputname(1);
recursive_displayStruct(Struct, Name);
end

function recursive_displayStruct(Struct, Name)
display([Name, '.'])
disp(Struct)
fprintf('\n')
FieldNames = fieldnames(Struct);
for FieldNameCell = FieldNames'
    FieldName = FieldNameCell{1};
    Field = Struct.(FieldName);
    if isstruct(Field)
        recursive_displayStruct(Field, [Name, '.', FieldName])
    end
end
end