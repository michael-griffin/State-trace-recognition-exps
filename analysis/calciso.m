function isofit = calciso(dat)
dat = sortrows(dat, 1);
dat = [dat dat(:,2)]; %last column will eventually become isofit

%Average across ties first.
uniq = unique(dat(:,1));
for n = 1:length(uniq)
    if length(find(dat(:,1) == uniq(n))) > 1 %if there's a tie.
        indexes = find(dat(:,1) == uniq(n));
        dat(indexes,3) = mean(dat(indexes,3));
    end
end

for n = 2:length(dat)
    if dat(n,3) < dat(n-1,3)
        done = 0; %rabbit hole begins
        index = n-1;
        newmean = mean(dat(index:n,3));
        
        %Back averages. If new average is still smaller than the previous
        %point, that point is added into the mix until the trend is monotonic.
        while ~done
            problem = find(dat(1:index-1,3) > newmean, 1, 'last');
            if isempty(problem)
                done = 1;
            else
                index = problem;
                newmean = mean(dat(index:n,3));
            end
        end
        dat(index:n,3) = newmean;
    end
end
isofit = dat(:,3);
end

