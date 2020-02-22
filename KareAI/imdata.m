function [imdsTrain,imdsTest] = imdata(folder,name,amountTest)
%Creates an imageDatastore obj, where train and Test data is randomized
birdAmount = containers.Map(["bergfink","blames","bofink","grasparv","pilfink","talgoxe"],[7,9,10,8,6,8]);
imds = imageDatastore(folder,'IncludeSubFolders',true,'LabelSource','none');

if nargin<3; amountTest=1; end

exklBirds = randperm(birdAmount(name),amountTest);

flag = ones(length(imds.Files),1);
for ii = 1:amountTest
    flag = flag - contains(imds.Files,fullfile(name,num2str(exklBirds(ii))));
end

%I don't know logical indexing stuffs... :(
trainFiles = imds.Files(find(flag==1));
testFiles = imds.Files(find(flag==0));

imdsTrain = imageDatastore(trainFiles);
imdsTest = imageDatastore(testFiles);

imdsTrain.Labels = categorical(repelem(name, length(imdsTrain.Files)));
imdsTest.Labels = categorical(repelem(name, length(imdsTest.Files)));

end

