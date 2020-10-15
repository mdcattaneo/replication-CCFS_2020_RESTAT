
function [] = ccfsMainFcn(spec, numPort, maxPort, evalPctile, localpoints, controlIndustries)

tic

% Define Specifications of Interest
if (spec==1), yearStart = 1967; monthStart = 1; yearEnd = 2015; monthEnd = 12; sortVar = 'mktEqtyLag'; sortVarTransform = 'logzscore'; weightVar = 'mktEqtyLag'; end
if (spec==2), yearStart = 1967; monthStart = 1; yearEnd = 2007; monthEnd = 12; sortVar = 'mktEqtyLag'; sortVarTransform = 'logzscore'; weightVar = 'mktEqtyLag'; end
if (spec==3), yearStart = 1980; monthStart = 1; yearEnd = 2015; monthEnd = 12; sortVar = 'mktEqtyLag'; sortVarTransform = 'logzscore'; weightVar = 'mktEqtyLag'; end
if (spec==4), yearStart = 1980; monthStart = 1; yearEnd = 2007; monthEnd = 12; sortVar = 'mktEqtyLag'; sortVarTransform = 'logzscore'; weightVar = 'mktEqtyLag'; end
if (spec==5), yearStart = 1926; monthStart = 1; yearEnd = 2015; monthEnd = 12; sortVar = 'mktEqtyLag'; sortVarTransform = 'logzscore'; weightVar = 'mktEqtyLag'; end
if (spec==6), yearStart = 1926; monthStart = 1; yearEnd = 2007; monthEnd = 12; sortVar = 'mktEqtyLag'; sortVarTransform = 'logzscore'; weightVar = 'mktEqtyLag'; end

if (spec==7),  yearStart = 1967; monthStart = 1; yearEnd = 2015; monthEnd = 12; sortVar = 'momentum12_2'; sortVarTransform = 'zscore'; weightVar = 'mktEqtyLag'; end
if (spec==8),  yearStart = 1967; monthStart = 1; yearEnd = 2007; monthEnd = 12; sortVar = 'momentum12_2'; sortVarTransform = 'zscore'; weightVar = 'mktEqtyLag'; end
if (spec==9),  yearStart = 1980; monthStart = 1; yearEnd = 2015; monthEnd = 12; sortVar = 'momentum12_2'; sortVarTransform = 'zscore'; weightVar = 'mktEqtyLag'; end
if (spec==10), yearStart = 1980; monthStart = 1; yearEnd = 2007; monthEnd = 12; sortVar = 'momentum12_2'; sortVarTransform = 'zscore'; weightVar = 'mktEqtyLag'; end
if (spec==11), yearStart = 1927; monthStart = 1; yearEnd = 2015; monthEnd = 12; sortVar = 'momentum12_2'; sortVarTransform = 'zscore'; weightVar = 'mktEqtyLag'; end
if (spec==12), yearStart = 1927; monthStart = 1; yearEnd = 2007; monthEnd = 12; sortVar = 'momentum12_2'; sortVarTransform = 'zscore'; weightVar = 'mktEqtyLag'; end

% User-defined inputs
indLoadMatFile = false;
indCRSPonly = true;
indNYSEonly = false;
indSeePlots = false;
indSaveData = true;
returnVar = 'ret';

if (indCRSPonly == indNYSEonly), error('CRSP and NYSE settings are inconsistent'); end

% Process inputs and define file names
evalPctileString = num2str(evalPctile/100);
timeHour = num2str(hour(now));
timeMinute = num2str(minute(now));
timeStamp = [date, '-', timeHour, timeMinute];

fileName = [timeStamp, '_spec', num2str(spec), '_eval', evalPctileString(3:end), '_local', num2str(localpoints), '_ind', num2str(controlIndustries)];
fileNameTruncated = ['_spec', num2str(spec), '_eval', evalPctileString(3:end), '_local', num2str(localpoints), '_ind', num2str(controlIndustries)];


if (controlIndustries==0)
    controlVar = '';
elseif (controlIndustries==12) % Dropping 'ind12_12'
    controlVar = {'ind12_1', 'ind12_2', 'ind12_3', 'ind12_4', 'ind12_5', 'ind12_6', 'ind12_7', 'ind12_8', 'ind12_9', 'ind12_10', 'ind12_11'};    
