function [imdsTrain,imdsVal] = imdata(folder,name)
%Creates an imageDatastore obj, where train and val data is randomized
birdAmount = containers.Map(["bergfink","blames","bofink","grasparv","pilfink","talgoxe"],[7,9,10,8,6,8]);
imds = imageDatastore(folder,'IncludeSubFolders',true,'LabelSource','none');

exklBirds = randperm(birdAmount(name),round(0.2*birdAmount(name)));

flag = ones(length(imds.Files),1);
for ii = 1:length(exklBirds)
    flag = flag - contains(imds.Files,fullfile(name,num2str(exklBirds(ii))));
end

%I don't know logical indexing stuffs... :(
trainFiles = imds.Files(find(flag==1));
validationFiles = imds.Files(find(flag==0));

imdsTrain = imageDatastore(trainFiles);
imdsVal = imageDatastore(validationFiles);

imdsTrain.Labels = categorical(repelem(name, length(imdsTrain.Files)));
imdsVal.Labels = categorical(repelem(name, length(imdsVal.Files)));

end

