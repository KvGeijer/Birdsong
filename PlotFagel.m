% Overall not so efficient
D = 'C:\Users\karek\OneDrive\Documents\MATLAB\MatMod2020\Data'; %Adress to folder with subfolders of data
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.


lengthTable = zeros(6,10);

for ii = 1:numel(N) %For each subfolder
    figure
    T = dir(fullfile(D,N{ii},'*')); % improve by specifying the file extension.
    C = {T(~[T.isdir]).name}; % files in subfolder.
    for jj = 1:numel(C)
        F = fullfile(D,N{ii},C{jj})
        [data, ~] = audioread(F);
        subplot(4,3,jj);
        plot(data);
        
        lengthTable(ii,jj) = length(data);
    end
end