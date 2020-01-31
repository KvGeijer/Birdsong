function [Xmat,Tmat,fs]=syllablecut(data0,fs,minsp,maxsp,extth,lev,Filtl,Filts)
%Gissar vad inputs betyder:
% data0: ljudfilen i form av vektor, detta det enda som beh?vs skickas in
% fs: sampling-frekvens, s?tts till 44100 hz om inget ges som input 
% minsp: is minimum space between syllables (ms)
% maxsp: is maxmum space between syllables (ms)
% extth: (ms) ?
% lev: Level of difference tolerated (in %)
% Fltl: ? Some filter
% Filts: ? Some filter


%S?tter samplingsfreq om inget ges
if nargin<2
    fs=44100;
end

%Sista sampeln med ljud.
%maxt=max(find(data0~=0));
maxt = find(data0~=0,1,'last');
data0=data0(1:maxt);

%Downsamplar med en faktor 4
data=decimate(data0,4);
fs=fs/4;


%figoff=1; %No figures show
figoff=0; %Figures show

%bets: min space between syllables (in samples).
%aets: maximum allowed syllable length (in samples).

Next=fix(extth*fs/1000); %+- extth ms extension from threshold level.
bets=minsp*fs/1000; % minsp ms is minimum space between syllables. 
aets=maxsp*fs/1000; % maxsp ms is maximum allowed syllable length.


%Nani? Filtrerar datan f?r att se var s?ng faktiskt ?r. Filts & Filtl kan
%s?ttas = 5 med 'ok' resultat. Men vet inte vad de b?r vara, ger varningar.
xpows=conv(ones(Filts,1)/Filts,data.^2);
xpows=xpows(Filts/2+1:length(data)+Filts/2);
xpowl=conv(ones(Filtl,1)/Filtl,data.^2);
xpowl=xpowl(Filtl/2+1:length(data)+Filtl/2);
t=[0:length(data)-1];


if figoff==0
figure
subplot(211)

plot(t/fs,[xpows xpowl],'LineWidth',2)
title('a) The two smoothing power filters, (blue,green), and detected samples above threshold (red)') 
ylabel('Amplitude^2')
xlabel('s')
hold on

end

lev=lev/100*max(xpowl); %Level above threshold for detected samples 


%Picks out the points where we think there are syllables
s=zeros(length(data),1);
for i=1:length(data)
 if (xpows(i)>xpowl(i)+lev)
    s(i)=1;
 end
end
ss=find(s==1);

if figoff==0
plot(ss/fs,xpows(ss),'r.')
xlabel('s')


hold off

subplot(212)

plot(t/fs,real(data))
xlabel('s')
title('Signal')
ylabel('Amplitude')
hold on
end


ss=[1;ss;length(data)];
sub=find(diff(ss)>bets);



%Maybe comment ou? Was before
for i=1:length(sub)-1
 if sub(i+1)-sub(i)>aets
   subadd=find(diff(ss([sub(i)+1:sub(i+1)-1]))>bets/2)+sub(i);
   sub=[sub;subadd];


 end
end

sub=sort(sub);

sylllim=0.1*max(max(abs(data)));
  
Xmat=zeros(6000,length(diff(sub)),2);    

for i=1:length(Xmat(1,:,1))
    in=[max(1,ss(sub(i)+1)-Next):min(length(data),ss(sub(i+1))+Next)];
    
    if figoff==0
    plot([min(in) max(in)]/fs,(-sylllim+sylllim/4*(-1)^i)*[1 1],'m X')
    plot([min(in) max(in)]/fs,(-sylllim+sylllim/4*(-1)^i)*[1 1],'m -')
    text(min(in)/fs-0.01,max(max(real(data))),int2str(i)) %Comment out
    axis([0 max(t)/fs min(data)*1.2 max(data)*1.2])
    title('b) Signal with detected syllables') %Comment out
    end
    xx=data(in);
    tt=in;
    Xmat(1:length(xx),i,1)=xx;
    Xmat(1:length(tt),i,2)=tt;
end


%if figoff==0
%hold off
%pause(0.5)
%sound(data0,44100)
%pause
%end
  

  
  