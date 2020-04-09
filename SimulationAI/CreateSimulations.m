
samples = 1000;
samplingTime = 1;
imageSize = [75 100];

% Spectrogram Paramters
overlap = [.5, .9];
n_win = [9, 1024];
minFreqSize = [4096, 256];
folderName = ["simulations_freq", "simulations_time", "simulations_sound"];

for type = 1:6
    for k = 1:3
        if (~exist(folderName(k) + "/" + type, 'dir'))
            mkdir(folderName(k), string(type));
        end
    end
    for n = 1:samples
        y = SimulateBird(type, samplingTime);
        
        for k = 1:2
            Ny = length(y);
            nsc = floor(Ny/(n_win(k) - overlap(k)*(n_win(k) - 1)));
            nov = floor(nsc*(1 - overlap(k)));
            nff = max(minFreqSize(k)*2,2^nextpow2(nsc));

            img = abs(spectrogram(y,hamming(nsc),nov,nff));
            maxVal = max(max(img));
            minVal = min(min(img));
            img = (img-minVal)/(maxVal-minVal);
            imwrite(img, folderName(k) + "/" + type + "/" + n + ".png",'PNG');
        end
        for k = 3:3
            img = y';
            maxVal = max(max(img));
            minVal = min(min(img));
            img = (img-minVal)/(maxVal-minVal);
            imwrite(img, folderName(k) + "/" + type + "/" + n + ".png",'PNG');
        end
    end
    disp(type + " done!");
end