elseif (controlIndustries==37) % Dropping 'ind37'
    controlVar = {'ind1', 'ind2', 'ind3', 'ind4', 'ind5', 'ind6', 'ind7', 'ind8', 'ind9', 'ind10', 'ind11', 'ind12', 'ind13', 'ind14', 'ind15', ...
         'ind16', 'ind17', 'ind18', 'ind19', 'ind20', 'ind21', 'ind22', 'ind23', 'ind24', 'ind25', 'ind26', 'ind27', 'ind28', 'ind29', 'ind30', ...
         'ind31', 'ind32', 'ind33', 'ind34', 'ind35', 'ind36'};
elseif strcmp(controlIndustries,'12rel')
    controlVar = {'ind12momentum12_2', 'ind12momentum12_2_SQ', 'ind12momentum12_2_CU'};    
elseif strcmp(controlIndustries,'37rel')
    controlVar = {'ind37momentum12_2', 'ind37momentum12_2_SQ', 'ind37momentum12_2_CU'};
end

disp(['controlVar:', controlVar]);
disp(' ')

% Report specification
disp(['Specification: ', num2str(spec)]);
disp(' ');
% Report Dates
disp(['Start date is ', num2str(yearStart), ':', num2str(monthStart)]);
disp(['Start date is ', num2str(yearEnd), ':', num2str(monthEnd)]);
disp(' ');
% Report other aspects
disp(['Sorting variable: ', sortVar]);
disp(['Sorting Variable Transform: ', sortVarTransform]);
disp(['Weight variable: ', weightVar]);
if isempty(controlVar), disp('Control variables: none'); else disp(['Control variables: ', num2str(controlIndustries), ' Industry dummies']); end
disp(['Evaluation Percentile: ', evalPctileString]);
disp(['# of local points: ', num2str(localpoints)]);
disp(' ');

% LOAD IN DATA
if ~indLoadMatFile
    if indCRSPonly
        rawData = dlmread('CRSPonly.csv', ',', 1,0);
        fid = fopen('CRSPonlyLabels.csv');
        varNames = textscan(fid, '%s', 'delimiter', ',');
        fclose(fid);
    elseif indNYSEonly
        rawData = dlmread('NYSEonly.csv', ',', 1,0);
        fid = fopen('NYSEonlyLabels.csv');
        varNames = textscan(fid, '%s', 'delimiter', ',');
        fclose(fid);        
    end
    rawData(rawData == -999) = NaN;
    for i = 1:numel(varNames{1}), eval([varNames{1}{i}, ' = rawData(:,', num2str(i), ');']); end
    %save(['CRSPonly.mat']);
    %save(['NYSEonly.mat']);
else
    if indCRSPonly
        load('CRSPonly.mat');
    elseif indNYSEonly      
        load('NYSEonly.mat');
    end    
end

disp('Data is loaded');
disp(' ');

% Find indexes for variables of interest
for i = 1:numel(varNames{1})
   if strcmp(varNames{1}{i}, sortVar), idxSortVar = i; end
   if strcmp(varNames{1}{i}, returnVar), idxReturnVar = i; end
   if ~isempty(weightVar)
       if strcmp(varNames{1}{i}, weightVar), idxWeightVar = i; end
   else
       idxWeightVar = [];
   end
   if ~isempty(controlVar)
       idxControlVar = find(ismember(varNames{1},controlVar));
   end   
end   

T = 12*(yearEnd-yearStart-1) + (12-monthStart+1) + monthEnd;
data = cell(T,5);        

iYear = yearStart;
iMonth = monthStart;
t = 1;

% Generate cell of data for empirical analysis
while t<=T
    idxTemp = (datey==iYear) & (datem==iMonth) & ~isnan(rawData(:,idxReturnVar)) & ~isnan(rawData(:,idxSortVar));    
    if all([~isempty(weightVar), isempty(controlVar)])
        idxTemp = idxTemp & ~isnan(rawData(:,idxWeightVar));
    elseif all([isempty(weightVar), ~isempty(controlVar)])
        idxTemp = idxTemp & logical(prod(~isnan(rawData(:,idxControlVar)),2));
    elseif all([~isempty(weightVar), ~isempty(controlVar)])
        idxTemp = idxTemp & ~isnan(rawData(:,idxWeightVar)) & logical(prod(~isnan(rawData(:,idxControlVar)),2));
    end
    data{t,1} = rawData(idxTemp,idxReturnVar);
    data{t,2} = rawData(idxTemp,idxSortVar);
    if ~isempty(controlVar), data{t,3} = rawData(idxTemp,idxControlVar); end
    data{t,4} = [iYear, iMonth];
    data{t,5} = sum(idxTemp);
    data{t,6} = rawData(idxTemp,idxWeightVar);            
    
    iMonth = (iMonth+1)*(iMonth+1 <= 12) + mod(iMonth+1,12)*(iMonth+1 > 12);
    if (iMonth==1), iYear = iYear+1; end
    t = t+1;
