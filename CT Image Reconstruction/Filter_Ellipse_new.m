input = P;
ndet = 252;
Tmax=36.4372;
%dt = 3.458580;
 dt = ndet/(2*Tmax);
tu = dt;
nviews = length(theta);
n=1:1:nviews*4;

N = -(nviews/2)*4:1:(nviews/2)*4-1;
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
% w = 0.54 -0.46*cos(2*pi*n/(ndet-1));
input_padded = zeros(nviews,length(n));
input_padded(:,1:ndet)=input;
for i=1:nviews
    Q1(i,:) = real(ifft(fft(input_padded(i,:),length(n),2).*fft(h,length(n),2),length(n),2));
end
Qout = zeros(nviews,ndet);
Qout = Q1(:,1:ndet);



        