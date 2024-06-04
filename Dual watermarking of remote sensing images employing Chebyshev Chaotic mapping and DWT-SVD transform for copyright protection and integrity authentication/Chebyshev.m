%Chebyshev

function output_value = Chebyshev(x,times)
k=4;
for i=2:times
    x(i)=cos(k.*acos(x(i-1)));
    y(i)=1-2*(cos(2*acos(x(i)))).^2; 
end

output_value = x(i);
end