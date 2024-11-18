function displayObj(obj,tex)
%
% function display_obj(obj,texture)
%
% displays an obj structure with texture
%
% INPUTS:  obj:     object data
%                   - obj.v:    vertices
%                   - obj.vt:   texture coordinates
%                   - obj.f:  face definition vertices
%
%       texture:    -  texture image full path
%
% Adapted from Bernard Abayowas function by Quirin
%14.03.2021

texture = tex;
texture_img = flipdim(texture,1);
[sy, sx, sz] = size(texture_img);
texture_img =  reshape(texture_img,sy*sx,sz);
% make image 3D if grayscale
if sz == 1
    texture_img = repmat(texture_img,1,3);
end
% select what texture correspond to each vertex according to face
% definition
[vertex_idx fv_idx] = unique(obj.f);
texture_idx = obj.t(fv_idx);
x = abs(round(obj.vt(:,1)*(sx-1)))+1; % the indices for texture are percent for OBJ files. Hence vt (vertex texture) is multiplied by pixle size of the texture. since pictures start with 0 --> pixlesize-1
y = abs(round(obj.vt(:,2)*(sy-1)))+1;
xy = sub2ind([sy sx],y,x);
texture_pts = xy(texture_idx);
tval = double(texture_img(texture_pts,:))/255;
% display object
% patch('vertices',obj.v,'faces',obj.f,'FaceVertexCData', tval);
patch('vertices',obj.v,'faces',obj.f);
shading interp
colormap gray(256);
lighting phong;
% camproj('perspective');
axis equal
grid on
xlabel('x-axis');ylabel('y-axis');zlabel('z-axis');
% cameratoolbar
end
