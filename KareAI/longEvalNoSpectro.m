% This script should run the following and save their results:
%   Audio of 3 birds syllables, bucket method
%   Audio of 6 birds syllables, bucket method
%   Audio of 3 birds syllables, bird method
%   Audio of 6 birds syllables, bird method
% They should all return results of how well it classes different birds, as
% well as syllable validation rate.
% Each thing should run at least 10 times at 40 epochs
folders = cell(4,1);
folders{1} = {'.\Syllables\bofink';'.\Syllables\grasparv';'.\Syllables\talgoxe'};
folders{2} = {'.\Syllables\bergfink';'.\Syllables\blames';'.\Syllables\bofink';'.\Syllables\grasparv';'.\Syllables\pilfink';'.\Syllables\talgoxe'};
folders{3} = {'.\SyllablesSubs\bofink';'.\SyllablesSubs\grasparv';'.\SyllablesSubs\talgoxe'};
folders{4} = {'.\SyllablesSubs\bergfink';'.\SyllablesSubs\blames';'.\SyllablesSubs\bofink';'.\SyllablesSubs\grasparv';'.\SyllablesSubs\pilfink';'.\SyllablesSubs\talgoxe'};

names = cell(2,1);
names{1} = ["bofink";"grasparv";"talgoxe"];
names{2} = ["bergfink";"blames";"bofink";"grasparv";"pilfink";"talgoxe"];


%First arg: type
%Second: rep
%Third: 1:accuracy syllables, 2:accuracy matrix syllables, 3:accuracy
%matrix birds
resultsBucket = cell(2,20,2);
resultsBirds = cell(2,20,3);

%Bucket method
for type = 3:2
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
            imageInputLayer([imgSize(1) imgSize(2)]) %f?rsta ska vara samma som padTo
            
            
            convolution2dLayer(3,8,'Padding','same')
            batchNormalizationLayer
            reluLayer

            maxPooling2dLayer(2,'Stride',2,'Padding','same') 

            convolution2dLayer(3,16,'Padding','same')
            batchNormalizationLayer
            reluLayer

            maxPooling2dLayer(2,'Stride',2,'Padding','same')

            convolution2dLayer(3,32,'Padding','same')
            batchNormalizationLayer
            reluLayer

            fullyConnectedLayer(size(labelCount, 1)) %antalet kategorier
            softmaxLayer
            classificationLayer];

        options = trainingOptions('sgdm', ...
            'InitialLearnRate',0.01, ...
            'MaxEpochs',35, ...
            'Shuffle','every-epoch', ...
            'ValidationData',imdsValidation, ...
            'ValidationFrequency',5, ...
            'Verbose',false, ...
            'ExecutionEnvironment', 'auto' ...
            );
   %         'Plots','training-progress'...

        net = trainNetwork(imdsTrain,layers,options);

        YPred = classify(net,imdsTest);
        YTest = imdsTest.Labels;
        resultsBucket{type,rep,1} = sum(YPred == YTest)/numel(YTest);
        resultsBucket{type,rep,2} = CheckNetSyll(net,imdsTest);
        
       disp("Type: " + type + ", Rep: " + rep + ", Done!")
   end
   save('results\resultsNoSpectroBucket.mat','results');
end


for type = 3:4
    for rep = 1:20
        % Set up imdsValidation and imdsTrain
        amountBirds = length(folders{type});
        
        trainFiles = [];
        trainLabels = [];
        testFiles = [];
        testLabels = [];
        
        for k = 1:amountBirds
            [imdsTrainLoop, imdsTestLoop] = imdata(folders{type}{k},names{type-2}(k));
            
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
            imageInputLayer([imgSize(1) imgSize(2)]) %f?rsta ska vara samma som padTo

            convolution2dLayer(3,8,'Padding','same')
            batchNormalizationLayer
            reluLayer

            maxPooling2dLayer(2,'Stride',2,'Padding','same') %felet ?r h?r

            convolution2dLayer(3,16,'Padding','same')
            batchNormalizationLayer
            reluLayer

            maxPooling2dLayer(2,'Stride',2,'Padding','same')

            convolution2dLayer(3,32,'Padding','same')
            batchNormalizationLayer
            reluLayer

            fullyConnectedLayer(size(labelCount, 1)) %antalet kategorier
            softmaxLayer
            classificationLayer];
        
        options = trainingOptions('sgdm', ...
            'InitialLearnRate',0.01, ...
            'MaxEpochs',35, ...
            'Shuffle','every-epoch', ...
            'ValidationData',imdsValidation, ...
            'ValidationFrequency',5, ...
            'Verbose',false, ...
            'ExecutionEnvironment', 'auto');
        %'Plots','training-progress'
        
        net = trainNetwork(imdsTrain,layers,options);
        
        YPred = classify(net,imdsTest);
        YTest = imdsTest.Labels;
        resultsBirds{type-2,rep,1} = sum(YPred == YTest)/numel(YTest);
        resultsBirds{type-2,rep,2} = CheckNetSyll(net,imdsTest);
        resultsBirds{type-2,rep,3} = CheckNet(net,imdsTest);
        
        disp("Type: " + type + ", Rep: " + rep + ", Done!")
    end
    save('results\resultsNoSpectroBird.mat','results');
end
disp('You did it! You crazy son of a &?#%')
