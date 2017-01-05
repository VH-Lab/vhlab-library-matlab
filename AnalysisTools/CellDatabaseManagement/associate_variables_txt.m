function associate_variables_txt
%  ASSOCIATE_VARIABLES_TXT - Help file for the associate variable text file
%  
%  The 'associate_variables.txt' file is an optional file that 
%  contains a list of associate variables to add to all cells (with the
%  function ADD_ASSOCIATE_VARIABLES.
%
%  The file should have the following format:
%    The first row should be:
%  type<tab>owner<tab>data<tab>desc<return>
%    The next rows should have the associate type, owner, data, 
%  and description in tab-delimited form.  For example:
%  Projector Scale<tab>associate_variables<tab>1.8<tab>Projector scale in microns per pixel<return>
%  
%
%  See also: LOADSTRUCTARRAY, ADD_ASSOCIATE_VARIABLES
