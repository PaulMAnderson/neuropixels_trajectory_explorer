function [obj,texture_map] = readObj(filename, path)

% [obj,texture_map] = readObj(filename, path)
% Inputs: 
%           filename    - name of file, that you want to read in
%           path        - path of the file
% 
% Outputs:
%           obj         - matlab structure containing:
%                         obj.v - vertices 
%                         obj.vt - vertex texture coordinates 
%                         obj.vn - vertex normals
%                         obj.f - faces
%                         obj.t - texture indices
%           texture_map - texture image
%
% This function is adapted from  Bernard Abayowas 'readObj' function but is
% significantly faster, but writes a txt-file derived from obj-file to disk
% (https://www.mathworks.com/matlabcentral/fileexchange/18957-readobj).
% It reads vertices, faces, texture and normal information from a 
% specified Obj file, and stores the information in a Matlab structure. 
% This file is designed for faces with 3 vertices (Triangulated mesh).
% The model should be continuous. Seperated parts should be loaded 
% respectively.
%
% Result can be displayed with accompanying displayObj
% Written by Quirin


%read files in


% File IO
if nargin < 2
    path = pwd;
end

if ~isequal(path(end),filesep)
    path = [path filesep];
end

filePath = [path filename];

if ~isfile(filePath)
    error('No file found...');
end

%% Read file
f = fileread(strcat(path, filename));
T = readtable(filePath, 'FileType', 'text');

% find vertices and vertex texture coordinates and vertex normals
columnNames = T.Properties.VariableNames;
firstColName = columnNames{1};
vLogic =  strcmp(T.(firstColName),'v');
vtLogic =  strcmp(T.(firstColName),'vt');
vnLogic =  strcmp(T.(firstColName),'vn');

%% extract material and texture
startKeyword = 'mtllib ';
endKeyword = '.mtl';
startIndex = strfind(f, startKeyword);
endIndex = strfind(f, endKeyword);
texture = '';
if ~isempty(startIndex)
    material = f(startIndex(1) + length(startKeyword):endIndex(1) + length(endKeyword) - 1);
    ffpp = fopen(strcat(path, material),'r');
    tempstr2 = ' ';
    while ( tempstr2 ~= -1)
        tempstr2 = fgets(ffpp);
        if findstr(tempstr2,'map_Kd')
            texture = extractAfter(tempstr2, 'map_Kd ');
        end
    end
    fclose(ffpp);
end
if ~isempty(texture)
    texture_map = imread(strcat(path,texture)); %open image
end 

%% find faces and texture index
startKeyword = 'f ';
startIndex = strfind(f, startKeyword);
fText = f(startIndex(1):end);
ffText = fText;
ffText(1) = [];
%check format of faces
startIndex1 = strfind(ffText, 'v');
startIndex2 = strfind(ffText, 'vn');
startIndex3 = strfind(ffText, 'vt');
startIndex4 = strfind(ffText, 'f');
index = min([startIndex1,startIndex2,startIndex3,startIndex4]);
fLine = fText(1:index);
fLine(1:2) = [];
sizeOfFline = count(fLine,'/');
doubleSlash = count(fLine,'//');

if sizeOfFline == 0
    newStr = strrep(fText,'/', ' ');
    txs = textscan(newStr, '%s%f%f%f', 'delimiter', ' ');
    fLogic =  strcmp(txs{1,1},'f');
    m = min([size(txs{1,2},1),size(txs{1,3},1),size(txs{1,4},1)]);
    fLogic = fLogic(1:m);
    textureIndex = [];
    fs = [txs{:,2}(1:m),txs{:,3}(1:m),txs{:,4}(1:m)];
    fs = fs(fLogic,:);
elseif sizeOfFline == 3
    newStr = strrep(fText,'/', ' ');
    txs = textscan(newStr, '%s%f%f%f%f%f%f', 'delimiter', ' ');
    fLogic =  strcmp(txs{1,1},'f');
    m = min([size(txs{1,2},1),size(txs{1,4},1),size(txs{1,6},1),size(txs{1,3},1),size(txs{1,5},1),size(txs{1,7},1)]);
    fLogic = fLogic(1:m);
    textureIndex = [txs{:,3}(1:m),txs{:,5}(1:m),txs{:,7}(1:m)];
    fs = [txs{:,2}(1:m),txs{:,4}(1:m),txs{:,6}(1:m)];   
    textureIndex = textureIndex(fLogic,:);
    fs = fs(fLogic,:);
elseif sizeOfFline == 6 && doubleSlash == 0
    newStr = strrep(fText,'/', ' ');
    txs = textscan(newStr, '%s%f%f%f%f%f%f%f%f%f', 'delimiter', ' ');
    fLogic =  strcmp(txs{1,1},'f');
    m = min([size(txs{1,2},1),size(txs{1,3},1),size(txs{1,5},1),size(txs{1,6},1),size(txs{1,8},1),size(txs{1,9},1)]);
    textureIndex = [txs{:,3}(1:m),txs{:,6}(1:m),txs{:,9}(1:m)];
    fLogic = fLogic(1:m);
    textureIndex = textureIndex(fLogic,:);
    fs = [txs{:,2}(1:m),txs{:,5}(1:m),txs{:,8}(1:m)];
    fs = fs(fLogic,:);
else
    newStr = strrep(fText,'//', ' ');
    txs = textscan(newStr, '%s%f%f%f%f%f%f', 'delimiter', ' ');
    fLogic =  strcmp(txs{1,1},'f');
    m = min([size(txs{1,2},1),size(txs{1,5},1),size(txs{1,8},1)]);
    textureIndex = [];
    fLogic = fLogic(1:m);
    fs = [txs{:,2}(1:m),txs{:,5}(1:m),txs{:,8}(1:m)];
    fs = fs(fLogic,:);
end

c2 = columnNames{2};
c3 = columnNames{3};
c4 = columnNames{4};
v =  [T.(c2)(vLogic,:),T.(c3)(vLogic,:),T.(c4)(vLogic,:)];
vt = [T.(c2)(vtLogic,:),T.(c3)(vtLogic,:),T.(c4)(vtLogic,:)];
vn = [T.(c2)(vnLogic,:),T.(c3)(vnLogic,:),T.(c4)(vnLogic,:)];
obj.v = v; obj.vt = vt; obj.vn = vn; obj.f = fs; obj.t = textureIndex;
end