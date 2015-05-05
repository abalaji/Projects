
% [input h1]=readda('crc_proj.da');
% [output h2]=readda('crc_fproj.da');
% [myfilter h3]=readda('my_filter.da');
% [fftfilter h4]=readda('fft_filter.da');
ndet = 252;
%N_N = 512;
%fs = 1/N_N;
% dt = fs;
Tmax=36.4372;
%dt = 3.458580;
dt = ndet/(2*Tmax);
tu = dt;
n=1:1:128*4;

N = -64*4:1:64*4-1;
for i =1:length(n)
    if(N(i) ==0)
        h(i)= 1/(4*(tu^2));
    elseif (mod(N(i),2)==0)
        h(i)= 0;
    else
        h(i)=-1/(N(i)^2*pi^2*tu^2);
    end
end

h=ifftshift(h)*dt*pi;
% plot(h);hold; plot(myfilter,'r');
input_padded = zeros(128,512);
input_padded(:,1:252)=input;

for i=1:128
    Q1(i,:) = real(ifft(fft(input_padded(i,:),512,2).*fft(h),512,2));
end
Qout = zeros(128,252);
Qout = Q1(:,1:252);
figure
plot(Qout(1,:)); hold; plot(output(1,:),'r');


        