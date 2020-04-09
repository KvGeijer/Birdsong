paths = ["simulations_freq", "simulations_time", "simulations_sound"];
nets = cell(1, 3);
results_all = zeros(6, 6*3);

for i = 1:3
    imds = imageDatastore(paths(i), 'IncludeSubfolders',true,'LabelSource','foldernames');
    
    labelCount = countEachLabel(imds);
    imgSize = size(readimage(imds,1));
    percentTrainFiles = 0.8;
    numTrainFiles = round(percentTrainFiles * min(labelCount{:, 2}));
    [imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');
    
    layers = [
        imageInputLayer([imgSize(1) imgSize(2) 1])

        convolution2dLayer(3,8,'Padding','same')
        batchNormalizationLayer
        reluLayer

        maxPooling2dLayer(2,'Stride',2, 'Padding', 'same')

        convolution2dLayer(3,16,'Padding','same')
        batchNormalizationLayer
        reluLayer

        maxPooling2dLayer(2,'Stride',2, 'Padding', 'same')

        convolution2dLayer(3,32,'Padding','same')
        batchNormalizationLayer
        reluLayer

        fullyConnectedLayer(size(labelCount, 1))
        softmaxLayer
        classificationLayer];

    options = trainingOptions('sgdm', ...
        'InitialLearnRate',0.01, ...
        'MaxEpochs',10, ...
        'Shuffle','every-epoch', ...
        'ValidationData',imdsValidation, ...
        'ValidationFrequency',30, ...
        'Verbose',false, ...
        'Plots','training-progress', ...
        'ExecutionEnvironment', 'auto');

    net = trainNetwork(imdsTrain,layers,options);
    nets{1, i} = net;
    
    YPred = classify(nets{i},imdsValidation);
    YValidation = imdsValidation.Labels;

    results = zeros(size(labelCount, 1), size(labelCount, 1));
    for kk = 1:length(YPred)
        guess = str2num('uint8(' + string(YPred(kk)) + ')');
        actual = str2num('uint8(' + string(YValidation(kk)) + ')');
        results(guess, actual) = results(guess, actual) + 1;
    end
    results_all(:, (i-1)*6+1:(i-1)*6+6) = results;
end
%%
k = 3;
imds = imageDatastore(paths(k), 'IncludeSubfolders',true,'LabelSource','foldernames');
YPred = classify(nets(k),imds);
YValidation = imds.Labels;

results = zeros(size(labelCount, 1), size(labelCount, 1));
for i = 1:length(YPred)
    guess = str2num('uint8(' + string(YPred(i)) + ')');
    actual = str2num('uint8(' + string(YValidation(i)) + ')');
    results(guess, actual) = results(guess, actual) + 1;
end

accuracy = sum(YPred == YValidation)/numel(YValidation);
disp(results)

%%
index = randperm(size(imdsValidation.Files, 1),1);
path = imdsValidation.Files{index};
figure(1)
%imshow(path)
guess = string(classify(net, imread(path)));
actual = string(imdsValidation.Labels(index));
disp(actual + ": " + guess);
%%
for i = 1:min(labelCount{:, 2})
    if (size(readimage(imds, i)) ~= imgSize) 
        disp(size(readimage(imds, i)));
    end
end