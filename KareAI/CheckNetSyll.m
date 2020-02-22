function table = CheckNetSyll(net, imdsValidation) 

    YPred = classify(net,imdsValidation);
    YValidation = imdsValidation.Labels;
    labels = countEachLabel(imdsValidation);
    labels = labels{:, 1};

    table = zeros(size(labels, 1), size(labels, 1));
    for kk = 1:length(YPred)
        for index = 1:length(labels)
           if (labels(index) == YPred(kk)) 
               guess = index;
           end
           if (labels(index) == YValidation(kk))
               actual = index;
           end
        end
        table(guess, actual) = table(guess, actual) + 1;
    end

end