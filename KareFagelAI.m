%% Konvertera ljudfilerna till imageDatastora filer
imds = imageDatastore({'train\talgoxe','train\bofink','train\graasparv'}, ...
'IncludeSubfolders',true,'FileExtensions','.mp3','LabelSource', ... 
'foldernames', 'ReadFcn', @audiore);



%% R?kna antal och storlek
labelCount = countEachLabel(imds)

img = readimage(imds,1);
size(img)

%% Splitta upp i tr?ning och validation
numTrainFiles = 6;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%% Define the convolutional neural network architecture
layers = [
    imageInputLayer([426864 1])
    
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
    
    fullyConnectedLayer(3) %F?r 3 f?glar
    softmaxLayer
    classificationLayer];

%% Specificera tr?nings-options
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',4, ...              %G?r ?ver varje input 4 g?nger
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

%% Tr?na n?tverket
net = trainNetwork(imdsTrain,layers,options);
%% Titta final accuracy
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)
