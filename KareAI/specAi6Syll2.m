%Creates imds from all different subfolders,

folders = {'.\Oskar2\bergfink';'.\Oskar2\blames';'.\Oskar2\bofink';'.\Oskar2\grasparv';'.\Oskar2\pilfink';'.\Oskar2\talgoxe'};
[imdsTrainA, imdsValA] = imdata(folders(1),"bergfink");
[imdsTrainB, imdsValB] = imdata(folders(2),"blames");
[imdsTrainC, imdsValC] = imdata(folders(3),"bofink");
[imdsTrainD, imdsValD] = imdata(folders(4),"grasparv");
[imdsTrainE, imdsValE] = imdata(folders(5),"pilfink");
[imdsTrainF, imdsValF] = imdata(folders(6),"talgoxe");

%Ugly :(
imdsTrain = imageDatastore([imdsTrainA.Files;imdsTrainB.Files;imdsTrainC.Files;imdsTrainD.Files;imdsTrainE.Files;imdsTrainF.Files]);
imdsTrain.Labels = [imdsTrainA.Labels;imdsTrainB.Labels;imdsTrainC.Labels;imdsTrainD.Labels;imdsTrainE.Labels;imdsTrainF.Labels];

imdsVal = imageDatastore([imdsValA.Files;imdsValB.Files;imdsValC.Files;imdsValD.Files;imdsValE.Files;imdsValF.Files]);
imdsVal.Labels = [imdsValA.Labels;imdsValB.Labels;imdsValC.Labels;imdsValD.Labels;imdsValE.Labels;imdsValF.Labels];
%%
labelCountTrain = countEachLabel(imdsTrain);
labelCountVal = countEachLabel(imdsVal);

imgSizeTrain = size(readimage(imdsTrain,1));
imgSizeVal = size(readimage(imdsVal,1));
%%
numFiles = 207;
[imdsUse,imdsExtra] = splitEachLabel(imds,numFiles,'randomize');

%%
numTrain = round(0.8*numFiles);
[imdsTrain,imdsValidation] = splitEachLabel(imdsUse,numTrain,'randomize');

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
    
    fullyConnectedLayer(size(labelCount, 1))
    softmaxLayer
    classificationLayer];


%%
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',50, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',10, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'auto');

%%
net = trainNetwork(imdsTrain,layers,options);

%% Aggregate results from train



%%
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

results = zeros(size(labelCountTrain, 1), size(labelCountTrain, 1));
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
