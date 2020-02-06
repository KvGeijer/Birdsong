padTo = 32767; %vilken sampellängd ska paddas till?

cd('train')
birbs = dir('*.');
birbs = birbs([3 6 7]); %bergfink, grasparv, pilfink

for k = 1:length(birbs)
    name = birbs(k).name;
    cd(name);
    
    files = dir('*.mp4')
    
    for k = 1:length(files)
   [y, fs] = audioread(files(k).name);
   diff = padTo - length(y);
   if (diff>0)
      zVec = zeros(diff, 1);
      data = [y; zVec];
      audiowrite(files(k).name, data, fs);
   end
    end
cd('..')
    
end
cd('..')