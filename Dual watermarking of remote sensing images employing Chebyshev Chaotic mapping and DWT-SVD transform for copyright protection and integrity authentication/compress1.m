clc;
%% 多波段遥感影像压缩
data = watermarked_img;

quality = 90;

[width,length,band_number]=size(data);
img_compress = data;
for i=1:band_number
    I = data(:,:,i);
    I=double(I); %将原图像转为双精度数据类型；
    T = dctmtx(8);
    dct = @(block_struct) T * block_struct.data * T';
    B1 = blockproc(I,[8 8],dct);

    %mask用来压缩DCT系数，只留下DCT系数中左上角的10个 rate = 10/64
    if quality == 90
        mask = [1   1   1   1   1   1   1   1  %10.9
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   0
            1   1   1   1   1   1   1   0
            1   1   1   1   1   1   0   0
            1   1   1   1   1   0   0   0];
    elseif quality == 70
             mask = [1   1   1   1   1   1   1   1  %30
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   0
            1   1   1   1   1   1   0   0
            1   1   1   1   1   0   0   0
            1   1   1   1   1   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0];
    elseif quality == 80
        mask = [1   1   1   1   1   1   1   1  %20
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   1
            1   1   1   1   1   1   1   0
            1   1   1   1   1   0   0   0
            1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0];
    elseif quality == 30
        mask = [1   1   1   1   1   1   0   0  %70
            1   1   1   1   1   1   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
    elseif quality == 50
        mask = [1   1   1   1   1   1   0   0  %50
            1   1   1   1   1   1   0   0
            1   1   1   1   1   1   0   0
            1   1   1   1   1   0   0   0
            1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
    elseif quality == 40
        mask = [1   1   1   1   1   0   0   0  %39
            1   1   1   1   1   0   0   0
            1   1   1   1   1   0   0   0
            1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];

    end
    B2 = blockproc(B1,[8 8],@(block_struct) mask .* block_struct.data);%只保留DCT 变换的10 个系数
    invdct = @(block_struct) T' * block_struct.data * T;
    I2 = blockproc(B2,[8 8],invdct);
    I2 = uint16(I2);
    img_compress(:,:,i) = I2;
end

% geotiffwrite('Results\img_compress.tif',img_compress,R,'CoordRefSysCode',21417);
% disp('copmress')