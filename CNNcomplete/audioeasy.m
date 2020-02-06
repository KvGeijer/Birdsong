function y = audioeasy(file)
[data, Fs] = audioread(file);
siz = size(data);
if(siz(1) == 1)
    data = data';
end

y = data;
end