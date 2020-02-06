imds = imageDatastore('C:\Users\Emil\Documents\MATLAB\Matmod20\comp\train\three','IncludeSubfolders',true,'FileExtensions','.mp4','LabelSource', 'foldernames', 'ReadFcn', @audioeasy)
labelCount = countEachLabel(imds)

%%
numTrainFiles = 20;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%%
layers = [
    imageInputLayer([32767 1]) %första ska vara samma som padTo
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2,'Padding','same') %felet är här
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2,'Padding','same')
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(3) %antalet kategorier
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.005, ...
    'MaxEpochs',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',2, ...
    'Verbose',false, ...
    'Plots','training-progress');

layers(2);

net = trainNetwork(imdsTrain,layers,options);
%%
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)

