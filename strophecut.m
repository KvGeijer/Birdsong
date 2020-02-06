function [Xmat, Tmat, fs] = strophecut(data0, fs, filtLongLen, tol)
%Tgis is a function which takes one song as input (vector) and returns a
%matrix where coolumns represent small parts of the song (the syllables) as
%well as a separate matrix for the time points (maybe?) as well as fs.

%Input: Data: audio. fs: sampling freq. filtLen = length in ms of long
%filter. Tol is tolerance [0,1] where higher tol takes up more sound.

%Either send in all arguments or just data and fs.

%Convert to mono sound
data = data0(:,1);

%S?tter standard fs om inget anges


%Tar bort all tysthet i slutet och b?rjan
maxt = find(data~=0,1,'last');
mint = find(data~=0,1,'first');
data=data(mint:maxt);

%Downsamplar med en faktor 4, beh?ver vi detta med s? lite indata?
data=decimate(data,4);
fs=fs/4;


%Skapar ett l?ngt och ett kort MA filter f?r att hitta syllables~
%Hur l?nga ska filtrerna vara i ms?
if nargin <3 filtLongLen = 360; end
filtShortLen = filtLongLen/4;
filtLongLen = round(filtLongLen/1000*fs);
filtShortLen = round(filtShortLen/1000*fs);
%Skapa filtrerna
filtLong = ones(filtLongLen,1)/filtLongLen;
filtShort = ones(filtShortLen,1)/filtShortLen;
% Filtrera kvadraten av datan med filtrerna
powDataLong = conv(data.^2,filtLong,'same');
powDataShort = conv(data.^2,filtShort,'same');
%Skapa tidsvektor f?r plots. I sekunder
t = (0:(length(data)-1))/fs;


%Hitta punkter med signifikant ljud
sign = zeros(length(data),1);
%Tol kan justeras i inputs 
if nargin <3; tol = 0.95; end
tolErr = (1-tol)*max(powDataLong);

for ii = 1:length(data)
   if powDataShort(ii)>powDataLong(ii) + tolErr
       sign(ii) = 1;
   end
end



%Spara index d?r s?ng finns.
indSign = find(sign==1); %L?gg till i b?rjan och slut?
indSign = [indSign;length(data)];
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
%of no song = silence between separate strophes.
%Allowed lengths between.
minSpace = 0.06*fs;



%Find the indexes of where the stops start
stopIndSs = find(diffIndSign>minSpace);
stopInd = indSign(stopIndSs);

%Array of start indexes
startInd = indSign(stopIndSs+1);

%remove last startInd, ad first startInd
startInd = circshift(startInd,1);
startInd(1) = indSign(1);
if isempty(stopInd) 
    stopInd = indSign(end);
end

%Now we want to include sampes a bit to the left and right of the
%significant sounds. Default 0.5*minSpace to each side. (spaceExtension)
spaceExt = round(0.6*minSpace);
stopInd = stopInd+spaceExt;
if stopInd(end)>length(data); stopInd(end) = length(data); end
startInd = startInd-spaceExt;
if startInd(1)<1; startInd(1) = 1; end


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
subplot(414);
title('Different cut out strophes');
hold on
for ii = 1:length(startInd)
   plot(Tmat(1:(stopInd(ii)-startInd(ii)),ii),Xmat(1:(stopInd(ii)-startInd(ii)),ii)); 
end
%Plot this if you want to see that the result matches the original
%plot(t,data,'k:','LineWidth',0.02)

end

