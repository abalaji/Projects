% Back Projection
Q=Qout;
%[X,Y]=meshgrid(1:512,1:512);
fov = 30;
nx=128;
dx = fov./nx;
dy = fov./nx;
x = -fov/2:dx:(fov/2-dx);
y = -fov/2:dy:(fov/2-dy);
f = zeros(nx,nx);
%%%%%%% changing t
% ndet1 = 1024;
% Tmax1=40;
% dt1 = 2*Tmax1./(ndet1-1);
% t1=-Tmax1:dt1:Tmax1;
%%%%%%%%%%%%%%%%%%%%%%%%%

for x_ind=1:nx
    for y_ind=1:nx
        for i = 1:length(theta)
            tval = x(x_ind)*cos(theta(i))+y(y_ind)*sin(theta(i));
            qint = interp1(t,Q(i,:),tval,'linear',0);
            f(x_ind,y_ind)=qint+f(x_ind,y_ind);
        end
        f(x_ind,y_ind) = f(x_ind,y_ind)./length(theta);
    end
    x_ind
end
imagesc(f);


