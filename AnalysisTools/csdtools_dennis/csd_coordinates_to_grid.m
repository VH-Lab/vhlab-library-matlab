function grid = coordinates_to_grid(x,y,rows)
%coordinates_to_grid
%This function resolves the discrepancy between the convention that grids
%are ordered and also how subplots are ordered.
%
%Example:
%grid = coordinates_to_grid(15,20,15)

grid = (x-1)*rows+y;

end

%Take note that x refers to columns and y refers to rows.