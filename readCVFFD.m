function [x,y,mag,angle,labeldata] = readCVFFD(filename)
if nargin == 0
    filename = 'C:\Users\Eric\Google Drive\MTW-OPAL\testbuf2.dat';
end
fid = fopen(filename,'r');
data = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
cstr = data{1};
fclose(fid);
zernikenames = {...
    1, 'Piston';...
    2, 'Tilt';...
    3, 'Tilt';...
    4, 'Defocus';...
    5, 'Primary Astigmatism';...
    6, 'Primary Astigmatism';...
    7, 'Primary Coma';...
    8, 'Primary Coma';...
    9, 'Primary Spherical';...
    10, 'Elliptical Coma';...
    11, 'Elliptical Coma';...
    12, 'Oblique Spherical';...
    13, 'Oblique Spherical';...
    14, 'Fifth-order Aperture Coma';...
    15, 'Fifth-order Aperture Coma';...
    16, 'Fifth-order Spherical'};
    
% Find the start of each zoom's data by searching for the word "position"
indexc = strfind(cstr, 'Position');
index = find(~cellfun('isempty', indexc));
numpos = length(index);
headerlines = index + 1;

% Determine if there is an orientation component to the aberration field by
% searching for "angle"
indexc = strfind(cstr, 'Angle');
index_ang = find(~cellfun('isempty', indexc),1);

% Determine the object field type by looking at line 3 (inserted by the
% CodeV script I wrote). If it is there, generate a field type.
fieldtype = cstr{3};
fieldtypename = [];
if ~isempty(fieldtype)
    switch fieldtype
        case 'ANG'
            fieldtypename = 'Object Angle (°)';
        case 'OBJ'
            fieldtypename = 'Object Height (mm)';
        case 'IMG'
            fieldtypename = 'Paraxial Image Height (mm)';
        case 'RIH'
            fieldtypename = 'Real Image Height (mm)';
    end
end

% Grab the title from the second line of the string data by parsing the
% data and determining what type of plot it is: RMS WFE, single zernike, or
% paired zernikes

plottitle1 = strtrim(cstr{2});
fringezerns = strfind(plottitle1,'FRINGE ZERNIKE COEFFICIENTS');
fringezern = strfind(plottitle1,'FRINGE ZERNIKE COEFFICIENT MAGNITUDE');
rmswfe = strfind(plottitle1,'RMS WAVEFRONT');
dsc = strfind(plottitle1,'DISTORTION');

% Set type based on which of the above statements returns something
if ~isempty(fringezerns)
    type = 'zpair';
elseif ~isempty(fringezern)
    type = 'zsingle';
elseif ~isempty(rmswfe)
    type = 'rmswfe';
elseif ~isempty(dsc)
    type = 'dsc';
else
    type = 'unexpected';
end

switch type
    case 'zpair'
        tempstring = textscan(plottitle1,'FRINGE ZERNIKE COEFFICIENTS Z%d AND Z%d %s %s %f');
        zernikes = [tempstring{1}, tempstring{2}];
        wavelength = tempstring{5};
        plottitle1 = ['Z' num2str(zernikes(1)) '/' num2str(zernikes(2)) ' @ \lambda=' num2str(wavelength) ' nm'];
        toptitle = zernikenames{zernikes(1),2};
    case 'zsingle'
        tempstring = textscan(plottitle1,'FRINGE ZERNIKE COEFFICIENT MAGNITUDE: Z%d %s %s %f');
        zernikes = tempstring{1};
        wavelength = tempstring{4};
        plottitle1 = ['Z' num2str(zernikes) ' @ \lambda=' num2str(wavelength) ' nm'];
        toptitle = zernikenames{zernikes,2};
    case 'rmswfe'
        tempstring = textscan(plottitle1,'%s %s %s %s %s %f');
        wavelength = tempstring{6};
        zernikes = 0;
        plottitle1 = ['RMS WFE @ \lambda=' num2str(wavelength) ' nm'];
        toptitle = [];
    case 'dsc'
        tempstring = textscan(plottitle1,'%s %s %s');
        units = tempstring{3};
        zernikes = 0;
        toptitle = [];
    case 'unexpected'
        error('No expected input found. Unable to parse file.')
end

% if ~isempty(fringezerns)
%     tempstring = textscan(plottitle1,'FRINGE ZERNIKE COEFFICIENTS Z%d AND Z%d %s %s %f');
%     zernikes = [tempstring{1}, tempstring{2}];
%     wavelength = tempstring{5};
%     plottitle1 = ['Z' num2str(zernikes(1)) '/' num2str(zernikes(2)) ' @ \lambda=' num2str(wavelength) ' nm'];
% elseif ~isempty(fringezern)
%     tempstring = textscan(plottitle1,'FRINGE ZERNIKE COEFFICIENT MAGNITUDE: Z%d %s %s %f');
%     zernikes = tempstring{1};
%     wavelength = tempstring{4};
%     plottitle1 = ['Z' num2str(zernikes) ' @ \lambda=' num2str(wavelength) ' nm'];
%     
% elseif ~isempty(rmswfe)
%     tempstring = textscan(plottitle1,'%s %s %s %s %s %f');
%     wavelength = tempstring{6};
%     zernikes = 0;
%     plottitle1 = ['RMS WFE @ \lambda=' num2str(wavelength) ' nm'];
% elseif ~isempty(dsc)
%     tempstring = textscan(plottitle1,'%s %s %s');
%     units = tempstring{3};
%     zernikes = 0;
% else
%     
% end

line1 = textscan(cstr{1},'%{dd-MMM-yyyy}D %d:%d:%d %s','Delimiter','\t');

plottitle2 = strtrim(line1{5});

vector = true;
format = '%f %f %f %f';
if isempty(index_ang)
    vector = false;
    format = '%f %f %f';
end


for j = 1:numpos;
    fid = fopen(filename,'r');
    data = textscan(fid, format,'headerLines',headerlines(j));
    x(:,j) = data{1};
    y(:,j) = data{2};
    mag(:,j) = data{3};
    if vector
        angle(:,j) = data{4};
    else
        angle = [];
    end
%     figure
%     plotvectors(x,y,mag,angle)
end

fclose(fid);

% Find absolute maxiumum
max_mag = max(mag,[],1);
min_mag = min(mag,[],1);
avg = mean(mag,1,'omitnan');

for j = 1:length(max_mag)
    if abs(max_mag(j)) < abs(min_mag(j))
        max_mag(j) = min_mag(j);
    else
        max_mag(j) = max_mag(j);
    end
end

switch type
    case 'rmswfe'
        labeldata.plottitle1 =  [plottitle1, sprintf('\n'),...
            'Max: ',num2str(max_mag(1),3), ' \lambda, ',...
            'Avg: ',num2str(avg,3), ' \lambda'];
    case 'dsc'
        labeldata.plottitle1 =  [plottitle1, sprintf('\n'),...
            'Max: ',num2str(max_mag(1),3), ' mm, ',...
            'Avg: ',num2str(avg,3), ' mm'];
    otherwise
        labeldata.plottitle1 =  [toptitle, sprintf('\n'), ...
            plottitle1, sprintf('\n'),'Max: ',num2str(max_mag(1),3), ' \lambda'];
end

labeldata.plottitle2 =  plottitle2;
labeldata.fieldtypename = fieldtypename;
labeldata.zernikes = zernikes;

end