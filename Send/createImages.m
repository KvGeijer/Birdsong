names = ["bergfink", "blames", "bofink", "grasparv", "pilfink", "talgoxe"];

for f = 1:size(names, 2)
    for i = 1:6
        y = audioread("sounds/" + names(f) + "/" + i + ".mp3");
        y = y(:, 1);
        
        
        figure1 = figure(1);
        axes1 = axes('Parent',figure1);
        hold(axes1,'all');
        
        spectrogram(y);
        saveas(figure1,"images/" + names(f) + "/" + i + ".png")
    end
end