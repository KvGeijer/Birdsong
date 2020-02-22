% This script should run the following and save their results:
%   Spectrogram of 3 birds, bad time rez
%   Spectrogram of 3 birds, good time rez
%   Spectrogram of 6 birds, bad time rez
%   Spectrogram of 6 birds, good time rez
% Note, this is when looking at individual birds
% They should all return results of how well it classes different birds, as
% well as syllable validation rate.
% Each thing should run at least 10 times at 40 epochs.

folders = cell(4,1);
folders{1} = {'.\Oskar2\bofink';'.\Oskar2\grasparv';'.\Oskar2\talgoxe'};
folders{2} = {'.\Oskar50%\bofink';'.\Oskar50%\grasparv';'.\Oskar50%\talgoxe'};
folders{3} = {'.\Oskar2\bergfink';'.\Oskar2\blames';'.\Oskar2\bofink';'.\Oskar2\grasparv';'.\Oskar2\pilfink';'.\Oskar2\talgoxe'};
folders{4} = {'.\Oskar50%\bergfink';'.\Oskar50%\blames';'.\Oskar50%\bofink';'.\Oskar50%\grasparv';'.\Oskar50%\pilfink';'.\Oskar50%\talgoxe'};

names = cell(4,1);
names{1} = ["bofink";"grasparv";"talgoxe"];
names{2} = ["bofink";"grasparv";"talgoxe"];
names{3} = ["bergfink";"blames";"bofink";"grasparv";"pilfink";"talgoxe"];
names{4} = ["bergfink";"blames";"bofink";"grasparv";"pilfink";"talgoxe"];



%First arg: type
%Second: rep
%Third: 1:accuracy syllables, 2:accuracy syllable matrix 3:accuracy birds matrix
results = cell(4,20,3);

for type = 1:4
    for rep = 1:20
        % Set up imdsValidation and imdsTrain
        amountBirds = length(folders{type});
        
        trainFiles = [];
        trainLabels = [];
        testFiles = [];
        testLabels = [];
        
        for k = 1:amountBirds
            [imdsTrainLoop, imdsTestLoop] = imdata(folders{type}{k},names{type}(k));
            
            trainFiles = [trainFiles;imdsTrainLoop.Files];
            trainLabels = [trainLabels;imdsTrainLoop.Labels];
            testFiles = [testFiles;imdsTestLoop.Files];
            testLabels = [testLabels;imdsTestLoop.Labels];
        end
        
        imdsTrain = imageDatastore(trainFiles);
        imdsTrain.Labels = trainLabels;

        imdsTest = imageDatastore(testFiles);
        imdsTest.Labels = testLabels;

        labelCount = countEachLabel(imdsTrain);

        numFiles = min(labelCount.Count);
        numTrain = round(numFiles*0.8);
        numVal = numFiles-numTrain;
        [imdsTrain, imdsValidation] = splitEachLabel(imdsTrain,numTrain,numVal,'randomize');

        imgSize = size(readimage(imdsTrain,1));

        layers = [
            imageInputLayer([imgSize(1) imgSize(2) 1])
    
            convolution2dLayer(3,8,'Padding','same')
            batchNormalizationLayer
            reluLayer

            maxPooling2dLayer(2,'Stride',2)

            convolution2dLayer(3,16,'Padding','same')
            batchNormalizationLayer
            reluLayer

            maxPooling2dLayer(2,'Stride',2)

            convolution2dLayer(3,32,'Padding','same')
            batchNormalizationLayer
            reluLayer

            fullyConnectedLayer(size(labelCount, 1))
            softmaxLayer
            classificationLayer];
        
        options = trainingOptions('sgdm', ...
            'InitialLearnRate',0.01, ...
            'MaxEpochs',25, ...
            'Shuffle','every-epoch', ...
            'ValidationData',imdsValidation, ...
            'ValidationFrequency',4, ...
            'Verbose',false, ...
            'ExecutionEnvironment', 'auto');
        
        net = trainNetwork(imdsTrain,layers,options);
        
        YPred = classify(net,imdsTest);
        YTest = imdsTest.Labels;
        results{type,rep,1} = sum(YPred == YTest)/numel(YTest);
        results{type,rep,2} = CheckNetSyll(net,imdsTest);
        results{type,rep,3} = CheckNet(net,imdsTest);
        
        disp("Type: " + type + ", Rep: " + rep + ", Done!")
    end
    save('results\resultsBird.mat','results');
end
disp('You did it! You crazy son of a &?#%')