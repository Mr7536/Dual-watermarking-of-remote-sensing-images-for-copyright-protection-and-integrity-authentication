clc,clear,close all;

original_img= imread('E:data\4\Jilin.tif');
original_img_caculate = original_img(2001:4000,2001:4000,:);
Wmdata = imread('E:\data\watermark\32claws.png');

angle = CaculateAngle(original_img_caculate);%计算角度

%对水印进行置乱
arnoldImg = arnold(Wmdata,3,5,20);%a 3,b 5,n 10
arnoldImg = double(arnoldImg);
[arnoldImg_m,arnoldImg_n]=size(arnoldImg);

[Uw,Sw,Vw] = svd(arnoldImg);

%提取RGB通道
RGB = original_img_caculate(:,:,1:3);
YCBCR = rgb2ycbcr(RGB);
Cr=double(YCBCR(:,:,3));
[Y_M,Y_N,band_n]=size(original_img_caculate);

block_M = floor(Y_M/4);
block_N = floor(Y_N/4);

Cr_watermarked = Cr;
strength = 0.1;
for i=1:4
    for j=1:4
        %三级分解
        dwt_caculate = Cr((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N);
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
                if entropy_value>entropy_value1
                    entropy_value1 = entropy_value;%熵值
                    %水印嵌入
                    [U1,S1,V1] = svd(temp1);
                    [U2,S2,V2] = svd(temp2);
                    [U3,S3,V3] = svd(entropy_caculate);
                    T=(S1+S2)/2;
                    T_em = T+strength*Sw;%加法

                    entropy_caculate_emb = U3*T_em*V3';
                    max1=m;max2=n;
                end
            end
        end
        cD3_emb=cD3;
        cD3_emb((max1-1)*arnoldImg_m+1:max1*arnoldImg_m,(max2-1)*arnoldImg_n+1:max2*arnoldImg_n)=entropy_caculate_emb;
        %逆dwt
        cA2_emb = idwt2(cA3,cH3,cV3,cD3_emb,'haar');
        cA2_emb = cA2_emb(1:size(cA2,1),1:size(cA2,2));%大小
        cA1_emb = idwt2(cA2_emb,cH2,cV2,cD2,'haar');
        cA1_emb = cA1_emb(1:size(cA1,1),1:size(cA1,2));%大小
        img_emb_block = idwt2(cA1_emb,cH1,cV1,cD1,'haar');
        img_emb_block = img_emb_block(1:size(dwt_caculate,1),1:size(dwt_caculate,2));
        Cr_watermarked((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N)=img_emb_block;
    end
end
YCBCR(:,:,3)=uint16(Cr_watermarked);
rgb_watermarked = ycbcr2rgb(YCBCR);%转回RGB
watermarked_img = original_img_caculate;
watermarked_img(:,:,1:3)=rgb_watermarked;

step = 8;
[watermarked_img,cop]= semi_fragile_watermarking(watermarked_img,step);

psnr = psnr(watermarked_img,original_img_caculate);
ssim = ssim(watermarked_img,original_img_caculate);
disp([psnr,ssim])

R=[0,-1;1,0;0,6000];
geotiffwrite('result\watermarked_img.tif', watermarked_img, R, 'CoordRefSysCode', 21417);
