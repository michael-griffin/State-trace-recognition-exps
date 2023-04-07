%Written by Michael Griffin, last modified 6/11/2019
%Requires calciso.m 	used to fit isotonic regression lines.

%This code runs the isotonic permutation test described in
%Benjamin, A.S., Griffin, M., & Douglas, J.V. & Dames, H. (2019).
%A nonparametric technique for analysis of state-trace functions

%First, determines overlap region for a subject (points in the data set whose
%conditions labels are eligible to swapped), and then runs the permutation
%test for that subject n times: it swaps condition labels, refits the isotonic regression
%to the new 'conditions', then records the new fit and compares to the fit pre-swap.

exp = 3;
[data, txt, raw] = xlsread(['data/fullsummary_formatted_exp', exp, '.xlsx']);

allsubs = [1:size(data,1)]';
nsubs = size(data,1);

nhalf = size(data,2)/4;
npoints = nhalf*2; % npoints = size(data,2)/2;
tol = 1e-9; %needed in pgreater down the line. Annoying.
permutations = 100; %how many permutation tests are done for swapping condition labels.

%Base RSS, average RSS post swap P Greater, P Less, P Same, Avg. Overlap.
summaryiso = zeros(nsubs, 6);
summaryiso(:,:) = -1; %to catch errors, will be overwritten below.

for k = 1:nsubs
    crow = data(k,:);
    averages = [crow(1:npoints)' crow(npoints+1:end)' (1:npoints)' [ones(1,nhalf) 2*ones(1,nhalf)]'];
    sorted = sortrows(averages, 1);

    iso = zeros(npoints, 12);
    iso(:,1:size(sorted,2)) = sorted;
    %Col 1:2 Base data
    %Col 3-4: Full vs divided attention
    %Col 5: Overlap
    %Col 6: post swap condition
    %Col 7:9 Pre swap iso fits. (7 across cond, 8 full, 9 divided)
    %Col 10-11: Post swap iso fits

    %Find overlap region. Points in this region will later be swapped for
    %the permutation test.
    sorty = sortrows(averages,2);
    for n = 1:npoints-1
        index = iso(n,3);
        index = find(sorty(:,3) == index);
        %if the next point that has a higher x or y value is in the
        %other attention condition, or if there are any y values from
        %the other condition that are smaller than the current.
        if iso(n+1,4) ~= iso(n,4) || sum(sorty(1:index-1,4) ~= iso(n,4))
            break;
        end
        if index ~= npoints && sorty(index+1,4) ~= iso(n,4)
            break;
        end
    end
    start = n;

    indexfull = find(iso(:,4) == 1);
    indexdiv = find(iso(:,4) == 2);
    isofull = iso(indexfull,:);
    isodiv = iso(indexdiv,:);

    %Determines which are inside overlap region
    tocut = [];
    for n = 1:npoints
        switch iso(n,4)
            case 1
                if iso(n,1) > max(isodiv(:,1)) && iso(n,2) >= max(isodiv(:,2)) ...
                        || iso(n,1) < min(isodiv(:,1)) && iso(n,2) <= min(isodiv(:,2))
                    tocut = [tocut, n];
                end
            case 2
                if iso(n,1) > max(isofull(:,1)) && iso(n,2) >= max(isofull(:,2)) ...
                        || iso(n,1) < min(isofull(:,1)) && iso(n,2) <= min(isofull(:,2))
                    tocut = [tocut, n];
                end
        end
    end
    iso(:,5) = 1;
    iso(tocut,5) = 0;
    overlap = find(iso(:,5));

    iso(:,7) = calciso(iso(:,1:2));
    %Base fits, to be compared to the permutations.
    iso(indexfull,8) = calciso(iso(indexfull,1:2));
    iso(indexdiv,9) = calciso(iso(indexdiv,1:2));

    %Calculate base RSS for both attention conditions
    rssbasefull = 0;
    rssbasediv = 0;
    for n = 1:length(indexfull)
        index = indexfull(n);
        rssbasefull = rssbasefull + (iso(index,2)-iso(index,8))^2;
    end
    for n = 1:length(indexdiv)
        index = indexdiv(n);
        rssbasediv = rssbasediv + (iso(index,2)-iso(index,9))^2;
    end


    %If there's overlap, do permutation test
    %Latter statement controls for a case where one attention
    %condition is completely within the range of the other. If so, the
    %overlap region would have only points of 1 condition, and swaps would
    %be inappropriate (no chance for a swap to improve fit).
    permtest = 0;
    if sum(iso(:,5)) > 0 && sum(iso(overlap,4) == 2) && sum(iso(overlap,4) == 1)
        permtest = 1;
    end
    permdata = zeros(permutations,2);
    permdata = permdata-1;


    %Swap conditions
    if permtest
        for p = 1:permutations
            swaps = overlap(randperm(length(overlap)));
            iso(:,6) = iso(:,4);
            iso(overlap,6) = iso(swaps,4);

            indexnewfull = find(iso(:,6) == 1);
            indexnewdiv = find(iso(:,6) == 2);

            iso(:,10) = 0;
            iso(:,11) = 0;
            iso(indexnewfull,10) = calciso(iso(indexnewfull,1:2));
            iso(indexnewdiv,11) = calciso(iso(indexnewdiv,1:2));

            rss = 0;
            for n = 1:length(indexnewfull)
                index = indexnewfull(n);
                rss = rss + (iso(index,2)-iso(index,10))^2;
            end
            rssfull = rss;

            rss = 0;
            for n = 1:length(indexnewdiv)
                index = indexnewdiv(n);
                rss = rss + (iso(index,2)-iso(index,11))^2;
            end
            rssdiv = rss;

            permdata(p,1) = rssbasefull+rssbasediv;
            permdata(p,2) = rssfull+rssdiv;
        end
        summaryiso(k,1) = rssbasefull+rssbasediv; %RSS pre swap
        summaryiso(k,2) = mean(permdata(:,2)); %average swapped RSS
        summaryiso(k,3) = sum((permdata(:,2) - permdata(:,1)) > tol)/length(permdata);
        summaryiso(k,4) = sum((permdata(:,2) - permdata(:,1)) < -tol)/length(permdata);
        summaryiso(k,5) = 1/nchoosek(length(overlap), sum(iso(overlap,4) == 1));
    else
        summaryiso(k,1) = rssbasefull+rssbasediv; %RSS pre swap
        summaryiso(k,2) = NaN;
        summaryiso(k,3) = NaN;
        summaryiso(k,4) = NaN;
        summaryiso(k,5) = NaN;
    end
    summaryiso(k,6) = length(overlap);
end

relevant = 1:length(summaryiso);
toremove = [];
for n = 1:nsubs
    if sum(isnan(summaryiso(n,:)));
        toremove = [toremove n];
    end
end
relevant(toremove) = [];

rssmeanbase = mean(summaryiso(relevant,1));
rssmeanswap = mean(summaryiso(relevant,2));
pgreater = mean(summaryiso(relevant,3)); %Each subject has a p greater, this averages.
pless = mean(summaryiso(relevant,4));
psameorder = mean(summaryiso(relevant,5));
overlapavg = mean(summaryiso(relevant,6));

