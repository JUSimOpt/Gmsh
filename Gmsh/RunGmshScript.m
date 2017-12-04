function [status,cmdout] = RunGmshScript(scriptFile,varargin)
% msh = RunGmshScript(scriptFile)
% msh = RunGmshScript(scriptFile,parameters)
% Parameters:
% 'gmshPath',gmshPath
% 'verbose','on'/'off'
% 'gmeshArgs', 'args'  - Optional gmesh command line arguments 
%
% Keep a copy of the executable "gmsh" in the Gmsh folder.
%

%% Input validation
fileExist = @(inFile)(exist(inFile, 'file') == 2);
if  ~fileExist(scriptFile)
    error(['File "',scriptFile,'" does not exist!'])
end

default_gmshPath = fullfile(pwd,'gmsh','gmsh.exe'); %TODO: make platform independent
IP = inputParser;
addParameter(IP,'gmshPath',default_gmshPath)
addParameter(IP,'OutFile',fullfile(pwd,'mesh.msh'));
addParameter(IP,'verbose','off');
addParameter(IP,'gmeshArgs','');
parse(IP,varargin{:});
PR = IP.Results;
gmshPath = PR.gmshPath;
outputFilePath = PR.OutFile;
verbose = PR.verbose;
gmeshArgs = PR.gmeshArgs;
verbose = strcmpi(verbose,'on');
if  ~fileExist(gmshPath)
    error(['Gmsh is not found at the location "',gmshPath,'"!'])
end
%%
command = [gmshPath,' ',gmeshArgs,' -0 -o "',outputFilePath,'" "',scriptFile,'"'];

if verbose
    [status,cmdout] = system(command,'-echo');
else
    [status,cmdout] = system(command,'-echo');
end

end



function dir = UpDir(dir,n)
    for i = 1:n
        dir = fileparts(dir);
    end
end