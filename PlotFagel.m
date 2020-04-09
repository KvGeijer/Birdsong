D = 'C:\Users\karek\OneDrive\Documents\MATLAB\MatMod2020\Data'; %Adress to folder with subfolders of data
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.

%This file is for looping over all indata and for example checking how 
%strophecut performs on the different files.

for ii = 1:numel(N) %For each subfolder
    T = dir(fullfile(D,N{ii},'*')); 
    C = {T(~[T.isdir]).name}; % files in subfolder.
    for jj = 1:numel(C)
        F = fullfile(D,N{ii},C{jj});
        [data, fs] = audioread(F);
        [Xmat,~,fs] = strophecut(data,fs,360,0.95);
    end
end

