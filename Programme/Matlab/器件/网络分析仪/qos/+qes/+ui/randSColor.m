function c = randSColor()
% produces randon color that's not too light
    b = 3;
    while b > 2
        c = rand(1,3);
        b = sum(c);
    end
end