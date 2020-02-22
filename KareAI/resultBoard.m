function resultB = resultBoard(T)



realBird = T.Properties.VariableNames;
for k = 1:length(realBird)
    name = realBird{k};
    index = find(isletter(name), 1, 'last');
    name = name(1:index);
    realBird{k} = name;
end    
A = table2array(T);
[~, rowIndexOfMaxVal] = max(A);



res = zeros(length(T.Properties.RowNames));

for k = 1:length(realBird)
   birdName = realBird{k};
   [~, columnIndex] = ismember(birdName, T.Properties.RowNames);
   res(rowIndexOfMaxVal(k), columnIndex) = res(rowIndexOfMaxVal(k), columnIndex) + 1;
   
end
resultB = array2table(res, 'Row', T.Properties.RowNames, 'VariableNames', T.Properties.RowNames);
%kolonner ?r vilken f?gel det egentligen ?r, rader ?r vad cnn gissar p?
end