%Minimum Mean Square Error equalization

clear
N = 10^6; %Num of bits/Symbols
Eb_N0_dB = [0:25]; %Range of Eb/No values
Tr = 2;
Rcvr = 2;
for i = 1:length(Eb_N0_dB)

    %%%%%%%%%Transmitter
    input = rand(1,N)>0.5; %Generating a random sequence
    s = 2*input-1; %BPSK is being done such that 0 becomes -1 and 1 becomes 0

    Modu_sig = kron(s,ones(Rcvr,1)); 
    Modu_sig = reshape(Modu_sig,[Rcvr,Tr,N/Tr]); %grouping in matrix

    h = 1/sqrt(2)*[randn(Rcvr,Tr,N/Tr) + j*randn(Rcvr,Tr,N/Tr)]; %Rayleigh channel
    n = 1/sqrt(2)*[randn(Rcvr,N/Tr) + j*randn(Rcvr,N/Tr)]; %white gaussian noise with 0 dB variance

    %%%%%%%%%%Noise being added to the channel
    y = squeeze(sum(h.*Modu_sig,2)) + 10^(-Eb_N0_dB(i)/20)*n;

    %%%%%%%%%%Receiver

    %Forming the MMSE equalization matrix W = inv(H^H*H+sigma^2*I)*H^H
    %Inverse of a [2x2] matrix [a b; c d] = 1/(ad-bc)[d -b;-c a]
    Coeff_h = zeros(2,2,N/Tr)  ; 
    Coeff_h(1,1,:) = sum(h(:,2,:).*conj(h(:,2,:)),1) + 10^(-Eb_N0_dB(i)/10);  %d term
    Coeff_h(2,2,:) = sum(h(:,1,:).*conj(h(:,1,:)),1) + 10^(-Eb_N0_dB(i)/10);  %a term
    Coeff_h(2,1,:) = -sum(h(:,2,:).*conj(h(:,1,:)),1); %c term
    Coeff_h(1,2,:) = -sum(h(:,1,:).*conj(h(:,2,:)),1); %b term
    Den_h = ((Coeff_h(1,1,:).*Coeff_h(2,2,:)) - (Coeff_h(1,2,:).*Coeff_h(2,1,:))); %ad-bc term
    Den_h = reshape(kron(reshape(Den_h,1,N/Tr),ones(2,2)),2,2,N/Tr);  %formatting for division
    Inverse_h = Coeff_h./Den_h; %inv(H^H*H)

    Modu_h =  reshape(conj(h),Rcvr,N); %H^H operation
    
    Modu_out = kron(y,ones(1,2)); %formatting the received symbol for equalization
    Modu_out = sum(Modu_h.*Modu_out,1); %H^H * y 
    Modu_out =  kron(reshape(Modu_out,2,N/Tr),ones(1,2)); %formatting
    Hat_out = sum(reshape(Inverse_h,2,N).*Modu_out,1); %inv(H^H*H)*H^H*y
   
    %receiver - hard decision decoding
    inputHat = real(Hat_out)>0;

    %counting the errors
    Error(i) = size(find([input- inputHat]),2);

end

BER = Error/N; %simulated ber
EbN0Lin = 10.^(Eb_N0_dB/10);
th_BER_Rcvr1 = 0.5.*(1-1*(1+1./EbN0Lin).^(-0.5)); 
p = 1/2 - 1/2*(1+1./EbN0Lin).^(-1/2);
th_BERMRC_Rcvr2 = p.^2.*(1+2*(1-p)); 

close all
figure
semilogy(Eb_N0_dB,th_BER_Rcvr1,'-.r*','LineWidth',2);
hold on
semilogy(Eb_N0_dB,th_BERMRC_Rcvr2,'-k*','LineWidth',2);
semilogy(Eb_N0_dB,BER,'-go','LineWidth',2);
axis([0 25 10^-5 0.5])
grid on
legend('theoretical (Tr=2,Rcvr=2, ZF)','theoretical (Tr=1,Rcvr=2, MRC)', 'simulation (Tr=2, Rcvr=2, MMSE)');
xlabel('Average Eb/No in dB');
ylabel('BER');
title('BER for MMSE equalizer');



