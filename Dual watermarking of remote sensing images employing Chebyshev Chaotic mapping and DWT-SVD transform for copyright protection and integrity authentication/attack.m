clc

% 噪声攻击
% watermarked_image_noise=imnoise(watermarked_img,'salt & pepper',0.0001);%添加方差为0.1的乘性噪声 speckle salt & pepper
% watermarked_image_noise=imnoise(watermarked_img,'gaussian',0,0.003);
% watermarked_image_noise=imnoise(watermarked_img,'speckle',0.001);

%旋转
% image_rotate = imrotate(watermarked_img,1,'nearest','loose');%将图像顺时针旋转*度
% angle2 = CaculateAngle(image_rotate);%计算角度
% roteAngle = angle2-angle;
% image_rotate2 = imrotate(image_rotate,-roteAngle,'nearest','loose');%将图像顺时针旋转*度
% outputImage=cropImage(image_rotate2);


% qu=floor((2000*2000*0.3)^(1/2));
%裁剪
% img_crop = watermarked_img;
% img_crop(2000-qu+1:2000,1:qu,:)=0;%左下
% img_crop(1:qu,2000-qu+1:2000,:)=0;%右上
% img_crop(4096-qu+1:4096,4096-qu+1:4096,:)=0;%右下
% img_crop(500:500+qu,500:500+qu,:)=0;%中间
% img_crop(1:qu,1:qu,:)=0;%左上

% geotiffwrite('result\img_crop.tif', img_crop, R, 'CoordRefSysCode', 21417);


%缩放
% watermarked_  img = imresize(watermarked_img,1.1); %0.46
% % watermarked_img = imresize(watermarked_img,0.9); %0.46
% watermarked_img = imresize(watermarked_img,[Y_M,Y_N]);

%平移2
% emb_img_circshift = circshift(watermarked_img,[200,0]);
%平移
% J = imtranslate(watermarked_img,[200, 200],'FillValues',0,'OutputView','full');

%低通滤波
% Iblur = imgaussfilt(watermarked_img,2.5); %标准差   
%均值滤波
% m =5;
% h = fspecial('average',[m m]);
% averageImageAttacked = imfilter(watermarked_img,h,'replicate');

%中值滤波
% m=1;
% % medianattack_img
% medianattack_img(:,:,1)=medfilt2(watermarked_img(:,:,1),[m,m]);
% medianattack_img(:,:,2)=medfilt2(watermarked_img(:,:,2),[m,m]);
% medianattack_img(:,:,3)=medfilt2(watermarked_img(:,:,3),[m,m]);
% medianattack_img(:,:,4)=medfilt2(watermarked_img(:,:,4),[m,m]);

% 二维仿射变换
% A = [0.9 0.1 0;   
%      0 1 0; 
%      0 0 1];
% tform = affinetform2d(A);
% J = imwarp(watermarked_img,tform);
% k = imresize(J,[Y_M,Y_N]);


disp('攻击结束')

