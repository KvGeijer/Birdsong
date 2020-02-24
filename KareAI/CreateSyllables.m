%Creates syllables (!and whole ballades), with added zeros so they all fit
%together

faglar = ["bergfink","blames","bofink","grasparv","pilfink","talgoxe"];
dataPath = '..\Data';
addpath('..');
maxLenSyll = 37882;
%maxLenBallad = 7858416;

mkdir('.\Syllables');
mkdir('.\SyllablesSubs');
%mkdir('.\Ballader');


for type = 1:6
    %Find all files in subfolders of data
    T = dir(fullfile(dataPath,faglar(type),'*'));
    C = {T(~[T.isdir]).name};
    
    mkdir(fullfile('.\Syllables',faglar(type)));
    mkdir(fullfile('.\SyllablesSubs',faglar(type)));
    %mkdir(fullfile('.\Ballader',faglar(type)));
    
    %for n = 1:1
    for n = 1:numel(C)
        %Create one folder for each bird
        mkdir(fullfile('SyllablesSubs',faglar(type),num2str(n)));
        %read file and get syllables
        F = fullfile(dataPath,faglar(type),C{n});
        [data,fs] = audioread(F);
        [Xmat,~,fs] = strophecut(data,fs);
        numSyll = length(Xmat(1,:));
        
        %Loop over all syllables and save their spectogram
        for syll = 1:numSyll
            %Make y the syllable, without zeros
            numPix = find(Xmat(:,syll)~=0,1,'last');
            y = zeros(maxLenSyll,1);
            y(1:numPix) = Xmat(1:numPix,syll);
            
            
            imwrite(y, fullfile('SyllablesSubs',faglar(type),num2str(n), syll + ".png"),'PNG');
            imwrite(y, fullfile('Syllables',faglar(type),num2str(n) + "_" + syll + ".png"),'PNG');
            
        end
        %did not work since they were too large
        %ballad = [data;zeros(maxLenBallad-length(data),1)];
        %imwrite(ballad,fullfile('Ballader',faglar(type),num2str(n) + ".png"),'PNG');
        
    end
    disp(faglar(type) + " done!"); 
    
end