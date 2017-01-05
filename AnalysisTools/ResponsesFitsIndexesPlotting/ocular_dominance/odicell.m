function [odi,CL,IL] = odicell(cell, prefix)
% ODICELL - Return ocular dominance index for a recorded cell
%
%  [ODI,CL,IL] = ODICELL(CELL, PREFIX)
%
%  Returns ODI index of a cell that has the following associates:
%
%    [PREFIX] 'CONT Ach OT Max Response'
%    [PREFIX] 'CONT Ach OT Blank Response'
%    [PREFIX] 'IPSI Ach OT Max Response'
%    [PREFIX] 'IPSI Ach OT Blank Response'
%     
%     (e.g., PREFIX='TP ' for 2-photon experiments)
%  
%    The response to stimulation of each eye is calculated as the maximum response
%    minus the blank response. If this response is less than 0, it is rectified so that
%    it is 0.
%
%    The index is:   (CL - IL) / (CL + IL)
%
%    If the associates are not present, NaN is returned
%
%    Note that this function makes no determination as to whether or not the responses
%    are significant.

if prefix(end)~=' ',  % be nice and add a space; this should be unambigiously good
	prefix(end+1) = ' ';
end;

A=findassociate(cell,[prefix 'CONT Ach OT Max Response'],'','');
B=findassociate(cell,[prefix 'CONT Ach OT Blank Response'],'','');
C=findassociate(cell,[prefix 'IPSI Ach OT Max Response'],'','');
D=findassociate(cell,[prefix 'IPSI Ach OT Blank Response'],'','');

odi = NaN;
CL = NaN;
IL = NaN;
 
if ~isempty(A) & ~isempty(B) & ~isempty(C) & ~isempty(D),
	CL = rectify(A.data - B.data(1));
	IL = rectify(C.data - D.data(1));
	odi = (CL-IL)/(CL+IL);
end;


