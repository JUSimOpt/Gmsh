function msh = MshRead(inFile,varargin)
% msh = MshRead(inFile)
% msh = MshRead(inFile,parameters)
% Parameters:
%
% Keep a copy of the executable "gmsh" in the Gmsh folder.
%

%% Input validation
fileExist = @(inFile)(exist(inFile, 'file') == 2);
if  ~fileExist(inFile)
    error(['File "',inFile,'" does not exist!'])
end
IP = inputParser;
parse(IP,varargin{:});
PR = IP.Results;

%% Open File


msh = 0;
end



function dir = UpDir(dir,n)
    for i = 1:n
        dir = fileparts(dir);
    end
end