%% 提取
clc;
imputdata=watermarked_img;%watermarked_img original_img_caculate

%提取RGB通道
RGB2 = imputdata(:,:,1:3);
YCBCR2 = rgb2ycbcr(RGB2);
CR2=double(YCBCR2(:,:,3));

[Y_M2,Y_N2,band_n]=size(imputdata);

block_M = floor(Y_M2/4);
block_N = floor(Y_N2/4);

nc_value=0;
for i=1:4
    for j=1:4
        %三级分解
        dwt_caculate = CR2((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N);
        [cA1, cH1, cV1, cD1] = dwt2(dwt_caculate, 'haar');%1级分解
        [cA2, cH2, cV2, cD2] = dwt2(cA1, 'haar'); %2级分解 
        [cA3, cH3, cV3, cD3] = dwt2(cA2, 'haar'); %3级分解
        %查找最优嵌入区域
        [cD3_m,cD3_n]=size(cD3);
        block_m=floor(cD3_m/arnoldImg_m);
        block_n=floor(cD3_n/arnoldImg_n);
        entropy_value1=0;
        for m=1:block_m
            for n=1:block_n
                entropy_caculate=cD3((m-1)*arnoldImg_m+1:m*arnoldImg_m,(n-1)*arnoldImg_n+1:n*arnoldImg_n);
                temp1=cV3((m-1)*arnoldImg_m+1:m*arnoldImg_m,(n-1)*arnoldImg_n+1:n*arnoldImg_n);
                temp2=cH3((m-1)*arnoldImg_m+1:m*arnoldImg_m,(n-1)*arnoldImg_n+1:n*arnoldImg_n);
                %熵值
                entropy_value=entropy(entropy_caculate);
                if entropy_value>=entropy_value1
                    entropy_value1 = entropy_value;%熵值
                    [U1,S1,V1] = svd(temp1);
                    [U2,S2,V2] = svd(temp2);
                    [U33,T_em,V3] = svd(entropy_caculate);
                    T=(S1+S2)/2;
                    SW1=(T_em-T)/strength;
                elseif entropy_value==0  %针对裁剪出现熵值为0的问题
                    SW1=zeros(12,12);
                end           
            end
        end
        extract = Uw*SW1*Vw';
        extract = uint8(extract);
        rearnoldimg = rearnold(extract,3,5,20);
        
        % sumavlue=sum(sum(rearnoldimg))/(32*32);
        % rearnoldimg(rearnoldimg<sumavlue)=0;rearnoldimg(rearnoldimg>=sumavlue)=255;

        dNC = abs(nc(rearnoldimg,Wmdata));
        if nc_value<dNC
            nc_value = dNC;
            final_image = rearnoldimg;
        end
        
    end
end

figure(2);
subplot(1,3,1), imshow(Wmdata),title('original watermark');
subplot(1,3,2), imshow(arnoldImg),title('scrambling');
subplot(1,3,3), imshow(final_image),title(strcat('extract','  NC=',num2str(nc_value)));
disp(nc_value)
imwrite(final_image,"result/extract_watermark.png");
% imwrite(rearnoldimg,"result/rearnoldimg.png");
