# Gmsh
Gmsh wrapper for MATLAB v.0.5

## MshRead 
Read .msh files.

    mesh = MshRead(filePath)
	mesh = MshRead(filePath,'typesToExtract',typesArray)

`filePath` is the .msh file
`mesh` is a struct containing the mesh data.
typesArray contains a list of element types to extract.
See [http://gmsh.info/doc/texinfo/gmsh.html#MSH-ASCII-file-format](http://gmsh.info/doc/texinfo/gmsh.html#MSH-ASCII-file-format) for a list over available elements.

## Installation
Include the `Gmsh` folder to your path. Copy the executable `gmesh.exe` (only implemented for windows as of now) to the `Gmsh` folder.

### Example
Run `main.m` or the following code to get up and running.

    addpath(fullfile('Gmsh'))
    
    [status,cmdout] = RunGmshScript('beamMeshGenerator.geo','verbose','on');
    
    msh = MshRead(fullfile(pwd,'mesh.msh'),'typesToExtract',[3,5])
    