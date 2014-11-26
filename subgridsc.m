function [sln,cln,slt,clt,x,y] = subgridsc(file, vlon, vlat, lonlim, latlim)
%SUBGRIDSC Get start and count indices for subgrid in netcdf file
%
% [sln,cln,slt,clt,x,y] = subgridsc(file, vlon, vlat, lonlim, latlim)
%
% This function locates the start and count indices required to extract a
% region from a netcdf file using the Matlab native netcdf tools (ncread,
% etc, 1-based).  It assumes that data is on a rectangular, non-angled
% grid (with respect to latitude and longitude).
%
% Input variables:
%
%   file:   .nc file
% 
%   vlon:   name of longitude variable
% 
%   vlat:   name of latitude variable
% 
%   lonlim: 1 x 2 array, west and east longitude limits for subgrid.  Can
%           be either on -180-180 or 0-360 scale. 
% 
%   latlim: 1 x 2 array, south and north latitude limits for subgrid
%
% Output variables
%
%   sln:    3 x 1 array, start indices for longitude dimension.  The 3
%           values correspond to 3 possible slices (to account for -180-180
%           vs 0-360 files).  If 0, no data in that potential range.
%
%   slt:    1 x 1 array, start index for latitude dimension
%
%   cln:    3 x 1 array, count value for longitude dimension
%
%   clt:    1 x 1 array, count value for latitude dimension
%
%   x:      longitude values (with all 3 potential slices concatenated)
%
%   y:      latitude values

% Copyright 2013 Kelly Kearney


lon = ncread(file, vlon);
lat = ncread(file, vlat);

ltmask = lat >= latlim(1) & lat <= latlim(2);

lnmask{1} = lon-360 >= lonlim(1) & lon-360 <= lonlim(2);
lnmask{2} = lon     >= lonlim(1) & lon     <= lonlim(2);
lnmask{3} = lon+360 >= lonlim(1) & lon+360 <= lonlim(2);

y = lat(ltmask);
x = cat(1, lon(lnmask{1})-360, lon(lnmask{2}), lon(lnmask{3})+360);

[slt,clt] = mask2startcnt(ltmask);
[sln, cln] = deal(zeros(3,1));
for ii = 1:3
    if any(lnmask{ii})
        [sln(ii),cln(ii)] = mask2startcnt(lnmask{ii});
    end
end

% Convert logical mask to start/count combo for netcdf reading

function [s,c] = mask2startcnt(mask)

mask = reshape(mask, 1, []);

isOne = [false, mask, false];
index = [strfind(isOne, [false, true]); ...
         strfind(isOne, [true, false]) - 1];
s = index(1,:);
c = index(2,:) - s + 1;
