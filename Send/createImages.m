names = ["bergfink", "blames", "bofink", "grasparv", "pilfink", "talgoxe"];
DataPath = '..\Data';

for f = 1:size(names, 2)
    for i = 1:6
        T = dir(fullfile(DataPath,names(f),'*'));
        C = {T(~[T.isdir]).name};
        y = audioread(fullfile(DataPath,names(f),C{i}));
        y = y(:, 1);
        
        
        figure1 = figure(1);
        axes1 = axes('Parent',figure1);
        hold(axes1,'all');
        
        spectrogram(y);
        saveas(figure1,"images/" + names(f) + "/" + i + ".png")
    end
end