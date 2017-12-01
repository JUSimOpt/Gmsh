function msh = MshRead(inFile,varargin)
% msh = MshRead(inFile)
% msh = MshRead(inFile,parameters)
% Parameters:
% 'typesToExtract' list of element types to extract. Default: [15,1,2,3,4,5]
% See http://gmsh.info/doc/texinfo/gmsh.html#MSH-ASCII-file-format for
% types of elements.
% http://www.manpagez.com/info/gmsh/gmsh-2.2.6/gmsh_63.php

%% Input validation
fileExist = @(inFile)(exist(inFile, 'file') == 2);
if  ~fileExist(inFile)
    error(['File "',inFile,'" does not exist!'])
end
typesToExtract = [15,1,2,3,4,5]; %Extract types in this list only!
IP = inputParser;
addParameter(IP,'typesToExtract',typesToExtract);
parse(IP,varargin{:});
PR = IP.Results;
typesToExtract = PR.typesToExtract;
%% Open and read file
disp('Reading file...')
tic
fid = fopen(inFile,'r');
if fid == -1
    error(['Cannot open the file: ', inFile])
end
try
    s = textscan(fid,'%s','Delimiter','\n');
catch
    closeFile(fid);
    error('Something went wrong reading the file!');
end
closeFile(fid);
s = s{1};
toc
%% Process file
N = length(s);

%Find Indices to regions, both starting and ending are found. This is fast!
disp('Finding Regions...')
tic
meshformatInds = find(TextInCellArray(s,'MeshFormat'));
NodesInds = find(TextInCellArray(s,'Nodes'));
ElementsInds = find(TextInCellArray(s,'Elements'));
toc

sMeshFormat = s{meshformatInds(1)+1};
cMeshFormat = textscan(sMeshFormat,'%f %d %d');
mshVersion = cMeshFormat{1};
mshFileType = cMeshFormat{2};
mshDataSize = cMeshFormat{3};
disp(['Msh version: ',num2str(mshVersion)])
disp(['Msh filetype: ',num2str(mshFileType)])
disp(['Msh data size: ',num2str(mshDataSize)])

%Process Coordinates
disp('Processing Coordinates...')
tic
mesh = ProcessCoordinates(s,NodesInds);
toc

% Processing elements
nele = str2double(s{ElementsInds(1)+1});

% Pre-allocate node data using typesToExtract
disp('Pre-allocate Element lists...')
tic
mesh = PreallocateElementLists(mesh,typesToExtract,nele);
toc


% Extract element node list
disp('Processing Element list...')
tic
mesh = ProcessElementList(s,mesh,ElementsInds,typesToExtract);
toc

% Re-mapping
%TODO:
% The node numbers do not necessarily have to form a dense nor an ordered
% sequence. Thus we need to re-map the node numbers to form a dense
% structure.


msh = mesh;
end

function mesh = ProcessElementList(s,mesh,ElementsInds,typesToExtract)
    % Extract element node list
    for lineNum = (ElementsInds(1)+2):ElementsInds(2)-1
        line = textscan(s{lineNum},'%u64');
        vl = line{1};
        type = vl(2);
        % vl(1) element number
        % vl(2) element type
        % vl(3) number of tags
        % vl(4) tag 1...
        % vl(?) node number list
        if ~any(type==typesToExtract)
            continue
        end
        1;
        nnods = GetNumNodsFromEleType(type);
        inod = vl((end-(nnods-1)):end)';
        typeInd = type==typesToExtract;
        c = mesh.ElementList(typeInd).c; %Counter for this element list.
        mesh.ElementList(typeInd).nodes(c,:) = inod;
        mesh.ElementList(typeInd).elmNum(c) = vl(1);
        mesh.ElementList(typeInd).c = mesh.ElementList(typeInd).c +1;
    end

    % Get rid of trailing zeros
    for i = 1:length(typesToExtract)
        c = mesh.ElementList(i).c -1;
        mesh.ElementList(i).nodes = mesh.ElementList(i).nodes(1:c,:);
        mesh.ElementList(i).elmNum = mesh.ElementList(i).elmNum(1:c);
    end
end

function mesh = ProcessCoordinates(s,NodesInds)
nnod = str2double(s{NodesInds(1)+1});
line1 = textscan(s{NodesInds(1)+2},'%d %f %f %f');
dofs = sum(~cellfun(@isempty,line1))-1;
P = zeros(nnod,dofs+1);
switch dofs
    case 1
        i = 1;
        for lineNum = (NodesInds(1)+2):NodesInds(2)-1
            line = textscan(s{lineNum},'%f %f');
            P(i,:) = [line{1},line{2}];
            i = i+1;
        end
    case 2
        i = 1;
        for lineNum = (NodesInds(1)+2):NodesInds(2)-1
            line = textscan(s{lineNum},'%f %f %f');
            P(i,:) = [line{1},line{2},line{3}];
            i = i+1;
        end
    case 3
        i = 1;
        for lineNum = (NodesInds(1)+2):NodesInds(2)-1
            line = textscan(s{lineNum},'%f %f %f %f');
            P(i,:) = [line{1},line{2},line{3},line{4}];
            i = i+1;
        end
end
mesh.P = P(:,2:end);
mesh.nodMap = uint64(P(:,1));
end

function mesh = PreallocateElementLists(mesh,typesToExtract,nele)
    i = 1;
    for type = typesToExtract
        nnods = GetNumNodsFromEleType(type);
        mesh.ElementList(i).type = type;
        mesh.ElementList(i).nodes = zeros(nele,nnods,'uint64');
        mesh.ElementList(i).elmNum = zeros(nele,1,'uint64');
        mesh.ElementList(i).c = 1;
        i = i+1;
    end
end

function nnods = GetNumNodsFromEleType(type)
switch type
    case 1
        nnods = 2;
    case 2
        nnods = 3;
    case 3
        nnods = 4;
    case 4
        nnods = 4;
    case 5
        nnods = 8;
    case 6
        nnods = 6;
    case 7
        nnods = 5;
    case 8
        nnods = 3;
    case 9
        nnods = 6;
    case 10
        nnods = 9;
    case 11
        nnods = 10;
    case 12
        nnods = 27;
    case 13
        nnods = 18;
    case 14
        nnods = 14;
    case 15
        nnods = 1;
    case 16
        nnods = 8;
    case 17
        nnods = 20;
    case 18
        nnods = 15;
    case 19
        nnods = 13;
    case 20
        nnods = 9;
    case 21
        nnods = 10;
    case 22
        nnods = 12;
    case 23
        nnods = 15;
    case 24
        nnods = 15;
    case 25
        nnods = 21;
    case 26
        nnods = 4;
    case 27
        nnods = 5;
    case 28
        nnods = 6;
    case 29
        nnods = 20;
    case 30
        nnods = 35;
    case 31
        nnods = 56;
    case 92
        nnods = 64;
    case 93
        nnods = 125;
end
end

function inds = TextInCellArray(cellArray,txt)
%RegExp

inds = ~cellfun(@isempty,regexp(cellArray,txt));

end

function success = closeFile(fid)
    try
        fclose(fid);
        success = 1;
    catch
        success = 0;
    end
end

function dir = UpDir(dir,n)
    for i = 1:n
        dir = fileparts(dir);
    end
end