end

disp('Variables are defined');
disp(' ');

clear rawData
clearvars -except spec evalPctileString data maxPort numPort T sortVarTransform controlVar evalPctile localpoints indSeePlots timeStamp ...
                  sortVar weightVar yearStart yearEnd monthStart monthEnd fileName fileNameTruncated indSaveData  ...
                  indCRSPonly indNYSEonly controlIndustries

ntVec = cell2mat(data(:,5));  %plot(ntVec)
n = max(ntVec);

%**% Portfolios Considered %**%
% Define Starting J
portVec = unique(ceil(linspace(2/(min(ntVec)/n)^(1/2), maxPort, numPort)));
Quantile = cell(numel(portVec),T);
z = cell(1,T);
x = cell(1,T);
R = cell(1,T);
w = cell(1,T);

muPrimeEvalptsLTemp = NaN(numel(portVec),T);
muPrimeEvalptsHTemp = NaN(numel(portVec),T);

SupportLTemp = NaN(1,T);
SupportHTemp = NaN(1,T);
    
for t = 1:T
    R{t} = data{t,1}(:,1);    
    %
    if isempty(sortVarTransform), z{t} = data{t,2}; end    
    if strcmp(sortVarTransform, 'rankzscore')
        [~, rankTemp] = ismember(data{t,2},sort(data{t,2}));
        z{t} = (rankTemp-mean(rankTemp)/std(rankTemp)); 
    end
    if strcmp(sortVarTransform, 'zscore'), z{t} = (data{t,2}-mean(data{t,2}))/std(data{t,2}); end
    if strcmp(sortVarTransform, 'logzscore'), z{t} = (log(data{t,2})-mean(log(data{t,2})))/std(log(data{t,2})); end
    if strcmp(sortVarTransform, 'logmax'), z{t} = log(data{t,2})/log(max(data{t,2})); end
    if strcmp(sortVarTransform, 'logmean'), z{t} = log(data{t,2})/log(mean(data{t,2})); end    
    %
    if ~isempty(controlVar), x{t} = data{t,3}; end
    w{t} = data{t,6};
    SupportLTemp(t) = min(z{t});
    SupportHTemp(t) = max(z{t});    
end

for j = 1:numel(portVec)
    for t = 1:T
        Jt = floor(portVec(j)*(ntVec(t)/n)^(1/2));               
        Quantile{j,t} = quantile(z{t}, ((1:1:(Jt-1))/Jt));        
        muPrimeEvalptsLTemp(j,t) = Quantile{j,t}(1);
        muPrimeEvalptsHTemp(j,t) = Quantile{j,t}(end);      
    end
end

SupportL = min(SupportLTemp);
SupportH = max(SupportHTemp);

if any(strcmp(sortVarTransform, {'zscore', 'logzscore'}))
    muPrimeEvalptsL = norminv(evalPctile/100)*ones(numel(portVec),1);
    muPrimeEvalptsH = norminv(1-evalPctile/100)*ones(numel(portVec),1);
else
    muPrimeEvalptsL = min(min(muPrimeEvalptsLTemp))*ones(numel(portVec),1);
    muPrimeEvalptsH = max(max(muPrimeEvalptsHTemp))*ones(numel(portVec),1);
end

Gridpts = sort([linspace(SupportL,SupportH,500), norminv(evalPctile/100), norminv(1-evalPctile/100)]);

RbarGridpts = cell(numel(portVec),1);
RbarGridptsAlt = cell(numel(portVec),1);
Rbar = cell(numel(portVec),T);
evalLPort = cell(numel(portVec),T);
evalRPort = cell(numel(portVec),T);
zbar = cell(numel(portVec),T);
N = cell(numel(portVec),T);
e2hat = cell(numel(portVec),T);
betahat = cell(numel(portVec),T);
muPrimeL= cell(numel(portVec),1);
muPrimeH= cell(numel(portVec),1);

RbarStandard = NaN(10,T);
NtStandard = NaN(10,T);

RbarL = NaN(numel(portVec),T);
RbarH = NaN(numel(portVec),T);
zbarL = NaN(numel(portVec),T);
zbarH = NaN(numel(portVec),T);
NL = NaN(numel(portVec),T);
NH = NaN(numel(portVec),T);
e2hatH = NaN(numel(portVec),T);
e2hatL = NaN(numel(portVec),T);
e2hat1H = NaN(numel(portVec),T);
e2hat1L = NaN(numel(portVec),T);
e2hat2H = NaN(numel(portVec),T);
e2hat2L = NaN(numel(portVec),T);

