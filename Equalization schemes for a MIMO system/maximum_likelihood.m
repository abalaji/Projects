%Maximum Likelihood equalization
clear
N = 10^6; %num of bits/symbols
Eb_N0_dB = [0:25]; %Range of Eb/No values
Tr = 2;
Rcvr = 2;
for i = 1:length(Eb_N0_dB)

    %%%%%%%%%Transmitter
    input = rand(1,N)>0.5; %Generating 0,1 with equal probability
    s = 2*input-1; %BPSK is being done such that 0 becomes -1 and 1 becomes 0
    Modu_sig = kron(s,ones(Rcvr,1)); %
    Modu_sig = reshape(Modu_sig,[Rcvr,Tr,N/Tr]); %grouping in [Rcvr,Tr,N/Tr ]matrix

    h = 1/sqrt(2)*[randn(Rcvr,Tr,N/Tr) + j*randn(Rcvr,Tr,N/Tr)]; %Rayleigh channel
    n = 1/sqrt(2)*[randn(Rcvr,N/Tr) + j*randn(Rcvr,N/Tr)]; %white gaussian noise with 0 dB variance

    %%%%%%%%%%Noise being added to the channel
    y = squeeze(sum(h.*Modu_sig,2)) + 10^(-Eb_N0_dB(i)/20)*n;

    %Maximum Likelihood Receiver
    %if [s1 s2 ] = [+1,+1 ]
    sHat1 = [1 1];	
    sHat1 = repmat(sHat1,[1 ,N/2]);
    sHat1Mod = kron(sHat1,ones(Rcvr,1));	
    sHat1Mod = reshape(sHat1Mod,[Rcvr,Tr,N/Tr]);	
    zHat1 = squeeze(sum(h.*sHat1Mod,2)) ;
    J11 = sum(abs(y - zHat1),1);
    
    %if [s1 s2 ] = [+1,-1 ]
    sHat2 = [1 -1];	
    sHat2 = repmat(sHat2,[1 ,N/2]);
    sHat2Mod = kron(sHat2,ones(Rcvr,1));	
    sHat2Mod = reshape(sHat2Mod,[Rcvr,Tr,N/Tr]);	
    zHat2 = squeeze(sum(h.*sHat2Mod,2)) ;
    J10 = sum(abs(y - zHat2),1);
    
    %if [s1 s2 ] = [-1,+1 ]
    sHat3 = [-1 1];	
    sHat3 = repmat(sHat3,[1 ,N/2]);
    sHat3Mod = kron(sHat3,ones(Rcvr,1));	
    sHat3Mod = reshape(sHat3Mod,[Rcvr,Tr,N/Tr]);	
    zHat3 = squeeze(sum(h.*sHat3Mod,2)) ;
    J01 = sum(abs(y - zHat3),1);
    
    %if [s1 s2 ] = [-1,-1 ]
    sHat4 = [-1 -1];	
    sHat4 = repmat(sHat4,[1 ,N/2]);
    sHat4Mod = kron(sHat4,ones(Rcvr,1));	
    sHat4Mod = reshape(sHat4Mod,[Rcvr,Tr,N/Tr]);	
    zHat4 = squeeze(sum(h.*sHat4Mod,2)) ;
    J00 = sum(abs(y - zHat4),1);
    
    %finding the minimum from the four alphabet combinations 
    rVec = [J11;J10;J01;J00];
    [jj dd] = min(rVec,[],1);

    %mapping the minima to bits
    ref = [1 1; 1 0; 0 1; 0 0 ];
    inputHat = zeros(1,N);
    inputHat(1:2:end) = ref(dd,1);
    inputHat(2:2:end) = ref(dd,2);

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
semilogy(Eb_N0_dB,BER,':bs','LineWidth',2);
axis([0 25 10^-5 0.5])
grid on
legend('theoretical (Tr=2,Rcvr=2)', 'theoretical (Tr=1,Rcvr=2, MRC)', 'simulation (Tr=2, Rcvr=2, ML)');
xlabel('Average Eb/No,dB');
ylabel('BER');
title('BER for ML equalizer');




