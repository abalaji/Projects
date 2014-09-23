%Minimum Mean Square Error Equalization with Successive Interference Cancellation (ZF-SIC) with optimal ordering 
clear
N =  10^6; %Num of bits/Symbols
Eb_N0_dB = 0:25; %Range of Eb/No values
Tr = 2;
Rcvr = 2;
for i = 1:length(Eb_N0_dB)

    %%%%%%%%%Transmitter
    input = rand(1,N)>0.5; %Generating a random sequence
    s = 2*input-1; %BPSK is being done such that 0 becomes -1 and 1 becomes 0
    Modu_sig = kron(s,ones(Rcvr,1));  
    Modu_sig = reshape(Modu_sig,[Rcvr,Tr,N/Tr]); %grouping in [Rcvr,Tr,N/Tr ] matrix
    
    h = 1/sqrt(2)*randn(Rcvr,Tr,N/Tr) + j*randn(Rcvr,Tr,N/Tr); %Rayleigh channel
    n = 1/sqrt(2)*randn(Rcvr,N/Tr) + j*randn(Rcvr,N/Tr); %white gaussian noise with 0 dB variance

    %%%%%%%%%%Noise being added to the channel
    y = squeeze(sum(h.*Modu_sig,2)) + 10^(-Eb_N0_dB(i)/20)*n;

    %%%%%%%%%%Receiver
    %----------
    %Forming the MMSE equalization matrix W = inv(H^H*H + sigma^2*I)*H^H
    %Inverse of a [2x2] matrix [a b; c d] = 1/(ad-bc)[d -b;-c a]
    Coeff_h = zeros(2,2,N/Tr)  ; 
    Coeff_h(1,1,:) =  sum(h(:,2,:).*conj(h(:,2,:)),1) + 0*10^(-Eb_N0_dB(i)/10);  %d term
    Coeff_h(2,2,:) =  sum(h(:,1,:).*conj(h(:,1,:)),1) + 0*10^(-Eb_N0_dB(i)/10);  %a term
    Coeff_h(2,1,:) = -sum(h(:,2,:).*conj(h(:,1,:)),1); %c term
    Coeff_h(1,2,:) = -sum(h(:,1,:).*conj(h(:,2,:)),1); %b term
    
    for kk = 1:2
       if kk == 1
          sortIdx = [];
    	  Coeff_h(1,1,:) =  sum(h(:,2,:).*conj(h(:,2,:)),1) + 10^(-Eb_N0_dB(i)/10);  %d term
          Coeff_h(2,2,:) =  sum(h(:,1,:).*conj(h(:,1,:)),1) + 10^(-Eb_N0_dB(i)/10);  %a term
          Coeff_h(2,1,:) = -sum(h(:,2,:).*conj(h(:,1,:)),1); %c term
          Coeff_h(1,2,:) = -sum(h(:,1,:).*conj(h(:,2,:)),1); %b term
       elseif kk == 2
          %Sorting the equalization matrix based on the channel power on each dimension
          %since the second spatial dimension is equalized first, the channel
          %with higher power assigned to second dimension
          normSS1 = squeeze(Coeff_h(2,2,:));
    	  normSS2 = squeeze(Coeff_h(1,1,:));
    	  sortIdx = find(normSS2 < normSS1);
       end

   
        %sorting the H^H*H  + sigma^2*I matrix 
        hCofSort = Coeff_h;
        if ~isempty(sortIdx)
            hCofSort(2,2,sortIdx) = Coeff_h(1,1,sortIdx) + 10^(-Eb_N0_dB(i)/10);
      	    hCofSort(1,1,sortIdx) = Coeff_h(2,2,sortIdx) + 10^(-Eb_N0_dB(i)/10);;
    	    hCofSort(1,2,sortIdx) = Coeff_h(2,1,sortIdx);
    	    hCofSort(2,1,sortIdx) = Coeff_h(1,2,sortIdx);
        end
        Den_h = ((hCofSort(1,1,:).*hCofSort(2,2,:)) - (hCofSort(1,2,:).*hCofSort(2,1,:))); %ad-bc term
        Den_h = reshape(kron(reshape(Den_h,1,N/Tr),ones(2,2)),2,2,N/Tr);  %formatting for division
        hInvSort = hCofSort./Den_h; %inv(H^H*H)

        %sorting the H matrix
        hSort = h;
        if ~isempty(sortIdx)
    	    hSort(:,2,sortIdx) = h(:,1,sortIdx);
    	    hSort(:,1,sortIdx) = h(:,2,sortIdx);
        end

        %Equalization - Zero forcing
        hModSort =  reshape(conj(hSort),Rcvr,N); %H^H operation
    
        yModSort = kron(y,ones(1,2)); %formatting the received symbol for equalization
        yModSort = sum(hModSort.*yModSort,1); %H^H * y 
        yModSort =  kron(reshape(yModSort,2,N/Tr),ones(1,2)); %formatting
        yHatSort = sum(reshape(hInvSort,2,N).*yModSort,1); %inv(H^H*H)*H^H*y

        %receiver - hard decision decoding on second spatial dimension
        inputHat2SS = real(yHatSort(2:2:end))>0;
        inputHatMod2SS = 2*inputHat2SS-1;
        inputHatMod2SS = kron(inputHatMod2SS,ones(Rcvr,1));
        inputHatMod2SS = reshape(inputHatMod2SS,[Rcvr,1,N/Tr]);

        %new received symbol - removing the effect from second spatial dimension
        h2SS = hSort(:,2,:); %channel in the second spatial dimension
        r = y - squeeze(h2SS.*inputHatMod2SS);

        %maximal ratio combining - for symbol in the first spatial dimension
        h1SS = squeeze(hSort(:,1,:));
        yHat1SS = sum(conj(h1SS).*r,1)./sum(h1SS.*conj(h1SS),1);
        yHatSort(1:2:end) = yHat1SS;
  
        yHatSort = reshape(yHatSort,2,N/2) ;
        if ~isempty(sortIdx)
            yHatSort(:,sortIdx) = flipud(yHatSort(:,sortIdx));
        end
        Hat_out = reshape(yHatSort,1,N);

        %receiver - hard decision decoding
        inputHat = real(Hat_out)>0;

        %counting the errors
        Error(kk,i) = size(find([input- inputHat]),2);

    end

end

BER = Error/N; %simulated ber
EbN0Lin = 10.^(Eb_N0_dB/10);
th_BER_Rcvr1 = 0.5.*(1-1*(1+1./EbN0Lin).^(-0.5)); 
p = 1/2 - 1/2*(1+1./EbN0Lin).^(-1/2);
th_BERMRC_Rcvr2 = p.^2.*(1+2*(1-p)); 

close all
semilogy(Eb_N0_dB,th_BER_Rcvr1,'-.r*','LineWidth',2);
hold on
semilogy(Eb_N0_dB,th_BERMRC_Rcvr2,'-k*','LineWidth',2);
semilogy(Eb_N0_dB,BER(1,:),'-go','LineWidth',2);
semilogy(Eb_N0_dB,BER(2,:),':bs','LineWidth',2);
axis([0 25 10^-5 0.5])
grid on
legend('theoretical (Tr=2,Rcvr=2, ZF)', 'theoretical (Tr=1,Rcvr=2, MRC)', 'simulation (Tr=2, Rcvr=2, MMSE-SIC)','simulation (Tr=2, Rcvr=2, MMSE-SIC-OO)');
xlabel('Average Eb/No,dB');
ylabel('BER');
title('BER for MMSE-SIC equalizer');

