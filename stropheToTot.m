function [Xvec,fs,Xmat,Tmat] = stropheToTot(data,fs,filtLongLen, tol)
%Using strophecut we return the song but without all the 'not important'
%parts.

%Do you want to plot shit?
figOn = 1;

if nargin <3
   [Xmat,Tmat,fsnew] = strophecut(data,fs); 
else
   [Xmat,Tmat,fsnew] = strophecut(data,fs,filtLongLen,tol); 
end
Imat = round(Tmat*fsnew);

%Find how many samples we want and create Xvec
lastInd = find(Imat(:,end)~=0,1,'last');
Xvec = zeros(Imat(lastInd,end),1);

for k = 1:length(Xmat(1,:))
    lastInd = find(Imat(:,k)~=0,1,'last');
    Xvec(Imat(1:lastInd,k)) = Xmat(1:lastInd,k);
end

%remove zeros at start and end
first = find(Xvec~=0,1,'first');
last = find(Xvec~=0,1,'last');
Xvec = Xvec(first:last);

if figOn==1
    figure
    subplot(211);
    %plot((1:length(Xvec))/fsnew,Xvec)
    plot(Xvec);
    subplot(212);
    plot((1:length(data))/fs,data);
end

end

