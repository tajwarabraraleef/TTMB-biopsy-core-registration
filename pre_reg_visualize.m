%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada


%This function is used for observing moving and target images.
%Use this function to find the slices of target image that corresponds to the moving image slices. 

%This function allows users to:
%*scroll through the target image using slider or mouse wheel
%*change plane of moving image by using the val box
%*change alpha level to observe between moving and target images

%click mouse button to switch between scrolling to change planes or scrolling to change alpha level

%%%%Based on imshow3D.m function from Maysam Shahedi (mshahedi@gmail.com)

function pre_reg_visualize(moving, target, moving_plane) 

maxPlaneMoving = size(moving,3);
maxPlaneTarget= size(target,3);
planeTarget = 1;
planeMoving = moving_plane;

MouseButtonStat = 0;
alpha = 0;


FixPlaneFntSz = 9;
MovPlaneFntSz = 10;
AlphaFntSz = 9;


axes('position',[0,0.2,1,0.8]), 

%Subplotting the images
movH = subplot(1,3,1); imshow(moving(:,:,planeMoving),[]),axis off, title('Moving')
fixH = subplot(1,3,2); imshow(target(:,:,planeTarget),[]),title('Target'); axis off;
blendH = subplot(1,3,3); imshow(target(:,:,planeTarget),[]),title('Blend'); axis off;

axis off;

FigPos = get(gcf,'Position');
SliderPos = [50 45 uint16(FigPos(3)-100)+1 20];
FixPlanetxt_Pos = [50 65 uint16(FigPos(3)-100)+1 15];
MovPlanetxt_Pos = [175 20 45 20];
MovPlaneval_Pos = [220 20 60 20];
Alphaval_Pos = [320 20 100 20];

sliderhand = uicontrol('Style','slider','Position',SliderPos,...
              'value',planeTarget, 'min',1, 'max',maxPlaneTarget,'SliderStep',[1/maxPlaneTarget, 0.01], 'Callback', {@SliceSlider, target, moving});
slidertxthand = uicontrol('Style', 'text','Position', FixPlanetxt_Pos,'String',sprintf('Fix Plane: %d',planeTarget), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', FixPlaneFntSz);
MovPlanetxthand = uicontrol('Style', 'text','Position', MovPlanetxt_Pos,'String',sprintf('Mov:'), 'BackgroundColor', [1 1 1], 'FontSize', MovPlaneFntSz);
MovPlanevalhand = uicontrol('Style', 'edit','Position', MovPlaneval_Pos,'String',sprintf('%6.0f',planeMoving), 'BackgroundColor', [1 1 1], 'FontSize', AlphaFntSz,'Callback', @MovPlaneChanged);
Alphatxthand = uicontrol('Style', 'text','Position', Alphaval_Pos,'String',sprintf('Alpha: %0.2f',alpha), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', AlphaFntSz);

set(gcf, 'WindowScrollWheelFcn', @mouseScroll);
set (gcf, 'ButtonDownFcn', @mouseClick);
set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);


function SliceSlider (hObj,event, target, moving)
    planeTarget = round(get(hObj,'Value'));
    %disp(plane_f)
    set(get(fixH,'children'),'cdata',(target(:,:,planeTarget)));
    set(get(blendH,'children'),'cdata',(alpha*target(:,:,planeTarget) + (1-alpha)*moving(:,:,planeMoving)));
    set(slidertxthand, 'String', sprintf('Fix Plane: %d',planeTarget));
end

function mouseClick (object, eventdata)
    %MouseStat = get(gcbf, 'SelectionType');
    MouseButtonStat = ~MouseButtonStat; %switch button states
    %disp(MouseButtonStat)
end

function mouseScroll (object, eventdata)
        
    if (MouseButtonStat == 0)      
        UPDN = eventdata.VerticalScrollCount;
        planeTarget = planeTarget - (UPDN);
        if (planeTarget < 1)
            planeTarget = 1;
        elseif planeTarget>maxPlaneTarget
            planeTarget = maxPlaneTarget;  
        end
               
        set(sliderhand,'Value',planeTarget);
        set(slidertxthand, 'String', sprintf('Fix Plane: %d',planeTarget));
        set(get(fixH,'children'),'cdata',(target(:,:,planeTarget)));
        set(get(blendH,'children'),'cdata',(alpha*target(:,:,planeTarget) + (1-alpha)*moving(:,:,planeMoving)));
        axis off;
    else        
        UPDN = eventdata.VerticalScrollCount;
        alpha = alpha - (UPDN/15);

        if (alpha < 0)
            alpha = 0;
        elseif (alpha > 1)
            alpha = 1;
        end
        %disp(S);
        
        set(get(blendH,'children'),'cdata',(alpha*target(:,:,planeTarget) + (1-alpha)*moving(:,:,planeMoving)));
        set(Alphatxthand, 'String', sprintf('Alpha: %0.2f',alpha));
        axis off;
    end
end

function MovPlaneChanged(varargin)
    planeMoving = str2double(get(MovPlanevalhand, 'string'));
    if (planeMoving < 1)
        planeMoving = 1;
    elseif planeMoving>maxPlaneMoving
        planeMoving = maxPlaneMoving;  
    end
    set(MovPlanevalhand, 'String', planeMoving);
    
    set(get(movH,'children'),'cdata',(moving(:,:,planeMoving)));
    set(get(blendH,'children'),'cdata',(alpha*target(:,:,planeTarget) + (1-alpha)*moving(:,:,planeMoving)));
    set(Alphatxthand, 'String', sprintf('Alpha: %0.2f',alpha));
    axis off;
end
end