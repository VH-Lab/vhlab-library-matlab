function LFP2 = csdDownsampling(LFP,channel,t1,t2)
%downsampling
%Downsamples a dataset by taking every 83rd data point.

p1 = t1*25000;  %will need to add 1 to 't1*25000' if t1 = 0 sinces indices in MATLAB do not start at 0 but rather 1.
p2 = t2*25000;

temp = LFP(:,channel);

unfiltered_data = temp(round(p1):round(p2));

LFP2 = unfiltered_data(1:83:end); %we are down-sampling here because the computer doesn't have enough memory to store the 'whole' matrix

end


%IF THE 83 VALUE IS CHANGED, WILL NEED TO CHANGE VALUES IN PLOTCSD AND
%EXTREME_CSD FUNCTIONS.
%IT WOULD BE HELPFUL TO IMPLEMENT A FUNCTION THAT TRACKS THE CHANGES OF THE
%DOWNSAMPLING (83) VALUE AND MAKE ACCORDING CHANGES

%Professor Van Hooser's Suggested Filtration via ChebyChev
%[b_cb,a_cb] = cheby1(4,0.5,[100 300]/(0.5 * 25000),'bandpass');
%filtered_data = filtfilt(b_cb,a_cb,double(unfiltered_data));
%downsampled_filtered_data = filtered_data(1:83:end);

%Sgolayfilt Algoritm
%filtered_data = sgolayfilt(double(LFP),1,417)

%To do list:
%1. Filter and non-filter functionality