%Last updated by Michael Griffin - 9.24.2014
%Run after analysis_preproc generates fullsummary files.
%Rebuilds fullsummary files to make 'tidy'. Each row contains 1 data point, and condition
%labels are now explicitly written into corresponding row.

%While SPSS liked having a separate column for each condition of a repeated
%measures ANOVA, R likes having one column for all responses,
%and separate columns for each factor.

pkg load io %in Octave allows xlswrite/xlsread

exp = 1;
[data, txt, raw] = xlsread(['fullsummary_formatted_exp', int2str(exp), '.xlsx']);

allformatted = cell(16*length(data),5);
for n = 1:length(data)
    cformatted = cell(16, 5);
    %Columns should be laid out as 'Sub', 'D prime', 'judgment', 'attention', 'study time'
    craw = data(n,2:end);

    cformatted(:,1) = {['Sub', int2str(data(n,1))]}; %originally {data(n,1)}

    for o = 1:16
       cformatted{o,2} = craw(o);
    end

    cformatted(1:8,3) = {'oldnew'};
    cformatted(9:16,3) = {'color'};
    cformatted(1:4,4) = {'full'};
    cformatted(9:12,4) = {'full'};
    cformatted(5:8,4) = {'divided'};
    cformatted(13:16,4) = {'divided'};

    for o = 1:4
        for p = 1:4
            index = (o-1)*4+p;
            label = ['time', int2str(p)];
            cformatted(index,5) = {label};
        end
    end

    startindex = (n-1)*16+1;
    endindex = n*16;
    allformatted(startindex:endindex,:) = cformatted;
end

filename = ['Rformatted_exp', int2str(exp), '.xlsx'];
xlswrite(filename, allformatted);
