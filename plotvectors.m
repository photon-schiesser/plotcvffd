function h = plotvectors(X,Y,magnitude,angle,scale,type)
    magmax = max(abs(magnitude));
    
    if nargin < 5
        scale = [];
    end
    
    if nargin < 6
        type = [];
    end
    
    if isempty(scale)
            scale = magmax;
    end

    mag_norm = abs(magnitude./scale*100);

%     triplot(tri,X,Y,mag_norm)
%     h = scatter(X,Y,mag_norm)
    

    % If there is no angle information, plot the points as circles in a
    % scatter plot. Otherwise, plot as either lines or vectors using
    % delaunay triangulation.
    if isempty(angle)
        scatter(X,Y,mag_norm.*0.7);
    else
        tri = delaunay(X,Y);
        u = mag_norm.*cos(radians(angle));
        v = mag_norm.*sin(radians(angle));
        scale = magmax/scale;       
        if isempty(type) || strcmp(type,'vector')
            triquiver(tri,X,Y,u,v,scale*0.6);
        elseif strcmp(type,'line')
            trilines(tri,X,Y,u,v,scale*0.6);
        end
    end
    h = gca;
    axis equal
end

function rad = radians(degrees)
    rad = degrees.*pi./180;
end