muhat_CCFS = NaN(numel(portVec),T);
sdhat_CCFS = NaN(numel(portVec),T);
tstat_CCFS = NaN(numel(portVec),T);
tstat_CCFS1 = NaN(numel(portVec),T);
tstat_CCFS2 = NaN(numel(portVec),T);
tstat_FM = NaN(numel(portVec),T);

mseEst_var = NaN(numel(portVec),T);
mseEst_bias_v3 = NaN(numel(portVec),T);

toc

IdxLocalLzt = cell(1,T);
IdxLocalHzt = cell(1,T);

muPrimeEvalptsPoolH = NaN(1,T);
muPrimeEvalptsPoolL = NaN(1,T);

ttVec = unique(round(linspace(round(T/2),T,3)));

for t = 1:T
    tempL = knnsearch(z{t}, muPrimeEvalptsL(1), 'K', localpoints, 'IncludeTies', true);
    IdxLocalLzt{t} = tempL{1};
    tempH = knnsearch(z{t}, muPrimeEvalptsH(1), 'K', localpoints, 'IncludeTies', true);
    IdxLocalHzt{t} = tempH{1};
    %
    if ismember(t,ttVec)
        poolR = cat(1,R{1:t});
        poolz = cat(1,z{1:t});
        tempL = knnsearch(poolz, muPrimeEvalptsL(1), 'K', localpoints, 'IncludeTies', true);
        tempH = knnsearch(poolz, muPrimeEvalptsH(1), 'K', localpoints, 'IncludeTies', true);
        tempBetaH = poolR(tempH{1})\[ones(numel(tempH{1}),1), poolz(tempH{1})];    
        tempBetaL = poolR(tempL{1})\[ones(numel(tempL{1}),1), poolz(tempL{1})];
        muPrimeEvalptsPoolH(t) = tempBetaH(2);
        muPrimeEvalptsPoolL(t) = tempBetaL(2);
    end
end


