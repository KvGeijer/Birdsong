
cd('train');

birbs = dir('*.');
birbs = birbs(3:end);

for k = 1:length(birbs)
    name = birbs(k).name;
    cd(name)
    
    files = dir('*.mp4');
    
    largest = 0;
    indLarge = 0;
    
    for k = 1:length(files)
        [y, fs] = audioread(files(k).name);
        yLong = length(y);
        if (yLong>largest)
            largest = yLong;
            indLarge = k;
        end
    end
    
    largest;
    indLarge;
    %The largest of birbs is x sampel y index
    X = ['The largest of ', name, ' is ' num2str(largest), ' sample in index ', num2str(indLarge)];
    disp(X)
    cd('..')
    
end
cd('..')
