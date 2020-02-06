% Detta script tar de hela mp3-filerna,
% skapar ny subfolder "train",
% l�gger in strofer i r�tt subfolder i train.
% 'train' kan sedan enkelt tas bort.

files = dir('*.')
subfolders = files(3:end);

mkdir train

for k = 1:length(subfolders)
   name = subfolders(k).name;
   mkdir('train', name)  
end
filtLen = 1000 %ms f�r l�nga filtret

for k = 1:length(subfolders) %g�r in i varje f�gelfolder
    name = subfolders(k).name;
    name
    cd(name);
    sounds = dir('*.mp3');
    for index = 1:length(sounds) %f�r varje mp3-fil, ta en, g� upp i pathen, anv�nd strophecut, spara i r�tt folder i 'train'
        
        [data, fs] = audioread(sounds(index).name);
        cd('..')
        [Xmat, Tmat, sampF] = strophecut(data, fs, filtLen); %tog bort decimate i strophecut s� att testk�rning kan funka
        
        cd('train')
        cd(name)
      stor = size(Xmat);
      lengthy = stor(2);
      for num = 1:lengthy
          fileName = strcat(name, num2str(index),'_',num2str(num),'.mp4');
          soundfile = Xmat(1:end, num);
          
          audiowrite(fileName, soundfile, fs);
          
      end
      cd('..')
      cd('..')
      cd(name)
    end
    cd('..')
    
    
end
cd('train')
