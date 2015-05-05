clear all;
% Num of detectors = 481
ndet = 251;
Tmax=36.4372;
dt = 2*Tmax./ndet;
A = 10;
B=10;
t=-Tmax:dt:Tmax;
rho = 1;
theta = 0:360./127:360;
theta = theta*2*pi./360;
% Projection of Ellipse
for i = 1:length(theta)
a(i)=sqrt(A^2*cos(theta(i))^2 + B^2*sin(theta(i))^2);
end
figure;
P = zeros(length(theta),length(t));
for i = 1:length(theta)
for j = 1:length(t)
    if(abs(t(j))<= a(i))
        P(i,j)=(2*rho*A*B*sqrt(a(i).^2-t(j).^2))./(a(i).^2);
    elseif(abs(t(j))>a(i))
        p(i,j)=0;
    else
        continue;
    end
end
end
imagesc(P);

    