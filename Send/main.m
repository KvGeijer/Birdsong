
imds = imageDatastore('simulations', 'IncludeSubfolders',true,'LabelSource','foldernames');
%%
figure;
perm = randperm(size(imds.Files, 1),min(size(imds.Files, 1), 20));
for i = 1:min(size(imds.Files, 1), 20)
    subplot(4,5,i);
    imshow(imds.Files{perm(i)});
end
%%
labelCount = countEachLabel(imds);
imgSize = size(readimage(imds,1));
numTrainFiles = 8000;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

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
    'InitialLearnRate',0.0001, ...
    'MaxEpochs',10, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'auto');

%%
net = trainNetwork(imdsTrain,layers,options);

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
