%Created by Michael Griffin, 11/15/12

%Creates input files loaded by exp_statetrace.
%In particular, creates variables:
%studylists		testlists		schedules		soundlists
%rate			buffer			numlists		lrec

%More detailed summaries for each variable are below.
%Key created variables:
%rate:			Presentation rate for divided attention task
%buffer: 		how many items for the divided attention task
% 		 		are presented alone before starting the studylist
%numlists/lrec: The number of study-test blocks / the number of items per bloc


%Studylists:
% C1: 		Word
% C2: 		Attention condition
% C3: 		Color of Word
% C4: 		presentation rate (in seconds)
% C5: 		Subsequent memory test condition (Color vs Old/New judgment)
% C6: 		which half of the list the word was in
% C7: 		List number, 1-4 are full attention lists, 5-8 for divided attention
%			%Presentation rate varies by list (hence 4 for each attention condition)
% C8: 		Adjusted list number, used for creating soundlists.

%Testlists:
%Cols 1-7:	identical to study
%Col 8:		what type of response should be made
%Col 9:		correct response.
%Col 10:	(Blank) will be RT once experiment has been run
%Col 11:	(Blank) will be time since list began
%Col 12:	(Blank) will be participant's response

%Schedules:
%One for each studylist. Perhaps the most initially confusing variable. This is
%the main thing used to actually run the experiment.

%C1: 		Total time elapsed for that list.
%C2: 		Time until next action (start a trial/sound, stop a trial/sound.)

%When two actions happen at the same time, the time until the next
%action will be zero. Running a study list in the actual experiment is
%essentially one large for loop running through the schedule,
%with it telling it to wait .X seconds before trying to do the next action.


rng('shuffle'); %shuffles random number generator.

waitTime2 = .5; %duration of blank screen. Needed for constructing soundlists
buffer = 4; %How many digits to hear before list begins/how long it continues after words finish
numlists = 8;
rate = 2.3; % how fast sounds are presented.
lrec = 30;
numobs = lrec/6;
trialratio = 2/3; %1/3 of study list is old/new test, 2/3 is color discrimination

%Presentation rates for each study list. 1-4 for full attention, 5-8 for divided attention.
presrates = [{'.5'} {'1'} {'2'} {'4'}; {'.5'} {'1'} {'2'} {'4'}];




