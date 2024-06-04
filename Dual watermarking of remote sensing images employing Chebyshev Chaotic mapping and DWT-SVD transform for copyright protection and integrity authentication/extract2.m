
%% 半脆弱水印提取
clc;
vertify_image = watermarked_img;

% R=[0,-1;1,0;0,6000];
% geotiffwrite('result\vertify_image.tif', vertify_image, R, 'CoordRefSysCode', 21417);
% vertify_image = imrotate(vertify_image,10,'nearest','loose');%将图像顺时针旋转*度

RGB2 = vertify_image(:,:,1:3);
YCBCR2 = rgb2ycbcr(RGB2);
Y2=double(YCBCR2(:,:,1));

% B2 = double(vertify_image(:,:,3));
[vm,vn,bands2]=size(vertify_image);
block_M2 = floor(vm/4);
block_N2 = floor(vn/4);

% step = 100;
for i=1:4
    for j=1:4
        dwt_caculate2 = Y2((i-1)*block_M2+1:i*block_M2, (j-1)*block_N2+1:j*block_N2);
        [cA11, cH11, cV11, cD11] = dwt2(dwt_caculate2, 'haar');
        [cA22, cH22, cV22, cD22] = dwt2(cA11, 'haar');
        [cA33, cH33, cV33, cD33] = dwt2(cA22, 'haar'); 
        %Chebyshev映射输入值范围为[-1,1]
        average2 = (cH33+cH33)/2;
        average_caculate2 = floor(mod(average2,100)/10)/10;%控制映射输入范围
        Chebyshev_value2 = arrayfun(@(x) Chebyshev(x,40),average_caculate2);%混沌后序列
        extract_value2 = Chebyshev_value2;
        extract_value2(Chebyshev_value2<0)=0;extract_value2(Chebyshev_value2>0)=1;
        %提取对应的QIM值
        cA33_emb = cA33;
        for i2 = 1:size(cA33,1)
            for j2 = 1:size(cA33,2)
                modvalue2 = mod(cA33_emb(i2,j2),step);
                if modvalue2>=(step/2)
                    copyRight(i2,j2) = 1;
                elseif modvalue2<(step/2)
                    copyRight(i2,j2) = 0;
                end
            end
        end
        vertification = xor(copyRight,extract_value2);
        %输出验证信息
        final_vertification((i-1)*size(vertification,1)+1:i*size(vertification,1), (j-1)*size(vertification,2)+1:j*size(vertification,2))=vertification;
    end
end

imwrite(final_vertification,"result\验证图像.png")
figure(1)
subplot(1,2,1)
imshow(final_vertification);title("验证图像")
subplot(1,2,2)
imshow(copyRight);title("提取验证图像")



