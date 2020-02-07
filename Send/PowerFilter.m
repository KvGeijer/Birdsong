function filtered = PowerFilter(signal, tSlow, tFast, FS) 
    nSlow = tSlow * FS;
    nFast = tFast * FS;
    absSignal = abs(signal);
    slow = movmean(absSignal, nSlow);
    fast = movmean(absSignal, nFast);
    filtered = zeros(size(signal));
    for i = 1:length(filtered)
        if (fast(i) > slow(i)) 
            filtered(i) = signal(i);
        end
    end
    plot(filtered);
end