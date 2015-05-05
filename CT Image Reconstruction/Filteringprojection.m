close all;
clear all;
[input h1]=readda('crc_proj.da');
[output h2]=readda('crc_fproj.da');

ndet = 252;
Tmax=40;
dt = 3.458580;
%dt = inv(ndet/2*Tmax);
tu = dt;
n=1:1:252;
%N = -(length(t)-1)/2:1:(length(t)-1)/2;
 N = -126:1:125;
for i =1:length(n)
    if(N(i) ==0)
        h(i)= 1/(4*(tu^2));
    elseif (mod(N(i),2)==0)
        h(i)= 0;
    else
        h(i)=-1/(N(i)^2*pi^2*tu^2);
    end
end
figure;
plot(h);
figure
h=ifftshift(h)*dt*pi;
plot(h);
figure;
plot((input(1,:)))
% Q1=zeros(length(theta),length(t));
%  Q1=zeros(length(theta),1024);
% figure;

for i=1:128
    Q1(i,:) = tu * real(ifft(fft(input(i,:)).*fft(h)));
    
%     Q1(i,:) = tu * real(ifft(ifftshift(fft(fftshift(P(i,:))).*fft(fftshift(h)))));
    
end
% figure;
% imagesc(Q1)
figure
plot(Q1(1,:)); hold; plot(output(1,:),'r');
%     drawnow

        