%Creates all spectrograms, zero-pads to get same dimension

faglar = ["bergfink","blames","bofink","grasparv","pilfink","talgoxe"];
dataPath = '..\Data';
addpath('..');
maxLen = 37882;

%For the two different types of spectrograms. The ones with 50% have bad
%resolution in time while the other ones are better.
mkdir('.\Oskar50%');
mkdir('.\Oskar2');
mkdir('.\Oskar50%syll');
mkdir('.\Oskar');
mkdir('.\results');

for type = 1:6
    %Find all files in subfolders of data
    T = dir(fullfile(dataPath,faglar(type),'*'));
    C = {T(~[T.isdir]).name};
    
    mkdir(fullfile('.\Oskar50%',faglar(type)));
    mkdir(fullfile('.\Oskar50%syll',faglar(type)));
    mkdir(fullfile('.\Oskar',faglar(type)));
    mkdir(fullfile('.\Oskar2',faglar(type)));
    
    %for n = 1:1
    for n = 1:numel(C)
        %Create one folder for each bird
        mkdir(fullfile('Oskar50%',faglar(type),num2str(n)));
        mkdir(fullfile('Oskar2',faglar(type),num2str(n)));
        %read file and get syllables
        F = fullfile(dataPath,faglar(type),C{n});
        [data,fs] = audioread(F);
        [Xmat,~,fs] = strophecut(data,fs);
        numSyll = length(Xmat(1,:));
        
        %Loop over all syllables and save their spectogram
        for syll = 1:numSyll
            %Make y the syllable, without zeros
            numPix = find(Xmat(:,syll)~=0,1,'last');
            y = zeros(maxLen,1);
            y(1:numPix) = Xmat(1:numPix,syll);
            
            Ny = length(y);
            nsc = floor(Ny/(256 - 0.5*(256 - 1)));
            nov = floor(nsc*(1 - 0.5));
            nff = max(nextpow2(nsc),256);

            img = abs(spectrogram(y,hamming(nsc),nov,nff));
            maxVal = max(max(img));
            minVal = min(min(img));
            img = (img-minVal)/(maxVal-minVal);
            
            imwrite(img, fullfile('Oskar50%',faglar(type),num2str(n), syll + ".png"),'PNG');
            imwrite(img, fullfile('Oskar50%syll',faglar(type),num2str(n) + "_" + syll + ".png"),'PNG');
            
            %Now again for bad rez
            Ny = length(y);
            nsc = floor(Ny/4.5);
            nov = floor(nsc/2);
            nff = max(256,2^nextpow2(nsc));

            img = abs(spectrogram(y,hamming(nsc),nov,nff));
            maxVal = max(max(img));
            minVal = min(min(img));
            img = (img-minVal)/(maxVal-minVal);
            
            imwrite(img,fullfile('Oskar2',faglar(type),num2str(n),syll + ".png"),'PNG');
            imwrite(img,fullfile('Oskar',faglar(type),num2str(n) + "_" + syll + ".png"),'PNG');
        end
        
    end
    disp(faglar(type) + " done!"); 
    
end