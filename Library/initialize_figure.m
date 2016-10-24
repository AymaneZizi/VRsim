% This function initializes an 3D animation plane
%    initialize_figure(i,varargin)
% varargin can specify xlim, ylim, zlim, view
%
% Changliu Liu
% 2015.8

function fighandle=initialize_figure(i,varargin)
fighandle = figure(i);clf;
set(fighandle,'Position',get(0,'ScreenSize'),'color','w')
set(fighandle,'renderer','opengl')
grid on;
hold on;

if length(varargin)>1
    xlim=varargin{1};
    ylim=varargin{2};
    zlim=varargin{3};
else
    xlim=[-1,3];
    ylim=[-1,1];
    zlim=[0,2];
end

if length(varargin)>3
    view(varargin{4});
else
    view([1,-0.5,0.4])
end

axis equal
axis([xlim,ylim,zlim])
lighting=camlight('left');
%lighting phong
set(gca,'Color',[0.8 0.8 0.8]);
%set(gcf,'Renderer','zbuffer');

wall{1}.handle=fill3([xlim(1),xlim(1),xlim(2),xlim(2)],[ylim(1),ylim(2),ylim(2),ylim(1)],[zlim(1),zlim(1),zlim(1),zlim(1)],[0.1,0.1,0.1]);
wall{2}.handle=fill3([xlim(1),xlim(1),xlim(1),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],[zlim(1),zlim(2),zlim(2),zlim(1)],[0,0.9,0.9]);
wall{3}.handle=fill3([xlim(1),xlim(1),xlim(2),xlim(2)],[ylim(2),ylim(2),ylim(2),ylim(2)],[zlim(1),zlim(2),zlim(2),zlim(1)],[0,0.9,0.9]);

end