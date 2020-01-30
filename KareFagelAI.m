%% Konvertera ljudfilerna till imageDatastora filer
imds = imageDatastore({'Data\Talgoxe','train\Bofink','train\Graasparv'}, ...
'IncludeSubfolders',true,'FileExtensions','.mp3','LabelSource', ... 
'foldernames', 'ReadFcn', @audiore);



%% R?kna antal och storlek
labelCount = countEachLabel(imds)

img = readimage(imds,1);
size(img)

%% Splitta upp i tr?ning och validation
numTrainFiles = 5;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');