for i = 900
    subn = i
    completelist = cell(numlists*lrec, 7);

    if round(numobs) ~= numobs
        commandwindow;
        error('Not a valid number of items per list.');
    end

    [~, ~, allwords] = xlsread('stimuli\WordList.xlsx'); %word list is from MRC database.

    %Cleanup
    allwords = allwords(2:end,:);
    for n = 1:length(allwords)
        o = 1;
        check = 0;
        while o <= 8 && check == 0   %removes extra spaces
            if strcmp(allwords{n,1}(o), ' ')
                check = 1;
                allwords{n,1} = allwords{n,1}(1:o-1);
            end
            o = o+1;
        end
    end


    %Add words:
    wordsleft = allwords(randperm(length(allwords)),:);
    for n = 1:length(completelist) %240
        completelist{n,1} = wordsleft{n};

        if n <= lrec*numlists/2
            completelist{n,2} = 'Full';
        else
            completelist{n,2} = 'Divided';
        end

        if rem(n,2) == 0 %Half need to be Color 1
            completelist{n,3} = '1';
        else
            completelist{n,3} = '2';
        end
    end
    wordsleft = wordsleft((length(completelist)+1):end,:); %for adding new words in test

    %Create Lists:
    falist = completelist(1:length(completelist)/2,:);
    dalist = completelist(1+length(completelist)/2:length(completelist),:);

    studylists = cell(numlists,1);
    studylists(:,1) = {cell(lrec,8)};

    for n = 1:numlists
        studylists{n,1} = completelist(1+lrec*(n-1):lrec*n,:);
        studylists{n,1}(1:lrec/2,6) = {'firsthalf'};
        studylists{n,1}(lrec/2+1:lrec,6) = {'secondhalf'};
        studylists{n,1}(:,7) = {int2str(n)};
        if sum(ismember(studylists{n,1}(:,2), 'Full')) > 0
            rowadj = 1;
            coladj = n;
            studylists{n,1}(:,8) = {'N/A'};
        else
            rowadj = 2;
            coladj = n-numlists/2;
            studylists{n,1}(:,8) = {int2str(coladj)};
        end

        studylists{n,1}(:,4) = presrates(rowadj, coladj);
        lsect = round(lrec*(1-trialratio)/2);
        studylists{n,1}(1:lsect,5) = {'oldnew'};
        studylists{n,1}(1+lsect:3*lsect,5) = {'Discrim'};
        studylists{n,1}(1+3*lsect:4*lsect,5) = {'oldnew'};
        studylists{n,1}(1+4*lsect:end,5) = {'Discrim'};
    end

    %Creates test lists from study lists. (Adds in new words, has new columns
    %for Cresp. Subject number also determines what color is chosen).

    testlists = cell(numlists,1);
    testlists(:,1) = {cell(lrec*(4/3), 12)}; %adjust to change old/new proportions.

    for n = 1:numlists
		%First 30 of test are all Old items. Then add New items, finally shuffle
        testlists{n,1}(1:lrec, 1:7) = studylists{n,1}(:,1:7);

        for o = 1:lrec
            if strcmp(testlists{n,1}{o,5}, 'oldnew')
                testlists{n,1}{o,8} = 'old';
                testlists{n,1}{o,9} = 'c'; %key press needed
            else
                if strcmp(testlists{n,1}{o,3}, '1')
					%color 1 requires old response (note that 'color 1' actually is made
					%to switch colors in the experiment script).
                    testlists{n,1}{o,8} = 'Old Response';
                    testlists{n,1}{o,9} = 'd';
                else
                    testlists{n,1}{o,8} = 'New Response';
                    testlists{n,1}{o,9} = 'j';
                end
            end
        end

        q = 1;
        for p = lrec+1:length(testlists{n,1}(:,:))

            testlists{n,1}{p,1} = wordsleft{q,1};
            q = q + 1;

            testlists{n,1}{p,4} = studylists{n,1}{1,4};
            testlists{n,1}{p,5} = 'oldnew';
            testlists{n,1}{p,6} = 'N/A';       %whether it was from first or second half.
            testlists{n,1}{p,7} = int2str(n);
            testlists{n,1}{p,8} = 'new';
            testlists{n,1}{p,9} = 'n';

            if n <= numlists/2
                testlists{n,1}{p,2} = 'Full';
            else
                testlists{n,1}{p,2} = 'Divided';
            end
            if rem(p, 2) == 0
                testlists{n,1}{p,3} = '1';
            else
                testlists{n,1}{p,3} = '2';
            end
        end
        wordsleft = wordsleft((lrec/3)+1:end, :); %/3 determines proportion of new words.
    end


    %Checking to see if everything got sorted correctly
	%C2 = first half type of response consistency, C4 = second half type of response
	%consistency. Weird indexes due to originally having more checks
    checkcount = zeros(2,4);
    falist = {};
    dalist = {};
    adjust = numlists/2;

    firsthalfsort = [];
    for n = 1:numlists/2
        firsthalfsort = [firsthalfsort, (1:lrec/2)+ lrec*(n-1)];
        falist = [falist; studylists{n,1}];
        dalist = [dalist; studylists{n+adjust,1}];
    end


    secondhalfsort = firsthalfsort + lrec/2;
    for n = 1:2
        switch n
            case 1
                currentlist = falist;
            case 2
                currentlist = dalist;
        end

        firsthalf = currentlist(firsthalfsort,:);
        secondhalf = currentlist(secondhalfsort,:);
        if sum(ismember(firsthalf(:,5), 'Discrim')) == 2*sum(ismember(firsthalf(:,5), 'oldnew'))
            checkcount(n,2) = 1;
        end

        if sum(ismember(secondhalf(:,5), 'Discrim')) == 2*sum(ismember(secondhalf(:,5), 'oldnew'))
            checkcount(n,4) = 1;
        end
    end


    %Checks to see if any words are being used more than once.
    wordreps = zeros(8,3);
    for n = 1:numlists
        for o = 1:numlists
            if n ~= o
                if sum(ismember(studylists{n,1}(:,1), studylists{o,1}(:,1))) > 0
                    wordreps(n,1) = o;
                end
                if sum(ismember(testlists{n,1}(:,1), testlists{o,1}(:,1))) > 0
                    wordreps(n,2) = o;
                end
            end
        end

        for p = 1:numlists
            if n~= p
                if sum(ismember(studylists{n,1}(:,1), testlists{p,1}(:,1))) > 0
                    wordreps(n,3) = p;
                end
            end
        end
    end

    for n = 1:numlists
		%scramble first, then second half of each list
        studylists{n,1}(1:lrec/2,:) = studylists{n,1}(randperm(length(studylists{n,1})/2),:);
        studylists{n,1}(1+lrec/2:lrec,:) = studylists{n,1}(randperm(length(studylists{n,1})/2)+lrec/2,:);
        testlists{n,1}(:,:) = testlists{n,1}(randperm(length(testlists{n,1})),:);
    end


    %Making Sound File Lists
    lsound = zeros(numlists/2,1);

    soundlists = cell(numlists/2, 1);
    for n = 1:numlists/2
        lsound(n) = ceil(((str2double(studylists{n+numlists/2}{1,4}) + waitTime2) * lrec)/rate) + buffer*2;
        soundlists(n,1) = {cell(lsound(n), 5)};
    end

    %For the divided attention task, people must press space whenever 3 odd
    %numbers in a row occur.
    for m = 1:4
        check = 0;
        while ~check
            soundlists{m,1}(:,1) = num2cell(randi(9, lsound(m),1));
            soundlists{m,1}(1:2,2) = {'not 3'};
            for n = 3:length(soundlists{m,1});
                first = soundlists{m,1}{n-2,1};
                second = soundlists{m,1}{n-1,1};
                third = soundlists{m,1}{n,1};

                if rem(first, 2) > 0 && rem(second, 2) > 0 && rem(third, 2) > 0
                    soundlists{m,1}{n,2} = '3 odds';
                else
                    soundlists{m,1}{n,2} = 'not 3';
                end
            end

            indexes = find(ismember(soundlists{m,1}(:,2), '3 odds'));
            threeoddcount = sum(ismember(soundlists{m,1}(:,2), '3 odds'));

            backtoback = 0;
            for o = 2:length(indexes)
                first = indexes(o-1);
                second = indexes(o);
                if second-first == 1
                    backtoback = 1;
                end
            end

			%Ensures there are at least a few 3 odds to listen for,
			%and that none are back to back.
            if threeoddcount > ceil(lsound(m)/10) && ~backtoback
                check = 1;
            end
        end
    end


    %Creating Schedules
    schedules = cell(numlists, 1);
    for m = 1:8
        currentlist = studylists{m,1};
        presrate = str2double(currentlist{1,4});
        numtrials = length(currentlist);

        schedule = zeros(500, 6);

        starttimes = cell(numtrials, 5);
        stoptimes = cell(numtrials, 5);

        for n = 1:numtrials
            starttimes(n,1) = num2cell(0 + (n-1)*(presrate+waitTime2)); %start times
            stoptimes(n,1) = num2cell(n*presrate + (n-1)*waitTime2);
            starttimes(n,3) = currentlist(n,1);
            stoptimes(n,3) = currentlist(n,1);
            starttimes{n,4} = 'start';
            stoptimes{n,4} = 'stop';

        end

        if strcmp(currentlist{1,2}, 'Full')
            finalschedule = [starttimes; stoptimes];
            finalschedule = sortrows(finalschedule,1);
            finalschedule(:,5) = {'N/A'}; %whether or not there are 3 odd numbers in a row
        else
            starttimes(:,1) = num2cell(cell2mat(starttimes(:,1)) + rate*buffer);
            stoptimes(:,1) = num2cell(cell2mat(stoptimes(:,1)) + rate*buffer);
            currentsoundlist = soundlists{str2double(currentlist{m,8})};
            numsounds = length(currentsoundlist);
            soundtimes = cell(numsounds, 5);
            for n = 1:numsounds
                soundtimes{n,1} = 0 + (n-1)*rate;
                soundtimes{n,3} = currentsoundlist{n,1};
                soundtimes{n,4} = 'sound';
                soundtimes{n,5} = currentsoundlist{n,2};
            end
            finalschedule = [starttimes; stoptimes; soundtimes];
            finalschedule = sortrows(finalschedule,1);


            for n = 2:length(finalschedule)
                if isempty(finalschedule{n,5})
                    finalschedule{n,5} = finalschedule{n-1,5};
                end
            end
        end
        finalschedule = sortrows(finalschedule,1);

		%time to pause until next trial, last one is 0 (no next trial).
        for n = 1:length(finalschedule)-1
            finalschedule{n,2} = finalschedule{n+1,1} - finalschedule{n,1};
        end

        schedules(m,1) = {finalschedule};
    end

    %Randomizes order
    neworder = randperm(8);
    studylists = studylists(neworder,:);
    testlists = testlists(neworder,:);
    schedules = schedules(neworder,:);

    subjectfilename = strcat('SubjectFiles\Subject', int2str(subn), '_allfiles.mat');
    save(subjectfilename, 'buffer', 'numlists', 'rate', 'lrec', 'studylists',
		'testlists', 'soundlists', 'schedules');
