function FitzLabCalibrate;

% this file _could_ be moved to the 'calibration' directory
%  however, at present, there's not much one would want to edit, so let's just keep it here for simplicity

% inits local pathname variables for FitzLabTools

NewStimGlobals;
remotecommglobals;
 
global FitzScriptmodifier_dirname FitzExperFileName FitzInstructionFileName;

FitzScriptmodifier_dirname = [Remote_Comm_dir];

FitzExperFileName = [Remote_Comm_dir 'experimentname.txt'];

FitzInstructionFileName=[Remote_Comm_dir 'instruction.txt'];
