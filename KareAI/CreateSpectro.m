name = ".\Oskar";
faglar = ["bergfink","blames","bofink","grasparv","pilfink","talgoxe"];
dataPath = '..\Data';
addpath('..');
maxLen = 37882;



for type = 1:6
    %Find all files in subfolders of data
    T = dir(fullfile(dataPath,faglar(type),'*'));
    C = {T(~[T.isdir]).name};
    
    %for n = 1:1
    for n = 1:numel(C)
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
            nsc = floor(Ny/4.5);
            nov = floor(nsc/2);
            nff = max(256,2^nextpow2(nsc));

            img = abs(spectrogram(y,hamming(nsc),nov,nff));
            maxVal = max(max(img));
            minVal = min(min(img));
            img = (img-minVal)/(maxVal-minVal);
            imwrite(img,fullfile(name,faglar(type),n + "_" + syll + ".png"),'PNG');
        end
        
    end
    disp(faglar(type) + " done!"); 
    
end