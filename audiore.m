function y = audiore(file)
[data, Fs] = audioread(file);
data = data(1:426864); %ful jävla hardcode, gjordes efter minsta ljudfilen hittades
siz = size(data);
if(siz(1) == 1)
    data = data';
end

y = data;
end