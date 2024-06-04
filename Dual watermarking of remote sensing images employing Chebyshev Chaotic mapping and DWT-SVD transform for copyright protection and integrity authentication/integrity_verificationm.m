clc;
%% 半脆弱水印验证
vertify_image = watermarked_img;

RGB2 = vertify_image(:,:,1:3);
YCBCR = rgb2ycbcr(RGB2);
Y2=double(YCBCR(:,:,1));

dwt_caculate2 = Y2;
[cA11, cH11, cV11, cD11] = dwt2(dwt_caculate2, 'haar');
[cA22, cH22, cV22, cD22] = dwt2(cA11, 'haar');
[cA33, cH33, cV33, cD33] = dwt2(cA22, 'haar');
%Chebyshev映射输入值范围为[-1,1]
average2 = (cH33+cV33)/2;
average_caculate2 = floor(mod(average2,100)/10)/10;%控制映射输入范围
Chebyshev_value2 = arrayfun(@(x) Chebyshev(x,40),average_caculate2);%混沌后序列
extract_value2 = Chebyshev_value2;
extract_value2(Chebyshev_value2<0)=0;extract_value2(Chebyshev_value2>0)=1;
%提取对应的QIM值
cD33_emb = cD33;
for i2 = 1:size(cD33,1)
    for j2 = 1:size(cD33,2)
        modvalue2 = mod(cD33_emb(i2,j2),step);
        if modvalue2>=(step/2)
            copyRight(i2,j2) = 1;
        elseif modvalue2<(step/2)
            copyRight(i2,j2) = 0;
        end
    end
end
%输出验证信息
vertification=copyRight;
final_vertification = xor(extract_value2,vertification);
final_vertification = bwmorph(final_vertification,"majority");

imwrite(final_vertification,"result\验证图像.png")
figure(1)
subplot(1,2,1)
imshow(final_vertification);title("验证图像")
subplot(1,2,2)
imshow(vertification);title("提取验证图像")
geotiffwrite('result\vertify_image.tif', vertify_image, R, 'CoordRefSysCode', 21417);


