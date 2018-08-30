function [y] = srconv(x,fsin,fsout)
% determine m, the least common multiple (lcm) of fsin and fsout
    m=lcm(fsin,fsout);
% determine the up and down sampling rates
    up=m/fsin;
    down=m/fsout;
% resample the input using the computed up/down rates
    y=resample(x,up,down);
end
