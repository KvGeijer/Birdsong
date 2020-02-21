%%
folders = {'.\Oskar2\bofink';'.\Oskar2\grasparv';'.\Oskar2\talgoxe'};
[imdsTrainA, imdsValA] = imdata(folders(1),"bofink");
[imdsTrainB, imdsValB] = imdata(folders(2),"grasparv");
[imdsTrainC, imdsValC] = imdata(folders(3),"talgoxe");

imdsTrain = imageDatastore([imdsTrainA.Files;imdsTrainB.Files;imdsTrainC.Files]);
imdsTrain.Labels = [imdsTrainA.Labels;imdsTrainB.Labels;imdsTrainC.Labels];

imdsValidation = imageDatastore([imdsValA.Files;imdsValB.Files;imdsValC.Files]);
imdsValidation.Labels = [imdsValA.Labels;imdsValB.Labels;imdsValC.Labels];
%%
labelCountTrain = countEachLabel(imdsTrain);
labelCountValidation = countEachLabel(imdsValidation);

imgSizeTrain = size(readimage(imdsTrain,1));
imgSizeValidation = size(readimage(imdsValidation,1));


%%
layers = [
    imageInputLayer([imgSizeTrain(1) imgSizeTrain(2) 1])
    
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
    'MaxEpochs',50, ...
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
