% This script should run the following and save their results:
%   Spectrogram of 3 birds, bad time rez
%   Spectrogram of 3 birds, good time rez
%   Spectrogram of 6 birds, bad time rez
%   Spectrogram of 6 birds, good time rez
% They should all return results of how well it classes different birds, as
% well as syllable validation rate.
% Each thing should run at least 10 times at 40 epochs
folders = cell(4,1);
folders{1} = {'.\Oskar\bofink';'.\Oskar\grasparv';'.\Oskar\talgoxe'};
folders{2} = {'.\Oskar50%syll\bofink';'.\Oskar50%syll\grasparv';'.\Oskar50%syll\talgoxe'};
folders{3} = {'.\Oskar\bergfink';'.\Oskar\blames';'.\Oskar\bofink';'.\Oskar\grasparv';'.\Oskar\pilfink';'.\Oskar\talgoxe'};
folders{4} = {'.\Oskar50%syll\bergfink';'.\Oskar50%syll\blames';'.\Oskar50%syll\bofink';'.\Oskar50%syll\grasparv';'.\Oskar50%syll\pilfink';'.\Oskar50%syll\talgoxe'};


%First arg: type
%Second: rep
%Third: 1:accuracy, 2:accuracy matrix
results = cell(4,20,2);

for type = 1:4
   for rep = 1:20
        imds = imageDatastore(folders{type},'LabelSource','foldernames');

        labelCount = countEachLabel(imds);
        imgSize = size(readimage(imds,1));

        numFiles = min(labelCount.Count);
        numTrain = round(numFiles*0.7);
        numVal = round(numFiles*0.15);
        numTest = numFiles - numTrain - numVal;
        [imdsTrain,imdsValidation, imdsTest] = splitEachLabel(imds,numTrain,numVal,numTest,'randomize');


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
        
       disp("Type: " + type + ", Rep: " + rep + ", Done!")
   end
   save('results\resultsSyll.mat','results');
end
disp('You did it! You crazy son of a &?#%')
