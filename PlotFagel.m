
% Overall not so efficient
D = 'C:\Users\karek\OneDrive\Documents\MATLAB\MatMod2020\Data'; %Adress to folder with subfolders of data
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.

for ii = 1:numel(N) %For each subfolder
%for ii = 6:6 %For specific folders
    %figure
    T = dir(fullfile(D,N{ii},'*')); % improve by specifying the file extension.
    C = {T(~[T.isdir]).name}; % files in subfolder.
    for jj = 1:numel(C)
    %for jj = 3:4
        F = fullfile(D,N{ii},C{jj});
        [data, ~] = audioread(F);
        %data = data(:,1);
        %subplot(4,3,jj);
        %plot((1:length(data))/44100,data);
        strophecut(data);
       
    end
end

