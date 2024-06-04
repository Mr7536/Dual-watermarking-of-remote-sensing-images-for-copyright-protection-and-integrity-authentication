%nc(归一化相关系数)
function dNC = nc(ImageA,ImageB)
 
if (size(ImageA,1) ~= size(ImageB,1)) || (size(ImageA,2) ~= size(ImageB,2))
    disp('ImageA ~= ImageB');
    dNC = 0;
else
    ImageA=double(ImageA);
    ImageB=double(ImageB);
    M = size(ImageA,1);
    N = size(ImageA,2);
    d1=0 ;
    d2=0;
    d3=0;
    for i = 1:M
        for j = 1:N
            d1=d1+ImageA(i,j)*ImageB(i,j) ;
            d2=d2+ImageA(i,j)*ImageA(i,j) ;
            d3=d3+ImageB(i,j)*ImageB(i,j) ;
        end
    end
    dNC=d1/(sqrt(d2)*sqrt(d3));
end


