imds = imageDatastore('C:\Users\Emil\Documents\MATLAB\Matmod20\train','IncludeSubfolders',true,'FileExtensions','.mp3','LabelSource', 'foldernames', 'ReadFcn', @audiore)
labelCount = countEachLabel(imds)

%%
img = readimage(imds,1);
size(img)

img = readimage(imds,2);
size(img)

smallest = 500000;

for k = 1:30
    img = readimage(imds,k);
    si = max(size(img));
    si;
    if si < smallest
        smallest = si;
    end %hittar minsta ljudfilen
    
end
smallest;


numTrainFiles = 4;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%%
layers = [
    imageInputLayer([426864 1])
    
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
    
    fullyConnectedLayer(6)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

layers(2);

net = trainNetwork(imdsTrain,layers,options);
%%
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)

