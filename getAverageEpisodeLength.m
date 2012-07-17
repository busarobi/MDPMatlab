function Ls = getAverageEpisodeLength( histories )

[N,M] = size(histories);
Ls = zeros(N,1);
for i1 = 1:N    
    for i2 = 1:M                    
        if ((i2 == M ) || isempty(histories{i1,i2+1}))
            break;
        end
    end
    Ls(i1) = i2;
end


return;
