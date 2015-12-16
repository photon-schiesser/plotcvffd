function h=trilines(tri,x,y,u,v,s)
%TRILINES Triangular Line Plot.
% TRILINES(TRI,X,Y,U,V) plots velocity vectors as arrows with components
% in U and V at the triangle vertices identified by the triangulated data
% given by TRI, X, and Y. U and V must have as many elements as X and Y.
%
% TRI, X, and Y define a triangulation where the triangles are defined by
% the size(TRI,1)-by-3 face matrix TRI such as that returned by DELAUNAY.
% Each row of TRI contains indices into the X and Y vectors to define a
% single triangular face.
%
% U and V are commonly computed using [U,V] = TRIGRADIENT(TRI,X,Y,Z), which
% is available from the MATLAB File Exchange.
%
% TRILINES(TRI,X,Y,U,V,s) scales all arrow lengths by the scalar s.
%
% H = TRILINES(...) returns a vector of patch object handles, one to each
% arrow.
%
% Example:
%           x=linspace(-3,3,19);
%           y=linspace(-2.5,2.5,29);
%           [xx,yy]=meshgrid(x,y);
%           zz=peaks(xx,yy);
%           [uu,vv]=gradient(zz,x,y');
%           subplot(1,2,1)
%           quiver(xx,yy,uu,vv)          % standard quiver for comparison
%           title 'Standard Quiver'
% 
%           idx=randperm(numel(zz));      % grab some scattered indices
%           n=idx(1:ceil(numel(zz)/2))';  % one half of them
%           X=xx(n);                      % get scattered data
%           Y=yy(n);
%           Z=zz(n);
%           tri=delaunay(X,Y);            % triangulate scattered data
%           [U,V]=trigradient(tri,X,Y,Z); % available from File Exchange
%           subplot(1,2,2)
%           trilines(tri,X,Y,U,V)
%           title TriLines
%
% See also TRIQUIVER, QUIVER, DELAUNAY, TRIMESH, TRISURF, TRIPLOT.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-11-25

if nargin<5
	error('TRILINES:rhs','Not Enough Input Arguments.')
end
if nargin==5
   s=1;
else
   if numel(s)~=1 || ~isnumeric(s) || ~isreal(s) || s<eps || s>10
      error('TRILINES:rhs','S Must be a Real Positive Scalar.')
   end
end
x=x(:).';   % convert vertices into row vectors
y=y(:).';
u=u(:).';   % convert vertex gradients into row vectors
v=v(:).';

xlen=length(x);
if ~isequal(xlen,length(y),length(u),length(v))
   error('TRILINES:rhs','X, Y, U and V Must Have the Same Number of Elements.')
end
if size(tri,2)~=3 || any(tri(:)<0) || any(tri(:)>xlen)
   error('TRILINES:rhs','TRI Must Be a Valid Triangulation of the Data in X and Y.')
end

d=tri(:,[1 2 3 1]); % use triangle side lengths to find a good arrow length
nal=min(mean(hypot(diff(x(d),1,2),diff(y(d),1,2)))); % nominal arrow length


xn=[-1 1 -1]';              % normalized arrow x coordinates
yn=[0 0 0]';              % normalized arrow y coordinates
xnlength = length(xn);
[tn,rn]=cart2pol(xn,yn);               % normalized arrow polar coordinates

[tg,rg]=cart2pol(u,v);              % vertex gradients in polar coordinates

% build arrays for arrow patches, one patch per column
xt=repmat(tn,1,xlen)+repmat(tg,xnlength,1);                         % arrow angles
yr=s*nal/max(rg)*repmat(rn,1,xlen).*repmat(rg,xnlength,1);         % arrow lengths
[xt,yr]=pol2cart(xt,yr);                             % convert to cartesian
xt=xt+repmat(x,xnlength,1);                        % move arrows to their vertices
yr=yr+repmat(y,xnlength,1);

hax=newplot; % get axes handle to plot into

hh=patch('XData',xt,'YData',yr,...
         'Parent',hax,'FaceColor','b','EdgeColor','b');
if nargout
   h=hh;
end