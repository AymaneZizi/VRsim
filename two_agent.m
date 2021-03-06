%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Main Code in two agent game    %
%  M16iB                          %
%                                 %
%  Changliu Liu                   %
%  2015.8 (Modified 2016.10)      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear;
addpath('Library')
addpath('figure')

ROBOT = 'M16iB'; %M16iB or LRMate200iD (not valid)
MODE = 'MOUSES'; %KINECT or MOUSES
robot=robotproperty(ROBOT);
agent=agentproperty(1);

opt.drawCAD = 1; % 1: draw robotCAD; 0: draw Capsule
opt.refTraj = 0;

if opt.drawCAD, robotCAD = load(['figure/',ROBOT,'.mat']); end

t=1;
% The initial position of human
init_pos=[1,1];

% Intialize figure
if MODE == 'KINECT'
    fighandle=initialize_figure(2,[-2,4],[-2,2],[0,2],[1,-2,0.2]);
    text1handle = text(0,max(ylim)+1,max(zlim)+0.5,'Please calibrate...');
else
    fighandle=initialize_figure_interact(2,[-2,3],[-2,2],[0,2],[60,30]);
    % Calibration
    text1handle = text(0,max(ylim)+1,max(zlim)+0.5,'Please calibrate...');
    [Center,URCorner]=calibration(init_pos);
end

% Draw figures
DrawHR_Skeleton;

Pos = [0;pi/2;0;0;-pi/2;-pi];
Pos1 = [pi/2;pi/2;0;0;-pi/2;-pi];
Pos2 = [-pi/2;pi/2;0;0;-pi/2;-pi];
[~,M]=CapPos(robot.base,robot.DH,robot.cap);

if opt.drawCAD
    robot.handle = DrawRobotCAD(robotCAD, M);
else
    robot.handle=DrawCapsule(robot.boundary,M,0.8,[0,1,0]);
end
%% begin testing
if MODE == 'MOUSES'
    set(fighandle(1), 'currentaxes', fighandle(2))
end
set(text1handle,'string','Test runing...')

if opt.refTraj
    ReferenceTrajectory;
    robot.refTraj = 1; % enable robotmove() to use reference trajectory
else
    robot.goal = [];
end

t=1;
while (t<1000) %true
    if ~opt.refTraj
        robot.goal(:,t) = Pos;
    end % if no reference trajectory, regulate at Pos
    
    robot.obs.HuCap{t,:}=HuCap;
    [status,robot]=robotmove(t,robot);
    
if opt.drawCAD
    robot.handle = UpdateRobot(robot.handle,robot.profile{t+1}.M,robotCAD);
else
    for i=1:robot.nlink+1
        delete(robot.handle(i))
    end
    robot.handle=DrawCapsule(robot.boundary,robot.profile{t+1}.M,0.8,[0,1,0]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the agent position   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch MODE
        case 'MOUSES'
            cursor_pos_current = get(0,'PointerLocation');
            u = (cursor_pos_current - Center)./(URCorner - Center).*init_pos; % normalized
            zoffset = 0;
        case 'KINECT'
            newz = y;
            y = z;
            z = newz;
            newx = y;
            y = x;
            x = newx;
            HuCap{1}.p=[x(4),x(4);y(4),y(4);z(4),z(4)];       %head-head
            HuCap{2}.p=[x(3),x(1);y(3),y(1);z(3),z(1)];       %shoulder center-hip center
            %[x(3),x(5);y(3),y(5);z(3),z(5)]       %shoulder center-shoulder left
            HuCap{5}.p=[x(5),x(6);y(5),y(6);z(5),z(6)];       %shoulder left-elbow left
            HuCap{6}.p=[x(6),x(7);y(6),y(7);z(6),z(7)];       %elbow left-wrist left
            %[x(3),x(9);y(3),y(9);z(3),z(9)]       %shoulder center-shoulder right
            HuCap{3}.p=[x(9),x(10);y(9),y(10);z(9),z(10)];    %shoulder right-elbow right
            HuCap{4}.p=[x(10),x(11);y(10),y(11);z(10),z(11)]; %elbow right-wrist right
            %[x(1),x(13);y(1),y(13);z(1),z(13)]    %hip center-hip left
            HuCap{9}.p=[x(13),x(14);y(13),y(14);z(13),z(14)]; %hip left-knee left
            HuCap{10}.p=[x(14),x(15);y(14),y(15);z(14),z(15)]; %knee left-ankle left
            %[x(1),x(17);y(1),y(17);z(1),z(17)]    %hip center-hip right
            HuCap{7}.p=[x(17),x(18);y(17),y(18);z(17),z(18)]; %hip right-knee right
            HuCap{8}.p=[x(18),x(19);y(18),y(19);z(18),z(19)]; %knee right-ankle right
            u=[0 0];
            zoffset = -min(z);
    end
    xref=HuCap{1}.p(1,1); yref=HuCap{1}.p(2,1);
    agent.offset(:,t)=[u';0];
    for i=1:10
        if MODE == 'MOUSES'
            HuCap{i}.p=HuCap{i}.p+[[u';zoffset] [u';zoffset]]-[xref xref;yref yref;0 0];
        else
            HuCap{i}.p=HuCap{i}.p+[[u';zoffset] [u';zoffset]];
        end
        refreshdata([Hhandle(i)],'caller')
    end

    t=t+1;
    
    output=strcat('timestep:',int2str(t));
    set(text1handle,'string',output)
    drawnow;

    pause(0.05); 

end

set(text1handle,'string','Test ended');