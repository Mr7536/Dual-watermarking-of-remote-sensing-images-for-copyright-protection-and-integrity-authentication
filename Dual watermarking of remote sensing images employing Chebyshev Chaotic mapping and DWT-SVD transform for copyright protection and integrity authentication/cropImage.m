

%输入cropImage，裁剪多余空白部分
function  outputImage=cropImage(cropImage)
[row,col]=find(cropImage(:,:,1)~=0);
xMIN =min(row);xMAX =max(row);
yMIN =min(col);yMAX =max(col);
outputImage = cropImage(xMIN:xMAX,yMIN:yMAX,:);
end