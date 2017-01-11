function vhlab_mltbx_matlibraries_Init
% VHLAB_MLTBX_MATLIBRARIES_INIT - Initialize the vhlab_mltbx_matlibraries library
%
%  VHLAB_MLTBX_MATLIBRARIES_INIT 
%
%  Initializes the vhlab_mltbx_matlibraries library/toolbox by initializing objects
%  and calling initialization procedures of subdirectories.

  % AnalysisTools subdirectory
measureddata([1 2],'',''); 
spikedata([1 2],'','');
windowdiscriminator('default');
cksmultipleunit([1 2],'','',[1.5],[]);
wdcluster('default');
multiextractor('default');
dotdiscriminator('default');


  % Legacy code
FitzLabInit;



