%Written by Michael Griffin 5.15.2013
%The original way data was formatted. fullsummary excel files were then read into
%SPSS for analysis. Later migrated these analyses to R, and used formatforR.m
%to bring summary files up to standards for tidy data.

%Hits minus false alarms/d' are both available, can toggle with usedprime.

% Subject data is arranged in the 'holding' variable such that
% First 4 rows are full attention
% Last 4 are divided
% Col 1: Hit %
% Col 2: FA %
% Col 3: Hit % For color 1.
% Col 4: FA, said color 1 (for Color 2).
% Col 5: D' or Hits - False Alarms, Old/New
% Col 6: D' or HIts - False Alarms, Color

clear all
clc
pkg load io %in Octave allows xlswrite/xlsread

exp = 1;
writefile = 0;
usedprime = 1; %change to 0 if you want Hits - False Alarms

switch exp
	case 1
		allsubs = [1:12, 14:32, 37:70];
	case 2
		allsubs = [16:77, 79:81, 84:86];
	case 3
		allsubs = [33:66, 68:94];
end


summary = cell(length(allsubs), 32); %Hit percent, FA percent and the corresponding two for colors for all 8 test lists.

Labels = [{'List1, Full, O/N Hit'}, {'List1, Full, O/N FA'}, {'List1, Full, C1 Hit'} {'List1, Full, C1 FA'}...
    {'List2, Full, O/N Hit'}, {'List2, Full, O/N FA'}, {'List2, Full, C1 Hit'} {'List2, Full, C1 FA'}...
    {'List3, Full, O/N Hit'}, {'List3, Full, O/N FA'}, {'List3, Full, C1 Hit'} {'List3, Full, C1 FA'}...
    {'List4, Full, O/N Hit'}, {'List4, Full, O/N FA'}, {'List4, Full, C1 Hit'} {'List4, Full, C1 FA'}...
    {'List1, Divided, O/N Hit'}, {'List1, Divided, O/N FA'}, {'List1, Divided, C1 Hit'} {'List1, Divided, C1 FA'}...
    {'List2, Divided, O/N Hit'}, {'List2, Divided, O/N FA'}, {'List2, Divided, C1 Hit'} {'List2, Divided, C1 FA'}...
    {'List3, Divided, O/N Hit'}, {'List3, Divided, O/N FA'}, {'List3, Divided, C1 Hit'} {'List3, Divided, C1 FA'}...
    {'List4, Divided, O/N Hit'}, {'List4, Divided, O/N FA'}, {'List4, Divided, C1 Hit'} {'List4, Divided, C1 FA'}];

for m = 1:length(allsubs)
    subn = allsubs(m);

    load(['data/data_exp', int2str(exp), '/Sub', int2str(subn), '_alldata.mat']);

    analyzed = cell(1, 8);
    holding = cell(8, 8);

    for n = 1:8
        currentlist = testlists{n,1};
        Discrim = currentlist(ismember(currentlist(:,5), 'Discrim'),:);
        oldnew = currentlist(ismember(currentlist(:,5), 'oldnew'),:);

        firsthalf = currentlist(ismember(currentlist(:,6), 'firsthalf'),:); %if you happen to grab a new item there's no presentation rate listed, which messes up the switch
        switch str2double(firsthalf{1,4})
            case .5
                listnum = 1;
            case 1
                listnum = 2;
            case 2
                listnum = 3;
            case 4
                listnum = 4;
        end

        if strcmp(firsthalf{1,2}, 'Divided')
            listnum = listnum + 4;
        else
        end

        c = [ismember(Discrim(:,9), 'd'), ismember(Discrim(:,12), 'd')];
        c = [c c(:,1)+c(:,2)];
        d = [ismember(oldnew(:,9), 'c'), ismember(oldnew(:,12), 'c')];
        d = [d d(:,1)+d(:,2)];
        c1said1 = length(find(c(:,3) == 2));
        c2said2 = length(find(c(:,3) == 0));

        colorerrors = find(c(:,3) == 1);
        oldnewerrors = find(d(:,3) == 1);

        c1said2 = length(intersect(colorerrors, find(c(:,2) == 0))); %Color 1 being what they should have responded 'd' to.
        c2said1 = length(intersect(colorerrors, find(c(:,2) == 1)));

        hits = length(find(d(:,3) == 2));
        CRs = length(find(d(:,3) == 0));
        misses = length(intersect(oldnewerrors, find(d(:,2) == 0)));
        FAs = length(intersect(oldnewerrors, find(d(:,2) == 1)));

        holding{listnum,1} = hits/10;
        holding{listnum,2} = FAs/10;
        holding{listnum,3} = c1said1 / 10;
        holding{listnum,4} = c2said1 / 10;
        if usedprime
            holding{listnum,5} = norminv(hits/10,0,1) - norminv(FAs/10,0,1);
            holding{listnum,6} = norminv(c1said1/10,0,1) - norminv(c2said1/10,0,1);
        else
            holding{listnum,5} = (hits-FAs)/10;
            holding{listnum,6} = (c1said1 - c2said1)/10;
        end
    end

    for o = 1:8
        for p = 1:4
            summary{m,(o-1)*4+p} = holding{o,p};
        end
    end
end


summary = [Labels; summary];

if writefile
	if usedprime
		xlswrite(['data/fullsummary_formatted_exp', intstr(exp), '.xlsx'], summary);
	else
		xlswrite(['data/fullsummaryhfa_formatted_exp', intstr(exp), '.xlsx'], summary);
	end
end