for j = 1:numel(portVec)
    RbarGridpts{j} = NaN(numel(Gridpts),T);
    if isempty(controlVar)
        RbarGridptsAlt{j} = [];
    else
        RbarGridptsAlt{j} = NaN(numel(Gridpts),T);
    end
    muPrimeL{j} = NaN(2,T);    
    muPrimeH{j} = NaN(2,T);    
    disp(['Portfolio Choice: ', num2str(j), ' of ', num2str(numel(portVec))]);
    for t = 1:T
        %if mod(t,20)==0, disp([num2str(t), ' of ', num2str(T), ' completed']); end
        if (j==1)
           [RbarStandard(:,t), ~, ~, NtStandard(:,t), ~, ~, ~, ~, ~, ~, ~, ~, ~] = ccfsEst(R{t},z{t},[],w{t},[],10,[], ...
            'quantiles',[],[],[]);   
        end
        Jt = floor(portVec(j)*(ntVec(t)/n)^(1/2));
        [Rbar{j,t}, betahat{j,t}, zbar{j,t}, N{j,t}, ~, e2hat{j,t}, ~, ~, ~, RbarGridpts{j}(:,t), ...
            muPrimeTemp, evalPortTemp, RbarGridptsAlt{j}(:,t)] = ccfsEst(R{t},z{t},x{t},w{t},[],Jt,Gridpts,'quantiles', ...
            [muPrimeEvalptsL(j), muPrimeEvalptsH(j)],IdxLocalLzt{t}, IdxLocalHzt{t});
                
        evalLPort{j,t} = evalPortTemp(1);
        evalRPort{j,t} = evalPortTemp(2);
     
        RbarL(j,t) = Rbar{j,t}(evalLPort{j,t});
        RbarH(j,t) = Rbar{j,t}(evalRPort{j,t});
        zbarL(j,t) = zbar{j,t}(evalLPort{j,t});
        zbarH(j,t) = zbar{j,t}(evalRPort{j,t});        
        NL(j,t) = N{j,t}(evalLPort{j,t});
        NH(j,t) = N{j,t}(evalRPort{j,t});
        e2hatL(j,t) = e2hat{j,t}(evalLPort{j,t});
        e2hatH(j,t) = e2hat{j,t}(evalRPort{j,t});
        %
        muPrimeL{j}(1,t) = muPrimeTemp(1);
        muPrimeH{j}(1,t) = muPrimeTemp(2);
        muPrimeL{j}(2,t) = muPrimeTemp(3);
        muPrimeH{j}(2,t) = muPrimeTemp(4);         
        %
        muhat_CCFS(j,t) = mean(RbarH(j,1:t)) - mean(RbarL(j,1:t));
        varbot = mean((n./(n.^2)).*((NL(j,1:t)./n).^(-2)).*e2hatL(j,1:t));
        vartop = mean((n./(n.^2)).*((NH(j,1:t)./n).^(-2)).*e2hatH(j,1:t));
        numtest_CCFS = sqrt(n*t)*muhat_CCFS(j,t);
        dentest_CCFS = sqrt(varbot + vartop);
        sdhat_CCFS(j,t) = dentest_CCFS;
        tstat_CCFS(j,t) = numtest_CCFS/dentest_CCFS;
        %
        varbot1 = mean((n./(n.^2)).*((NL(j,1:t)./n).^(-2)).*e2hat1L(j,1:t));
        vartop1 = mean((n./(n.^2)).*((NH(j,1:t)./n).^(-2)).*e2hat1H(j,1:t));
        tstat_CCFS1(j,t) = numtest_CCFS/sqrt(varbot1 + vartop1);
        %
        varbot2 = mean((n./(n.^2)).*((NL(j,1:t)./n).^(-2)).*e2hat2L(j,1:t));
        vartop2 = mean((n./(n.^2)).*((NH(j,1:t)./n).^(-2)).*e2hat2H(j,1:t));
        tstat_CCFS2(j,t) = numtest_CCFS/sqrt(varbot2 + vartop2);
        if (t>1)
            numtest_FM = sqrt(t)*muhat_CCFS(j,t);
            dentest_FM = sqrt([1 -1]*cov([RbarH(j,1:t)' RbarL(j,1:t)'])*[1 -1]');
            tstat_FM(j,t) = numtest_FM/dentest_FM;
        else
            tstat_FM(j,t) = Inf;
        end
        % MSE Constants
        mseEst_var(j,t) = ((t-1)/t)*([1 -1]*cov([(NH(j,1:t).^(-1/2))'.*RbarH(j,1:t)' (NL(j,1:t).^(-1/2))'.*RbarL(j,1:t)'])*[1 -1]')/t;
        %
        mseEst_bias_v3(j,t) = (mean(muPrimeH{j}(1,1:t))*mean(zbarH(j,1:t)-muPrimeEvalptsH(j)) - ...
                               mean(muPrimeL{j}(1,1:t))*mean(zbarL(j,1:t)-muPrimeEvalptsL(j)))^2;
    end
toc    
end


%     Find MSE optimal choices
mseEst_v3 = mseEst_bias_v3 + mseEst_var;
[~, IdxJmseEst_v3] = min(squeeze(mseEst_v3),[],1);  

disp('')
disp('')

disp(['controlVar:', controlVar]);
disp(' ')

% Report specification
disp(['Specification: ', num2str(spec)]);
disp(' ');
% Report Dates
disp(['Start date is ', num2str(yearStart), ':', num2str(monthStart)]);
disp(['Start date is ', num2str(yearEnd), ':', num2str(monthEnd)]);
disp(' ');
% Report other aspects
disp(['Sorting variable: ', sortVar]);
disp(['Sorting Variable Transform: ', sortVarTransform]);
disp(['Weight variable: ', weightVar]);
if isempty(controlVar), disp('Control variables: none'); else disp(['Control variables: ', num2str(controlIndustries), ' Industry dummies']); end
disp(['Evaluation Percentile: ', evalPctileString]);
disp(['# of local points: ', num2str(localpoints)]);
disp(' ');
% 
disp('Local Regression (J(V3))')
disp(portVec(IdxJmseEst_v3(end)))

dateMat = cell2mat(data(:,4));
dateym = datenum(dateMat(:,1), dateMat(:,2), ones(size(dateMat(:,1))));

if isempty(controlVar), clear RbarGridptsAlt; end

IdxVec = [IdxJmseEst_v3(end)];

if min(diff(portVec))<=10
    for i=1:numel(portVec)
        if (mod(i,10)~=0 && ~ismember(i, IdxVec))
            RbarGridpts{i} = [];
            if ~isempty(controlVar), RbarGridptsAlt{i} = []; end    
        end
    end    
end

clearvars *Temp e2* data R x w z zbar poolR poolz betahat Quantile

lastwarn('');
if (indSaveData && indCRSPonly), save([fileName, '_CRSP.mat']); end
if (indSaveData && indNYSEonly), save([fileName, '_NYSE.mat']); end
if ~isempty(lastwarn)
    if (indSaveData && indCRSPonly), save([fileName, '_CRSP.mat'], '-v7.3'); end
    if (indSaveData && indNYSEonly), save([fileName, '_NYSE.mat'], '-v7.3'); end    
end

disp('Data are saved!!')
