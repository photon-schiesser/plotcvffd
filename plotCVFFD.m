function plotCVFFD(filename,scale,handles)


[x, y, mag, angle, labeldata] = readCVFFD(filename);

npos = size(x,2);

% Check input arguments
scale_arg = 2;
if nargin < scale_arg;
    scale = [];
end

handles_arg = 3;
if nargin < handles_arg
    handles = [];    
elseif length(handles) ~= npos
    error('length(handles) should match the number of zoom positions in the data file')
end

for j = 1:npos
    type = [];
    
    if isempty(handles)
        figure
    else
        axes(handles(j))
    end
        
    if isempty(angle)
        angle = int16.empty(0,npos);
    end

    if labeldata.zernikes(1) == 5
        type = 'line';
    end

    plotvectors(x(:,j),y(:,j),mag(:,j),angle(:,j),scale,type);

    % Add labels to plots
    title(labeldata.plottitle1)
    xlabel(labeldata.fieldtypename)
    ylabel(labeldata.fieldtypename)

    % Change limits to be 10% larger than the max/min field
    xmin = min(x(:,j));
    ymin = min(y(:,j));
    xmax = max(x(:,j));
    ymax = max(y(:,j));       
    xl = [xmin xmax].*1.1;
    yl = [ymin ymax].*1.1;
    xlim(xl);
    ylim(yl);
end