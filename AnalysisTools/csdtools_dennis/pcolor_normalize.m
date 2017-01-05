function normalized_matrix = pcolor_normalize(matrix)
%pcolor_normalize
%To add a row and column of zeros of the ends of the matrix to be used in 'pcolor'
%so that the last row and column of the relevant matrix does not get deleted.


x = size(matrix);
row = x(1);
col = x(2);

matrix(row+1,:) = zeros(1,col);

for i = 1:row
    matrix(i,col+1) = 0;
end

normalized_matrix = matrix;

end
