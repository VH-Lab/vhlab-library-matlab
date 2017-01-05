function p = coordframe_imaginary_getpoint(cf)

prompt = {'X position:','Y position'};
defaultanswer = {'0','0'};
answer = inputdlg(prompt,'Enter point:',1,defaultanswer);
if isempty(answer), p = []; else, p = [eval(answer{1}) eval(answer{2})]; end;
