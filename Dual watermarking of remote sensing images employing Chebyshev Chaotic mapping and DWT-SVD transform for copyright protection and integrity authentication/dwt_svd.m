
function [img_emb,nc_value]=dwt_svd(Y,Wmdata,alpha,beta,gamma)
%对水印进行置乱
Wmdata = im2uint8(Wmdata); %转
arnoldImg = arnold(Wmdata,3,5,20);%a 3,b 5,n 10
arnoldImg = im2double(arnoldImg);%将水印值归到0-1间
[arnoldImg_m,arnoldImg_n]=size(arnoldImg);

% [Uw,Tw] = schur(arnoldImg);
[Uw,Sw,Vw] = svd(arnoldImg);

[Y_M,Y_N]=size(Y);

block_M = floor(Y_M/8);
block_N = floor(Y_N/8);
img_emb = Y;
%将Y进行分块
for i=1:8
    for j=1:8
        %三级分解
        dwt_caculate = Y((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N);
        [cA1, cH1, cV1, cD1] = dwt2(dwt_caculate, 'haar');%1级分解
        [cA2, cH2, cV2, cD2] = dwt2(cA1, 'haar'); %2级分解
        [cA3, cH3, cV3, cD3] = dwt2(cA2, 'haar'); %3级分解
        %纹理系数
        Ts = alpha*(mse(cH3)+mse(cV3)+mse(cA3)) + beta*(mse(cH2)+mse(cV2)+mse(cA2))+gamma*(mse(cH1)+mse(cV1)+mse(cA1));
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
                    T_em = T.*(1+Ts*Sw);
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
        img_emb((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N)=img_emb_block;

    end
end

nc_value=0;
for i=1:8
    for j=1:8
        %三级分解
        dwt_caculate = img_emb((i-1)*block_M+1:i*block_M, (j-1)*block_N+1:j*block_N);
        [cA1, cH1, cV1, cD1] = dwt2(dwt_caculate, 'haar');%1级分解
        [cA2, cH2, cV2, cD2] = dwt2(cA1, 'haar'); %2级分解
        [cA3, cH3, cV3, cD3] = dwt2(cA2, 'haar'); %3级分解
        %纹理系数
        Ts = alpha*(mse(cH3)+mse(cV3)+mse(cA3)) + beta*(mse(cH2)+mse(cV2)+mse(cD2))+gamma*(mse(cH1)+mse(cV1)+mse(cD1));
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
                    [U1,S1,V1] = svd(temp1);
                    [U2,S2,V2] = svd(temp2);
                    [U3,T_em,V3] = svd(entropy_caculate);
                    T=(S1+S2)/2;  
                    value=((T_em./T)-1);
                    value(isnan(value)) = 0 ;
                    SW1=value/Ts;
                    max1=m;max2=n; 
                end
            end
        end
        extract = Uw*SW1*Vw';
        extract = im2uint8(extract);%转回uint8
        rearnoldimg = rearnold(extract,3,5,20);
        
        rearnoldimg(rearnoldimg<125)= 0;rearnoldimg(rearnoldimg>=125)= 255;
        
        dNC = nc(rearnoldimg,Wmdata);
        if nc_value<dNC
            nc_value = dNC;
            final_image = rearnoldimg;
        end
        
    end
end
end




