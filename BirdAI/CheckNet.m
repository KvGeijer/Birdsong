function table_indiv = CheckNet(net, imdsValidation) 

    paths = imdsValidation.Files;
    names = strings(length(paths),1);
    indivCount = cell(1, 2);
    indivCount{1, 1} = strings(0);
    indivCount{1, 2} = [];
    for i = 1:length(paths) 
        pathParts = split(paths{i},"\"); 
        names(i) = [pathParts{length(pathParts)-2} pathParts{length(pathParts)-1}];
        exists = false;
        for ii = 1:length(indivCount{1, 1})
           if (indivCount{1, 1}(ii) == names(i)) 
              exists = true;
              indivCount{1, 2}(ii) = indivCount{1, 2}(ii) + 1;
           end
        end
        if (exists == false)
            indivCount{1, 1}(length(indivCount{1, 1}) + 1) = names(i);
            indivCount{1, 2}(length(indivCount{1, 2}) + 1) = 1;
        end
    end
    
    
    YPred = classify(net,imdsValidation);
    YValidation = imdsValidation.Labels;
    labelCount = countEachLabel(imdsValidation);
    labels = labelCount{:, 1};
    individuals = indivCount{1,1};
    

    table_class = zeros(length(labels), length(labels));
    table_indiv = zeros(length(labels), length(individuals));
    for kk = 1:length(YPred)
        for index = 1:length(labels)
           if (labels(index) == YPred(kk)) 
               guess = index;
           end
           if (labels(index) == YValidation(kk))
               actual = index;
           end
        end
        for index = 1:length(individuals)
            if (individuals(index) == names(kk))
               indiv = index; 
            end
        end
        
        table_indiv(guess, indiv) = table_indiv(guess, indiv) + 1;
        %table_class(guess, actual) = table_class(guess, actual) + 1;
    end
    T = array2table(table_indiv, 'Row', string(unique(imdsValidation.Labels)), 'VariableNames', individuals);
    %resultBoard(T)
    table_indiv = resultBoard(T);
end