clear
N = 10^6; %Num of bits/Symbols
Eb_N0_dB = [0:25]; %Range of Eb/No values
Tr = 2; nTr=4;
Rcvr = 2; nRcvr=4;
for i = 1:length(Eb_N0_dB)

%%%%%%%%%Transmitter
input = rand(1,N)>0.5; %Generating a random sequence
s = 2*input-1; %BPSK is being done such that 0 becomes -1 and 1 becomes 0

%2×2:
Modu_sig = kron(s,ones(Rcvr,1));
Modu_sig = reshape(Modu_sig,[Rcvr,Tr,N/Tr]); %grouping in [Rcvr,Tr,N/Tr ] matrix
h = 1/sqrt(2)*[randn(Rcvr,Tr,N/Tr) + j*randn(Rcvr,Tr,N/Tr)]; %Rayleigh channel
n = 1/sqrt(2)*[randn(Rcvr,N/Tr) + j*randn(Rcvr,N/Tr)]; %white gaussian noise with 0 dB variance
y = squeeze(sum(h.*Modu_sig,2)) + 10^(-Eb_N0_dB(i)/20)*n;

Coeff_h = zeros(2,2,N/Tr);
Coeff_h(1,1,:) = sum(h(:,2,:).*conj(h(:,2,:)),1); %d term
Coeff_h(2,2,:) = sum(h(:,1,:).*conj(h(:,1,:)),1); %a term
Coeff_h(2,1,:) = -sum(h(:,2,:).*conj(h(:,1,:)),1); %c term
Coeff_h(1,2,:) = -sum(h(:,1,:).*conj(h(:,2,:)),1); %b term
Den_h = ((Coeff_h(1,1,:).*Coeff_h(2,2,:)) - (Coeff_h(1,2,:).*Coeff_h(2,1,:))); %ad-bc term (det de matrix 2×2)
Den_h = reshape(kron(reshape(Den_h,1,N/Tr),ones(2,2)),2,2,N/Tr); %formatting for division
Inverse_h = Coeff_h./Den_h; %inv(H^H*H)
Modu_h = reshape(conj(h),Rcvr,N); %H^H operation
Modu_out = kron(y,ones(1,2)); %formatting the received symbol for equalization
Modu_out = sum(Modu_h.*Modu_out,1); %H^H * y
Modu_out = kron(reshape(Modu_out,2,N/Tr),ones(1,2)); %formatting
Hat_out = sum(reshape(Inverse_h,2,N).*Modu_out,1); %inv(H^H*H)*H^H*y
inputHat = real(Hat_out)>0;
Error(i) = size(find(input- inputHat),2);

%4×4:
ssMod = kron(s,ones(nRcvr,1));
ssMod = reshape(ssMod,[nRcvr,nTr,N/nTr]);
hh= 1/sqrt(2)*[randn(nRcvr,nTr,N/nTr) + j*randn(nRcvr,nTr,N/nTr)]; %Rayleigh channel 4×4
nn = 1/sqrt(2)*[randn(nRcvr,N/nTr) + j*randn(nRcvr,N/nTr)];
yy = squeeze(sum(hh.*ssMod,2)) + 10^(-Eb_N0_dB(i)/20)*nn;
hhCof = zeros(4,4,N/nTr) ;
hhCof(1,1,:) = (sum(hh(:,2,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,2,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,2,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,2,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1));
hhCof(1,2,:) = (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1));
hhCof(1,3,:) = (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1));
hhCof(1,4,:) = (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,3,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,3,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,3,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,3,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,3,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,3,:).*conj(hh(:,3,:)),1));
hhCof(2,1,:) = (sum(hh(:,2,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,2,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,2,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,2,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1));
hhCof(2,2,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1));
hhCof(2,3,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1));
hhCof(2,4,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,3,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,3,:).*conj(hh(:,1,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,3,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,3,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,3,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,3,:).*conj(hh(:,1,:)),1));
hhCof(3,1,:) = (sum(hh(:,2,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,2,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,2,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,2,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1));
hhCof(3,2,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1));
hhCof(3,3,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1));
hhCof(3,4,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,3,:).*conj(hh(:,2,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,3,:).*conj(hh(:,4,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,3,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,3,:).*conj(hh(:,4,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,4,:)),1) .* sum(hh(:,3,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,4,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,3,:).*conj(hh(:,2,:)),1));
hhCof(4,1,:) = (sum(hh(:,2,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,2,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,2,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,2,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,2,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1));
hhCof(4,2,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,3,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,3,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,3,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1));
hhCof(4,3,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,4,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,4,:).*conj(hh(:,1,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,4,:).*conj(hh(:,2,:)),1));
hhCof(4,4,:) = (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,3,:).*conj(hh(:,3,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,3,:).*conj(hh(:,1,:)),1))+ (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,3,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,1,:)),1).* sum(hh(:,2,:).*conj(hh(:,3,:)),1) .* sum(hh(:,3,:).*conj(hh(:,2,:)),1))- (sum(hh(:,1,:).*conj(hh(:,2,:)),1).* sum(hh(:,2,:).*conj(hh(:,1,:)),1) .* sum(hh(:,3,:).*conj(hh(:,3,:)),1))- (sum(hh(:,1,:).*conj(hh(:,3,:)),1).* sum(hh(:,2,:).*conj(hh(:,2,:)),1) .* sum(hh(:,3,:).*conj(hh(:,1,:)),1));

