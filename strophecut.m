function [Xmat, Tmat, fs] = strophecut(data, fs)
%Tgis is a function which takes one song as input (vector) and returns a
%matrix where coolumns represent small parts of the song (the syllables) as
%well as a separate matrix for the time points (maybe?) as well as fs.
% Note that this does not actually pick out syllables but actually song
% strophes.

%S?tter standard fs om inget anges
if nargin<2 
    fs = 44100;
end

%Tar bort all tysthet i slutet och b?rjan
maxt = find(data~=0,1,'last');
mint = find(data~=0,1,'first');
data=data(mint:maxt);

%Downsamplar med en faktor 4, beh?ver vi detta med s? lite indata?
data=decimate(data,4);
fs=fs/4;

%Skapar ett l?ngt och ett kort MA filter f?r att hitta syllables~
%Hur l?nga ska filtrerna vara i ms?
filtLongMs = 360;
filtShortMs = filtLongMs/4;
%Skapa filtrerna
filtLong = ones(filtLongMs,1)/filtLongMs;
filtShort = ones(filtShortMs,1)/filtShortMs;
% Filtrera kvadraten av datan med filtrerna
powDataLong = conv(data.^2,filtLong,'same');
powDataShort = conv(data.^2,filtShort,'same');
%Skapa tidsvektor f?r plots. I sekunder
t = (0:(length(data)-1))/fs;


%Hitta punkter med signifikant ljud
sign = zeros(length(data),1);
tol = 0.1;
tolErr = tol*max(powDataLong);

for ii = 1:length(data)
   if powDataShort(ii)>powDataLong(ii) + tolErr
       sign(ii) = 1;
   end
end

%Plot to understand and debugg
figure
subplot(411)
plot(t,data)
hold on
plot(t,sign,'*')
title('Nersamplad Orginaldata')
subplot(412)
plot(t,powDataLong)
title('Filtrerad med long MA filter')
subplot(413)
plot(t,powDataShort)
title('Filtrerad med short MA filter')
subplot(414)
plot(t,powDataShort-powDataLong)
title('Differens av filtrerade signaler')

%Spara index d?r s?ng finns.
indSign = find(sign==1); %L?gg till i b?rjan och slut?
indSign = [indSign;length(data)];
diffIndSign = diff(indSign);
%find all distances above a certain threshold. Corresponds to large spaces
%of no song = silence to separate strophes.
%Allowed lengths between.
minSpace = 0.25*fs;
%Find the indexes of where the stops start
stopIndSs = find(diffIndSign>minSpace);
stopInd = indSign(stopIndSs);

%Array of start indexes
startInd = indSign(stopIndSs+1);

%remove last startInd, ad first startInd
startInd = circshift(startInd,1);
startInd(1) = indSign(1);

%Cut out the strophes in columns of the X-matrix
Xmat = zeros(max(stopInd-startInd)+1,length(startInd));
%Pu the corr time values inside the T-matrix
Tmat = zeros(max(stopInd-startInd)+1,length(startInd));
for ii = 1:length(startInd)
    Xmat(1:(stopInd(ii)-startInd(ii)+1),ii) = data(startInd(ii):stopInd(ii));
    Tmat(1:(stopInd(ii)-startInd(ii)+1),ii) = t(startInd(ii):stopInd(ii));
end

%Plot to see teh final strophes
%Remember to trim all the zeros
figure
hold on;
title('Different cut out strophes')
for ii = 1:length(startInd)
   plot(Tmat(1:(stopInd(ii)-startInd(ii)),ii),Xmat(1:(stopInd(ii)-startInd(ii)),ii)); 
end
%Plot this if you want to see that the result matches the original
%plot(t,data,'k:','LineWidth',0.02)

end

