function [IMsnew] = filterintrinsicdata(IMs,varargin);

% FILTERINTRINSICDATA - Apply common filters to intrinsic data
%
%  IMnew = FILTERINTRINSICDATA(IM,...)
%
%  Accepts a 3D matrix of images and applies filters to each
%  2D image IM(:,:,i).  The filter arguments are provided as 
%  command/parameter pairs as follows:
%
% NAME:      |  MEANING:      | VALUE:
%   'CONV'   | Subtract       | matrix to convolve (e.g.,
%            |   convolution  | ones(100)/sum(sum(ones(100))))
%   'MEDFILT'| Median filter  | X and Y filter size (eg [5 5])
%   'BGSUB'  | Background     | Image index values to subtract
%            |   subtraction  | 
%
%  For example, to perform only a median filter, use
% 
%   IMnew = FILTERINTRINSICDATA(IM,'medfilt',[5 5]);
%
%  Or, to apply both a median filter and background
%    subtraction, use
%
%   IMnew = FILTERINTRINSICDATA(IM,'medfilt',[5 5],...
%      'BGSUB',mybgindices);
%
%  The filters will be applied in the order they are 
%  specified in the argument list.

for i=1:size(IMs,3),
	im0 = IMs(:,:,i);
	for j=1:2:length(varargin),
		switch varargin{j},
			case 'conv',
				im0 = im0-conv2(im0,varargin{j+1},'same');
			case 'medfilt',
				im0 = medfilt2(im0,varargin{j+1});
			case 'bgsub',
				im0 = im0 - mean(im0(varargin{j+1}));
			otherwise,
				error(['Unknown filter request ' varargin{j} '.']);
		end;
	end;
	IMs(:,:,i) = im0;
end;

IMsnew = IMs;
