
% Overall not so efficient
D = 'C:\Users\karek\OneDrive\Documents\MATLAB\MatMod2020\Data'; %Adress to folder with subfolders of data
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.

max = 0;

for ii = 1:numel(N) %For each subfolder
%for ii = 6:6 %For specific folders
    %figure
    T = dir(fullfile(D,N{ii},'*')); % improve by specifying the file extension.
    C = {T(~[T.isdir]).name}; % files in subfolder.
    for jj = 1:numel(C)
    %for jj = 3:3
        F = fullfile(D,N{ii},C{jj});
        [data, fs] = audioread(F);
        [Xmat,~,fs] = strophecut(data,fs,360,0.95);
        %stropheToTot(data,fs);
        
        if length(Xmat(:,1))>max; max = length(Xmat(:,1)); end
        
        
    end
end

