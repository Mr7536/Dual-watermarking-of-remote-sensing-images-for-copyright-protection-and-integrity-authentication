
%% 半脆弱水印算法完整性验证


function [watermarked_img,cop]= semi_fragile_watermarking(inputimage,step)

RGB = inputimage(:,:,1:3);
YCBCR = rgb2ycbcr(RGB);
Y=double(YCBCR(:,:,1));

% [Y_M,Y_N,bands]=size(original_img_caculate);
% block_M = floor(Y_M/4);
% block_N = floor(Y_N/4);
% % watermarked = Y;

% for i=1:4
%     for j=1:4
% dwt_caculate = Y((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N);
[cA1, cH1, cV1, cD1] = dwt2(Y, 'haar');
[cA2, cH2, cV2, cD2] = dwt2(cA1, 'haar');
[cA3, cH3, cV3, cD3] = dwt2(cA2, 'haar');

%Chebyshev映射输入值范围为[-1,1]
average = (cH3+cV3)/2;
average_caculate = floor(mod(average,100)/10)/10;%控制映射输入范围
Chebyshev_value = arrayfun(@(x) Chebyshev(x,40),average_caculate);%混沌后序列
extract_value = Chebyshev_value;
extract_value(Chebyshev_value<0)=0;extract_value(Chebyshev_value>0)=1;
%qim 修改
cD3_emb = cD3;
for i2 = 1:size(cD3,1)
    for j2 = 1:size(cD3,2)
        modvalue = mod(cD3_emb(i2,j2),step);
        if modvalue>=(step/2) && extract_value(i2,j2)==1
            continue
        elseif modvalue>=(step/2) && extract_value(i2,j2)==0
            cD3_emb(i2,j2) = cD3_emb(i2,j2)-step/2;
        elseif modvalue<(step/2) && extract_value(i2,j2)==0
            continue
        else %modvalue<(step/2) && extract_value(i2,j2)==1
            cD3_emb(i2,j2) = cD3_emb(i2,j2)+step/2;
        end
    end
end

%恢复图像
cA2_emb = idwt2(cA3,cH3,cV3,cD3_emb,'haar');
cA2_emb = cA2_emb(1:size(cA2,1),1:size(cA2,2));%大小
cA1_emb = idwt2(cA2_emb,cH2,cV2,cD2,'haar');
cA1_emb = cA1_emb(1:size(cA1,1),1:size(cA1,2));%大小
Y_watermarked = idwt2(cA1_emb,cH1,cV1,cD1,'haar');
% img_emb_block = img_emb_block(1:size(dwt_caculate,1),1:size(dwt_caculate,2));

% watermarked((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N)=img_emb_block;
cop=extract_value;
%     end
% end
YCBCR(:,:,1)=uint16(Y_watermarked);
rgb_watermarked = ycbcr2rgb(YCBCR);%转回RGB
watermarked_img = inputimage;
watermarked_img(:,:,1:3)=rgb_watermarked;

% 
% R=[0,-1;1,0;0,6000];
% geotiffwrite('result\watermarked_img.tif', watermarked_img, R, 'CoordRefSysCode', 21417);

end


