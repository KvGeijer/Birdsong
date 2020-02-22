%%
folders = {'.\Oskar2\bofink';'.\Oskar2\grasparv';'.\Oskar2\talgoxe'};
[imdsTrainA, imdsTestA] = imdata(folders(1),"bofink");
[imdsTrainB, imdsTestB] = imdata(folders(2),"grasparv");
[imdsTrainC, imdsTestC] = imdata(folders(3),"talgoxe");

imdsTrain = imageDatastore([imdsTrainA.Files;imdsTrainB.Files;imdsTrainC.Files]);
imdsTrain.Labels = [imdsTrainA.Labels;imdsTrainB.Labels;imdsTrainC.Labels];

imdsTest = imageDatastore([imdsTestA.Files;imdsTestB.Files;imdsTestC.Files]);
imdsTest.Labels = [imdsTestA.Labels;imdsTestB.Labels;imdsTestC.Labels];

labelCountTrain = countEachLabel(imdsTrain);
labelCountTest = countEachLabel(imdsTest);

[imdsTrain, imdsValidation, ~] = splitEachLabel(imdsTrain, round(min(labelCountTrain.Count)*0.8),min(labelCountTrain.Count)-round(min(labelCountTrain.Count)*0.8),'randomize');
labelCountTrain = countEachLabel(imdsTrain);
labelCountValidation = countEachLabel(imdsValidation);

imgSize = size(readimage(imdsTrain,1));



%%
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
    
    fullyConnectedLayer(size(labelCountTrain, 1))
    softmaxLayer
    classificationLayer];


%%
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',25, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',10, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'auto');

%%
net = trainNetwork(imdsTrain,layers,options);

%% INFOGA DIN METOD F?R GENOMSNITT H?R OSKAR



%%
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

results = zeros(size(labelCount, 1), size(labelCount, 1));
for i = 1:length(YPred)
    guess = str2num('uint8(' + string(YPred(i)) + ')');
    actual = str2num('uint8(' + string(YValidation(i)) + ')');
    results(guess, actual) = results(guess, actual) + 1;
end

accuracy = sum(YPred == YValidation)/numel(YValidation);

%%
index = randperm(size(imdsValidation.Files, 1),1);
path = imdsValidation.Files{index};
figure(1)
imshow(path)
guess = string(classify(net, imread(path)));
actual = string(imdsValidation.Labels(index));
disp(actual + ": " + guess);
