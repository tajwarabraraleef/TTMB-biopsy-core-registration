%% Code for Registration of trans-perineal template mapping biopsy cores to volumetric ultrasound

% Tajwar Abrar Aleef - tajwaraleef@ece.ubc.ca
% Website: https://tajwarabraraleef.github.io/
% Robotics and Control Laboratory, University of British Columbia, Vancouver, Canada

%This function is used for observing quality of registered images.

%This function allows users to:
%*scroll through the target & moving image using slider or mouse wheel
%*change alpha level to observe between moving and target images

%click mouse button to switch between scrolling to change planes or scrolling to change alpha level

%%%%Based on imshow3D.m function from Maysam Shahedi (mshahedi@gmail.com)


function reg_visualize(moving, target) 

maxPlane = size(moving,3);
plane = 1;

alpha = 0;
MouseButtonStat = 0;

PlaneFntSz = 9;
AlphaFntSz = 9;


axes('position',[0,0.2,1,0.8]), 

%Subplotting the images
movH = subplot(1,3,1); imshow(moving(:,:,plane)),axis off, title('Moving')
fixH = subplot(1,3,2); imshow(target(:,:,plane)),title('Target'); axis off;
blendH = subplot(1,3,3); imshow(target(:,:,plane)),title('Blend'); axis off;
axis off;

FigPos = get(gcf,'Position');
SliderPos = [50 45 uint16(FigPos(3)-100)+1 20];
PlanePos = [50 65 uint16(FigPos(3)-100)+1 15];
Alphaval_Pos = [320 20 100 20];

sliderhand = uicontrol('Style','slider','Position',SliderPos,...
              'value',plane, 'min',1, 'max',maxPlane,'SliderStep',[1/maxPlane, 1/maxPlane], 'Callback', {@SliceSlider, target, moving});
slidertxthand = uicontrol('Style', 'text','Position', PlanePos,'String',sprintf('Plane: %d', plane), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', PlaneFntSz);
Alphatxthand = uicontrol('Style', 'text','Position', Alphaval_Pos,'String',sprintf('Alpha: %0.2f',alpha), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', AlphaFntSz);

set(gcf, 'WindowScrollWheelFcn', @mouseScroll);
set(gcf, 'ButtonDownFcn', @mouseClick);
set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);


function SliceSlider (hObj,event, target, moving)
    plane = round(get(hObj,'Value'));
    %disp(plane)
    set(get(blendH,'children'),'cdata',(alpha*target(:,:,plane) + (1-alpha)*moving(:,:,plane)));
    set(get(fixH,'children'),'cdata',(target(:,:,plane)));
    set(get(movH,'children'),'cdata',(moving(:,:,plane)));
    set(slidertxthand, 'String', sprintf('Plane: %d',plane));
end


function mouseClick (object, eventdata)
    MouseButtonStat = ~MouseButtonStat; %switch button states
    %disp(MouseStat)
end

function mouseScroll (object, eventdata)
    if (MouseButtonStat == 0)      
        UPDN = eventdata.VerticalScrollCount;
        plane = plane - (UPDN);
        if (plane < 1)
        plane = 1;
        elseif plane>maxPlane
        plane = maxPlane;  
        end
        set(sliderhand,'Value',plane);
        set(slidertxthand, 'String', sprintf('Plane: %d',plane));
        set(get(blendH,'children'),'cdata',(alpha*target(:,:,plane) + (1-alpha)*moving(:,:,plane)));
        set(get(fixH,'children'),'cdata',(target(:,:,plane)));
        set(get(movH,'children'),'cdata',(moving(:,:,plane)));
        set(Alphatxthand, 'String', sprintf('Alpha: %0.2f',alpha));
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

        set(get(blendH,'children'),'cdata',(alpha*target(:,:,plane) + (1-alpha)*moving(:,:,plane)));
        set(Alphatxthand, 'String',  sprintf('Alpha: %0.2f',alpha));
        axis off;
    end
end



end