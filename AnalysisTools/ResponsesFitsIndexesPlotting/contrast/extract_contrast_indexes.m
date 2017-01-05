function [f1f0,rmg,c50,si,sig_ct,response_curve,blank] = extract_contrast_indexes(cell)
% Extract common contrast index values from a cell
%
%  [F1F0,RGM,C50,SI,SIG_CT] = EXTRACT_CONTRAST_INDEXES(CELL)
%
%  Returns several common index values from a CELL that is an
%  object of type MEASUREDDATA.
%
%  Returns:
%    F1F0 -- the F1/(F0+F1) ratio
%    RGM -- the relative maximum gain
%    C50 -- contrast at half maximum rate
%    SI -- saturation index
%    SIG_CT - the p value that determines if there is a significant response



A0_1 = findassociate(cell,'SP F0 Ach CT visual response p','','');
A1_1 = findassociate(cell,'SP F1 Ach CT visual response p','','');
A0_2 = findassociate(cell,'SP F0 Ach CT NKS Fit','','');
A1_2 = findassociate(cell,'SP F1 Ach CT NKS Fit','','');
A0_3 = findassociate(cell,'SP F0 Ach CT Response curve','','');
A1_3 = findassociate(cell,'SP F1 Ach CT Response curve','','');
A0_4 = findassociate(cell,'SP F0 Ach CT Blank Response','','');
A1_4 = findassociate(cell,'SP F1 Ach CT Blank Response','','');


f1f0 = [];
rmg = [];
c50 = [];
si = [];
sig_ct = [];
response_curve = [];
blank = [];


if ~isempty(A0_1)&~isempty(A0_2)
    if A0_1.data<1, % start off w/ no filter
        [mxf0,indf0]=max(A0_3.data(2,:));
        [mxf1,indf1]=max(A1_3.data(2,:));
        if mxf0>mxf1, % F0
		ind = indf0;
		sig_ct = A0_1.data(1);
		si = contrastfit2saturationindex(A0_2.data(1,:),real(A0_2.data(2,:)));
		rmg = contrastfit2relativemaximumgain(A0_2.data(1,:),real(A0_2.data(2,:)));
		c50 = contrastfit2c50(A0_2.data(1,:),real(A0_2.data(2,:)));
		response_curve = A0_3.data;
		blank = A0_4.data;
        else,
		ind = indf1;
		sig_ct = A1_1.data(1);
		si = contrastfit2saturationindex(A1_2.data(1,:),real(A1_2.data(2,:)));
		rmg = contrastfit2relativemaximumgain(A1_2.data(1,:),real(A1_2.data(2,:)));
		c50 = contrastfit2c50(A1_2.data(1,:),real(A1_2.data(2,:)));
		response_curve = A1_3.data;
		blank = A1_4.data;
        end;
        f1f0 = A1_3.data(2,ind)./(A1_3.data(2,ind)+A0_3.data(2,ind));
    end;
end;