end



%     %%%%Create Practice schedule (only needed to run once):
%     %%%%load('practice.mat');
%     lprac = 12;
%
%     %%%Loads a separate Practice word list.
%     [~, ~, allpwords] = xlsread('stimuli\PracticeList.xlsx');
%     allpwords = allpwords(2:end,:);
%     for n = 1:length(allpwords)
%         o = 1;
%         check = 0;
%         while o <= 8 && check == 0
%             if strcmp(allpwords{n,1}(o), ' ')
%                 check = 1;
%                 allpwords{n,1} = allpwords{n,1}(1:o-1);
%             end
%             o = o+1;
%         end
%     end
%
%     %Creates Practice study list
%     practicelists = cell(2,1);
%     presrate = '2.5';
%     for n = 1:2
%         practicelists{n,1} = cell(lprac,8);
%
%         for o = 1:lprac
%             practicelists{n,1}{o,1} = allpwords{(n-1)*lprac+o,1};
%             practicelists{n,1}{o,4} = presrate;
%
%             if rem(o,2) == 0
%                 practicelists{n,1}{o,3} = '1';
%             else
%                 practicelists{n,1}{o,3} = '2';
%             end
%
%             if o <= lprac/2
%                 practicelists{n,1}{o,6} = 'firsthalf';
%             else
%                 practicelists{n,1}{o,6} = 'secondhalf';
%             end
%
%             if n == 1
%                 practicelists{n,1}{o,2} = 'Full';
%                 practicelists{n,1}{o,8} = 'N/A';
%             else
%                 practicelists{n,1}{o,2} = 'Divided';
%                 practicelists{n,1}{o,8} = '1';
%             end
%         end
%
%         lsect = round(lprac*(1-trialratio)/2);
%         practicelists{n,1}(1:lsect,5) = {'oldnew'};
%         practicelists{n,1}(1+lsect:3*lsect,5) = {'Discrim'};
%         practicelists{n,1}(1+3*lsect:4*lsect,5) = {'oldnew'};
%         practicelists{n,1}(1+4*lsect:end,5) = {'Discrim'};
%     end
%
%
%     %%%%Creates practice test list.
%     practicetestlists = cell(2,1);
%     practicetestlists(1:2,1) = {cell(lprac*(1+(1-trialratio)), 12)};
%
%     for n = 1:2
%         practicetestlists{n,1}(1:lprac, 1:7) = practicelists{n,1}(:,1:7);
%
%         for o = 1:lprac
%             if strcmp(practicetestlists{n,1}{o,5}, 'oldnew')
%                 practicetestlists{n,1}{o,8} = 'old';
%                 practicetestlists{n,1}{o,9} = 'c'; %key press needed
%             else
%
%                 if strcmp(practicetestlists{n,1}{o,3}, '1') %color 1 requires old response
%                     practicetestlists{n,1}{o,8} = 'Old Response';
%                     practicetestlists{n,1}{o,9} = 'd';
%                 else
%                     practicetestlists{n,1}{o,8} = 'New Response';
%                     practicetestlists{n,1}{o,9} = 'j';
%                 end
%             end
%         end
%
%         q = 1;
%         wordadjust = lprac*2 + (n-1)*(lprac/3);   %number of words already used.
%         for p = lprac+1:length(practicetestlists{n,1}(:,:))
%
%             practicetestlists{n,1}{p,1} = allpwords{wordadjust+q,1};
%             q = q + 1;
%
%             practicetestlists{n,1}{p,4} = presrate;
%
%             practicetestlists{n,1}{p,5} = 'oldnew';
%             practicetestlists{n,1}{p,6} = 'N/A';
%             practicetestlists{n,1}{p,8} = 'new';
%             practicetestlists{n,1}{p,9} = 'n';
%
%             if n <= numlists/2
%                 practicetestlists{n,1}{p,2} = 'Full';
%             else
%                 practicetestlists{n,1}{p,2} = 'Divided';
%             end
%             if rem(p, 2) == 0
%                 practicetestlists{n,1}{p,3} = '1';
%             else
%                 practicetestlists{n,1}{p,3} = '2';
%             end
%         end
%     end
%
%     %Scrambles each half of the study and test lists.
%     for n = 1:2
%         practicelists{n,1}(1:length(practicelists{n,1})/2,:) = practicelists{n,1}(randperm(length(practicelists{n,1})/2),:);
%         practicelists{n,1}(1+length(practicelists{n,1})/2:length(practicelists{n,1}),:) = ...
%				practicelists{n,1}(randperm(length(practicelists{n,1})/2)+length(practicelists{n,1})/2,:);
%         practicetestlists{n,1}(:,:) = practicetestlists{n,1}(randperm(length(practicetestlists{n,1})),:);
%     end
%
%     %%Create Practice Sound Lists
%     lpracsound = ceil(((str2double(presrate)+waitTime2)*lprac)/rate);
%     lpracsound = lpracsound+buffer*2;
%     practicesoundlist = cell(lpracsound, 5);
%
%     for n = 1:length(practicesoundlist)
%         practicesoundlist{n,1} = randi(9,1);
%     end
%
%
%     standalonesounds = practicesoundlist(randperm(length(practicesoundlist)),:);
%
%     practicesoundlist(1:2,2) = {'not 3'};
%     standalonesounds(1:2,2) = {'not 3'};
%     for m = 1:2
%         switch m
%             case 1
%                 csoundlist = standalonesounds;
%             case 2
%                 csoundlist = practicesoundlist;
%         end
%
%         for n = 3:length(csoundlist);
%             first = csoundlist{n-2,1};
%             second = csoundlist{n-1,1};
%             third = csoundlist{n,1};
%
%             if rem(first, 2) > 0 && rem(second, 2) > 0 && rem(third, 2) > 0
%                 csoundlist{n,2} = '3 odds';
%             else
%                 csoundlist{n,2} = 'not 3';
%             end
%         end
%
%         if m == 1
%             standalonesounds = csoundlist;
%         else
%             practicesoundlist = csoundlist;
%         end
%     end
%
%     %%CREATE STANDALONE SCHEDULE
%     standaloneschedule = cell(length(standalonesounds),5);
%     standaloneschedule(:,1) = num2cell([0:rate:(length(standalonesounds)-1)*rate]');
%     standaloneschedule(:,2) = {rate};
%     standaloneschedule(:,3) = standalonesounds(:,1);
%     standaloneschedule(:,4) = {'sound'};
%     standaloneschedule(:,5) = standalonesounds(:,2);
%
%     %%CREATE PRACTICE SCHEDULE
%     practiceschedules = cell(2,1);
%     for m = 1:2
%         currentlist = practicelists{m,1};
%         presrate = 2.5;
%         numtrials = length(currentlist);
%
%
%         starttimes = cell(numtrials, 5);
%         stoptimes = cell(numtrials, 5);
%
%         for n = 1:numtrials
%             starttimes(n,1) = num2cell(0 + (n-1)*(presrate+waitTime2)); %start times
%             stoptimes(n,1) = num2cell(n*presrate + (n-1)*waitTime2);
%             starttimes(n,3) = currentlist(n,1);
%             stoptimes(n,3) = currentlist(n,1);
%             starttimes{n,4} = 'start';
%             stoptimes{n,4} = 'stop';
%
%         end
%
%         if strcmp(currentlist{1,2}, 'Full')
%             practiceschedule = [starttimes; stoptimes];
%             practiceschedule = sortrows(practiceschedule,1);
%             practiceschedule(:,5) = {'N/A'}; %whether there are 3 odd numbers in a row
%         else
%             starttimes(:,1) = num2cell(cell2mat(starttimes(:,1)) + rate*buffer);
%             stoptimes(:,1) = num2cell(cell2mat(stoptimes(:,1)) + rate*buffer);
%
%             numsounds = length(practicesoundlist);
%             soundtimes = cell(numsounds, 5);
%             for n = 1:numsounds
%                 soundtimes{n,1} = 0 + (n-1)*rate;
%                 soundtimes{n,3} = practicesoundlist{n,1};
%                 soundtimes{n,4} = 'sound';
%                 soundtimes{n,5} = practicesoundlist{n,2};
%             end
%             practiceschedule = [starttimes; stoptimes; soundtimes];
%             practiceschedule = sortrows(practiceschedule,1);
%
%
%             for n = 2:length(practiceschedule)
%                 if isempty(practiceschedule{n,5})
%                     practiceschedule{n,5} = practiceschedule{n-1,5};
%                 end
%             end
%         end
%
%
%         practiceschedule = sortrows(practiceschedule,1);
%		  %time to pause until next trial, last one is 0 (no next trial).
%         for n = 1:length(practiceschedule)-1
%             practiceschedule{n,2} = practiceschedule{n+1,1} - practiceschedule{n,1};
%         end
%         practiceschedules(m,1) = {practiceschedule};
%     end
%
%     save('practice.mat', 'practiceschedules', 'practicelists', 'practicesoundlist', ...
%		'practicetestlists', 'standalonesounds', 'standaloneschedule');
