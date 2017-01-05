function [f1f0,dirpref,oiind,tunewidth,cv,di,sig_ori,blank_rate, max_rate, coeff_var, pref, null, orth, fit, sig_vis]=extract_oridir_indexes(cell,varargin)
% Extract common orientation/direction index values from a cell
%
%  [F1F0,DIRPREF,OI,TUNEWIDTH,CV,DI,SIG_ORI,BLANK_RATE,MAX_RATE,
%     COEFFVAR] = EXTRACT_ORIDIR_INDEXES(CELL)
%
%  Returns several common index values from a CELL that is an
%  object of type MEASUREDDATA.
%
%  Returns:
%    F1F0 -- the F1/(F0+F1) ratio
%    DIRPREF -- the direction preference angle
%    OI -- the orientation index from Li/Van Hooser et al. 2008
%    TUNEWIDTH -- Half width at half height orientation fit
%    CV -- the circular variance
%    DI -- the direction index from Li/Van Hooser et al. 2008
%    SIG_ORI -- the P value that determines if there is a significant
%           orientation signal to be fit
%    BLANK_RATE -- the firing rate during the "blank" stimulus
%    MAX_RATE -- The firing rate to the "best" stimulus
%    COEFF_VAR -- the coefficient of variation to the best stimulus
%    PREF -- the response to the preferred direction (fit), blank subtracted
%    NULL -- the response to the opposite direction (fit), blank subtracted
%    ORTH -- the response to the orthogonal orientation (fit), blank subtracted
%    FIT -- the fitted response, blank-subtracted
%    SIG_VIS - The P value that determines if there is a significant visual
%           response
%
%  This function's beheavior may be modified by name/value pairs:
%  Parameters (default)     | Description
%  -----------------------------------------------------------
%  TestType ('OT')          | The test type 
%  ColorType ('Ach')        | The color type

TestType = 'OT';
ColorType = 'Ach';

assign(varargin{:});

A1 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' visual response p'],'','');
A2 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Carandini Fit'],'','');
A3 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Carandini Fit'],'','');
A4 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Response struct'],'','');

A5 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Tuning width'],'','');
A6 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Tuning width'],'','');
A7 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Circular variance'],'','');
A8 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Circular variance'],'','');
A9 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Orientation index'],'','');
A10 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Orientation index'],'','');
A11 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Fit Direction index blr'],'','');
A12 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Fit Direction index blr'],'','');
A13 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' vec varies p'],'','');
A14 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' vec varies p'],'','');
A15 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Blank Response'],'','');
A16 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Max Response'],'','');
A17 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Max Response'],'','');

A18 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Response struct'],'','');
A19 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Response struct'],'','');

A20 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' Carandini Fit'],'','');
A21 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' Carandini Fit'],'','');

A22 = findassociate(cell,['SP F0 ' ColorType ' ' TestType ' visual response p'],'','');
A23 = findassociate(cell,['SP F1 ' ColorType ' ' TestType ' visual response p'],'','');



f1f0 = []; dirpref = []; oiind = []; tunewidth = []; cv = []; di =[];
sig_ori = []; blank_rate = []; pref = []; null = []; orth = [];
fit = []; coeff_var = [];
max_rate = []; sig_vis = [];
if ~isempty(A1)&~isempty(A2)&~isempty(A3)&~isempty(A4),
    if ~isempty(A15),
        blank_rate = A15.data(1);
    else,
        blank_rate = 0;
    end;

    if A1.data<1, % start off w/ no filter
        [mxf0,indf0]=max(A2.data(2,:)-A4.data.spont(1));
        [mxf1,indf1]=max(A3.data(2,:));
        if mxf0>mxf1,
            ind = indf0;
            oiind=fit2fitoi(A2.data, 0);
            oiind=A9.data;
            tunewidth=A5.data;
            cv = A7.data;
            if ~isempty(A11), % might not have dir info if only ori run
	            di = A11.data;
            else,
                    di = NaN;
            end;
            sig_ori = A13.data;
            max_rate = A16.data(1);
            [mxrate,coeff_var] = neural_maxrate_variability(A18.data);
            pref = fit2pref(A20.data) - blank_rate;
            null = fit2null(A20.data) - blank_rate;
            orth = fit2orth(A20.data) - blank_rate;
            fit = A20.data - blank_rate;
            dirpref = A2.data(1,ind);
            sig_vis = A22.data(1);
        else,
            ind = indf1;
            oiind=fit2fitoi(A3.data, 0);
            oiind=A10.data;
            tunewidth = A6.data;
            cv = A8.data;
            if ~isempty(A12), % might not have dir info if only ori run
                di = A12.data;
            else,
                di = NaN;
            end;
            sig_ori = A14.data;
            max_rate = A17.data(1);            
            [mxrate,coeff_var] = neural_maxrate_variability(A19.data);            
            pref = fit2pref(A21.data);
            null = fit2null(A21.data);
            orth = fit2orth(A21.data);
            fit = A21.data - blank_rate;
            dirpref = A3.data(1,ind);
            sig_vis = A23.data(1);            
        end;
        f1f0 = A3.data(2,ind)./(A2.data(2,ind)+A3.data(2,ind));
    end;
    if A1.data>0.05, tunewidth = 90; end;
end;

