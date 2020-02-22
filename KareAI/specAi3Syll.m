%L?ser in inputs.
folders = {'.\Oskar50%syll\bofink';'.\Oskar50%syll\grasparv';'.\Oskar50%syll\talgoxe'};
imds = imageDatastore(folders,'LabelSource','foldernames');
%%
labelCount = countEachLabel(imds);
imgSize = size(readimage(imds,1));
%%
numFiles = min(labelCount.Count);
numTrain = round(numFiles*0.7);
numVal = round(numFiles*0.15);
numTest = numFiles -numTrain - numVal;
[imdsTrain,imdsValidation, imdsTest] = splitEachLabel(imds,numTrain,numVal,numTest,'randomize');


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
    'MaxEpochs',25, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',5, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'auto');

%%
net = trainNetwork(imdsTrain,layers,options);

%%
YPred = classify(net,imdsTest);
YTest = imdsTest.Labels;

accuracy = sum(YPred == YTest)/numel(YTest);

%%
index = randperm(size(imdsValidation.Files, 1),1);
path = imdsValidation.Files{index};
figure(1)
imshow(path)
guess = string(classify(net, imread(path)));
actual = string(imdsValidation.Labels(index));
disp(actual + ": " + guess);