hhDenom = (hhCof(1,1,:).*hhCof(2,2,:).*hhCof(3,3,:).*hhCof(4,4,:))+(hhCof(1,1,:).*hhCof(2,3,:).*hhCof(3,4,:).*hhCof(4,2,:))+(hhCof(1,1,:).*hhCof(2,4,:).*hhCof(3,2,:).*hhCof(4,3,:))+(hhCof(1,2,:).*hhCof(2,1,:).*hhCof(3,4,:).*hhCof(4,3,:))+(hhCof(1,2,:).*hhCof(2,3,:).*hhCof(3,1,:).*hhCof(4,4,:))+(hhCof(1,2,:).*hhCof(2,4,:).*hhCof(3,3,:).*hhCof(4,1,:))+(hhCof(1,3,:).*hhCof(2,1,:).*hhCof(3,2,:).*hhCof(4,4,:))+(hhCof(1,3,:).*hhCof(2,2,:).*hhCof(3,4,:).*hhCof(4,1,:))+(hhCof(1,3,:).*hhCof(2,4,:).*hhCof(3,1,:).*hhCof(4,2,:))+(hhCof(1,4,:).*hhCof(2,1,:).*hhCof(3,3,:).*hhCof(4,2,:))+(hhCof(1,4,:).*hhCof(2,2,:).*hhCof(3,1,:).*hhCof(4,3,:))+(hhCof(1,4,:).*hhCof(2,3,:).*hhCof(3,2,:).*hhCof(4,1,:))-(hhCof(1,1,:).*hhCof(2,2,:).*hhCof(3,4,:).*hhCof(4,3,:))-(hhCof(1,1,:).*hhCof(2,3,:).*hhCof(3,2,:).*hhCof(4,4,:))-(hhCof(1,1,:).*hhCof(2,4,:).*hhCof(3,3,:).*hhCof(4,2,:))-(hhCof(1,2,:).*hhCof(2,1,:).*hhCof(3,3,:).*hhCof(4,4,:))-(hhCof(1,2,:).*hhCof(2,3,:).*hhCof(3,4,:).*hhCof(4,1,:))-(hhCof(1,2,:).*hhCof(2,4,:).*hhCof(3,1,:).*hhCof(4,3,:))-(hhCof(1,3,:).*hhCof(2,1,:).*hhCof(3,4,:).*hhCof(4,2,:))-(hhCof(1,3,:).*hhCof(2,2,:).*hhCof(3,1,:).*hhCof(4,4,:))-(hhCof(1,3,:).*hhCof(2,4,:).*hhCof(3,2,:).*hhCof(4,1,:))-(hhCof(1,4,:).*hhCof(2,1,:).*hhCof(3,2,:).*hhCof(4,3,:))-(hhCof(1,4,:).*hhCof(2,2,:).*hhCof(3,3,:).*hhCof(4,1,:))-(hhCof(1,4,:).*hhCof(2,3,:).*hhCof(3,1,:).*hhCof(4,2,:));
hhDenom = reshape(kron(reshape(hhDenom,1,N/nTr),ones(4,4)),4,4,N/nTr);
hhInv = hhCof./hhDenom;
hhMod = reshape(conj(hh),nRcvr,N);

yyMod = kron(yy,ones(1,4)); %formatting the received symbol for equalization
yyMod = sum(hhMod.*yyMod,1); %H^H * y
yyMod = kron(reshape(yyMod,4,N/nTr),ones(1,4)); %formatting
yyHat = sum(reshape(hhInv,4,N).*yyMod,1); %inv(H^H*H)*H^H*y

inputpHat = real(yyHat)>0;
%counting the errors

Erroror(i) = size(find(input- inputpHat),2);
end

BER = Error/N; %simulated ber
BERR = Erroror/N;
EbN0Lin = 10.^(Eb_N0_dB/10);
theoreticalBer_Rcvr1 = 0.5.*(1-1*(1+1./EbN0Lin).^(-0.5));
p = 1/2 - 1/2*(1+1./EbN0Lin).^(-1/2);
theoreticalBerMRC_Rcvr2 = p.^2.*(1+2*(1-p));

close all
figure
semilogy(Eb_N0_dB,theoreticalBer_Rcvr1,'bp-');
hold on
semilogy(Eb_N0_dB,theoreticalBerMRC_Rcvr2,'kd-');
semilogy(Eb_N0_dB,BER,'mo-');
semilogy(Eb_N0_dB,BERR,'r-*');
axis([0 25 10^-5 0.5])
grid on
legend('theoretical (Tr=1,Rcvr=1)', 'theoretical (Tr=1,Rcvr=2, MRC)', 'simulation (Tr=2, Rcvr=2, ZF)', 'simulation (Tr=4, Rcvr=4, ZF)');
xlabel('Average Eb/No,dB');
ylabel('BER');
title('BER for 4*4 MIMO and ZF equalizer');