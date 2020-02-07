
samples = 10000;
samplingTime = 1;
imageSize = [75 100];

for type = 1:6
    for n = 1:samples
        y = SimulateBird(type, samplingTime);
        
        Ny = length(y);
        nsc = floor(Ny/4.5);
        nov = floor(nsc/2);
        nff = max(256,2^nextpow2(nsc));
        
        img = abs(spectrogram(y,hamming(nsc),nov,nff));
        maxVal = max(max(img));
        minVal = min(min(img));
        img = (img-minVal)/(maxVal-minVal);
        imwrite(img,"simulations/" + type + "/" + n + ".png",'PNG');
    end
    disp(type + " done!");
end