
% original_img= imread('E:data\3\suzhou.tif');
% original_img_caculate = original_img(1:2000,1:2000,1:3);
% image = imrotate(original_img_caculate,10,'nearest','loose');
%% 图像矩计算角度
function angle = CaculateAngle(image)

image = image(:,:,1:3);
image = double(im2gray(image));

%计算图像的零阶矩和一阶几何矩
m00=sum(sum(image));

m10=0;m01=0;

m20=0; m02=0;m11=0;m30=0;m12=0;m21=0;m03=0;
[row,col]=size(image);
for i=1:row
    for j=1:col
        %一阶
        m10=m10+i*image(i,j);
        m01=m01+j*image(i,j);
        %二阶、三阶
        m20=m20+i^2*image(i,j);
        m02=m02+j^2*image(i,j);
        m11=m11+j*i*image(i,j);
        m30=m30+i^3*image(i,j);
        m12=m12+i*j^2*image(i,j);
        m21=m21+i^2*j*image(i,j);
        m03=m03+j^3*image(i,j);
    end
end
x = m10/m00;
y = m01/m00;

mu00 = m00;
mu11 = m11 - x*m01;
mu20 = m20 - x*m10;
mu02 = m02 - y*m01;
theta = 1/2*atan2(2*mu11/mu00, (mu20 - mu02)/mu00);
angle = rad2deg(theta);

end