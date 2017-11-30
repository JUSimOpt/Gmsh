clear;clc;close all

addpath(fullfile('Gmsh'))

[status,cmdout] = RunGmshScript('beamMeshGenerator.geo','verbose','on')

msh = MshRead(fullfile(pwd,'mesh.msh'))

