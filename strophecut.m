function [Xmat, Tmat, fs] = strophecut(data0, fs, filtLongLen, tol)
%This function cuts out syllables (or strophes if you change settings).

%Output: Xmat is a matrix where the columns are the syllables extracted
%from the input. Tmat is a matrix where the columns store the associated
%time values to all values in Xmat. fs is the sampling frequency.

%Input: data0 is the vector with sound data, gotten from audioread. fs is
%the sampling frequency. data0 and fs are required inputs.
%If extra customization is wanted filtLongLen is the length (in ms) that
%the long MA filter has (standard 360 ms). tol is the tolerance (0:1)
%wanted (standard 0.9), higher tol equals more significant sounds picked out.
%Either data0 and fs are sent in or all 4 values

%Either send in all arguments or just data and fs.

%Convert to mono sound
data = data0(:,1);


%Tar bort all tysthet i slutet och b?rjan
maxt = find(data~=0,1,'last');
mint = find(data~=0,1,'first');
data=data(mint:maxt);

%Downsamplar med en faktor 4, beh?ver vi detta med s? lite indata?
data=decimate(data,4);
fs=fs/4;


%Creates a long and short MA filter to find significant sounds.
if nargin <3 filtLongLen = 360; end
filtShortLen = filtLongLen/4;
filtLongLen = round(filtLongLen/1000*fs);
filtShortLen = round(filtShortLen/1000*fs);
%Create the filters
filtLong = ones(filtLongLen,1)/filtLongLen;
filtShort = ones(filtShortLen,1)/filtShortLen;
%Filter the square of the data with the filters.
powDataLong = conv(data.^2,filtLong,'same');
powDataShort = conv(data.^2,filtShort,'same');
%Create time vector for plots
t = (0:(length(data)-1))/fs;



%Set the required deviation from short filter to long filter
if nargin <3; tol = 0.95; end
reqDev = (1-tol)*max(powDataLong);

%Find points with significant sound
sign = zeros(length(data),1);

for ii = 1:length(data)
   if powDataShort(ii)>powDataLong(ii) + reqDev
       sign(ii) = 1;
   end
end



%Save indexes with significant sound
indSign = find(sign==1);
indSign = [indSign;length(data)];
%This is to find the space between sounds
diffIndSign = diff(indSign);

%Plot to understand and debugg
figure;
subplot(411);
plot(t,data);
title('Nersamplad Orginaldata');
subplot(412);
plot(t,data);
hold on;
plot(indSign/fs,data(indSign),'.','LineWidth',0.005);
title('Signifikant orginaldata');
subplot(413);
plot(t,powDataShort-powDataLong);
title('Differens av filtrerade signaler');


%find all distances above a certain threshold. Corresponds to large spaces
%of no song = silence between separate syllables/strophes.

%Allowed lengths between sounds.
minSpace = 0.06*fs;



%Find the indexes of where the stops start and save them
stopIndSs = find(diffIndSign>minSpace);
stopInd = indSign(stopIndSs);

%Array of start indexes
startInd = indSign(stopIndSs+1);

%remove last startInd, ad first startInd
startInd = circshift(startInd,1);
startInd(1) = indSign(1);

%Check for strage special case where no sound is picked up
if isempty(stopInd) 
    stopInd = indSign(end);
end

%Now we want to include sampes a bit to the left and right of the
%significant sounds. Default 0.6*minSpace to each side. Also check if sound
%at edges cause errors.
spaceExt = round(0.6*minSpace);
stopInd = stopInd+spaceExt;
if stopInd(end)>length(data); stopInd(end) = length(data); end
startInd = startInd-spaceExt;
if startInd(1)<1; startInd(1) = 1; end


%Cut out the strophes in columns of the X-matrix
Xmat = zeros(max(stopInd-startInd)+1,length(startInd));
%Put the corr time values inside the T-matrix
Tmat = zeros(max(stopInd-startInd)+1,length(startInd));
for ii = 1:length(startInd)
    Xmat(1:(stopInd(ii)-startInd(ii)+1),ii) = data(startInd(ii):stopInd(ii));
    Tmat(1:(stopInd(ii)-startInd(ii)+1),ii) = t(startInd(ii):stopInd(ii));
end

%Plot to see teh final strophes
%Remember to trim all the zeros
subplot(414);
title('Different cut out strophes');
hold on
for ii = 1:length(startInd)
   plot(Tmat(1:(stopInd(ii)-startInd(ii)),ii),Xmat(1:(stopInd(ii)-startInd(ii)),ii)); 
end
%Plot this if you want to see that the result matches the original
%plot(t,data,'k:','LineWidth',0.02)

end

