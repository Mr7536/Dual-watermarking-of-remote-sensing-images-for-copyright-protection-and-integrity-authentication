% SSIM 结构相识度 或者 ssimval = ssim(A,ref) A度量图像，ref参考图像，两者必须是同样的格式
% 2维
function dSSIM=SSIM(X,Y) %返回值在0-1之间，数值越大，图像相似度越高。
X = normalize(X);
Y = normalize(Y);

X=double(X);
Y=double(Y);

ux=mean(mean(X));
uy=mean(mean(Y));

sigma2x=mean(mean((X-ux).^2));
sigma2y=mean(mean((Y-uy).^2));
sigmaxy=mean(mean((X-ux).*(Y-uy)));

k1=0.01;
k2=0.03;
L=255;
c1=(k1*L)^2;
c2=(k2*L)^2;
c3=c2/2;
%权重参数abr设置为1，1，1
l=(2*ux*uy+c1)/(ux*ux+uy*uy+c1);
c=(2*sqrt(sigma2x)*sqrt(sigma2y)+c2)/(sigma2x+sigma2y+c2);
s=(sigmaxy+c3)/(sqrt(sigma2x)*sqrt(sigma2y)+c3);

dSSIM=l*c*s;

end