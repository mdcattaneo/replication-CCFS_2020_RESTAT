
clear all;

varList = {'RbarStandard', 'Gridpts', 'RbarGridpts', 'IdxJmseEst_v3', 'T'};

specVec = [7,9,11];
evalPctileVec = [2.5, 5, 10];
controlVarVec = {'ind0', 'ind37'};

%specVec = 7;
%controlVarVec = {'ind0'};
%evalPctileVec = 5;

% Load data
for spec = specVec
    disp(spec)
    for controlVar = controlVarVec
        disp(controlVar)
        for evalPctile = evalPctileVec
            %
            evalPctileString = num2str(evalPctile/100);
            %
            % ###
            currentDir = dir('###/*.mat');
            f1 = regexpi({currentDir.name}, controlVar, 'match');
            f2 = regexpi({currentDir.name}, ['spec', num2str(spec)], 'match');
            f3 = regexpi({currentDir.name}, 'only', 'match');
            f4 = regexpi({currentDir.name}, ['eval', evalPctileString(3:end)], 'match');
            %
            listFiles = {currentDir.name};
            idxFile = find(~cellfun(@isempty,f1) & ~cellfun(@isempty,f2) & cellfun(@isempty,f3) & ~cellfun(@isempty,f4));
            %
            % ###
            ds = load(['###/', listFiles{idxFile}], varList{:});
            % ###
            disp(['###/', listFiles{idxFile}]);
            %
            for varName = varList
               eval(['spec', num2str(spec), '_eval', evalPctileString(3:end), '_', controlVar{1}, '.', varName{1}, ' = ds.', varName{1}, ';']) 
            end                       
            clear ds
        end
   end
end

diary('tableInputs2_v3');

% Make table
for spec = specVec
    if (spec==7), disp('Spec 7: 1967-2015'); end
    if (spec==9), disp('Spec 9: 1980-2015'); end
    if (spec==11), disp('Spec 11: 1926-2015'); end
    %disp(spec);
    for controlVar=controlVarVec 
        disp(controlVar);
        for evalPctile = evalPctileVec
            evalPctileString = num2str(evalPctile/100);
            disp(evalPctileString);
            %
            dsString = ['spec', num2str(spec), '_eval', evalPctileString(3:end), '_', controlVar{1}];
            %
            dsGridpts = eval([dsString, '.Gridpts;']);
            dsRbarGridpts = eval([dsString, '.RbarGridpts;']);
            dsIdxJmseEst_v3 = eval([dsString, '.IdxJmseEst_v3;']);
            dsT = eval([dsString, '.T;']);
            dsRbarStandard = eval([dsString, '.RbarStandard;']);
            
            idxBot = knnsearch(dsGridpts', norminv(evalPctile/100), 'K', 1);
            idxTop = knnsearch(dsGridpts', norminv(1-evalPctile/100), 'K', 1);
            %                        
            peBot = mean(dsRbarGridpts{dsIdxJmseEst_v3(end)}(idxBot,:));
            peTop = mean(dsRbarGridpts{dsIdxJmseEst_v3(end)}(idxTop,:));
            %
            varBot = var(dsRbarGridpts{dsIdxJmseEst_v3(end)}(idxBot,:),1)/dsT;
            varTop = var(dsRbarGridpts{dsIdxJmseEst_v3(end)}(idxTop,:),1)/dsT;            
            
            disp('CCFS ESTIMATOR');
            disp('');
            disp('Bottom point estimate');
            disp(peBot);
            disp('Bottom t-Statistic');
            disp(peBot/sqrt(varBot));

            disp('Top point estimate');
            disp(peTop);
            disp('Top t-Statistic');
            disp(peTop/sqrt(varTop));  
            
            disp('Difference point estimate');
            disp( peTop-peBot);
            disp('Difference t-Statistic');
            disp((peTop-peBot)/sqrt(varBot + varTop))  
            
            peBotStandard = mean(dsRbarStandard(1,:));
            peTopStandard = mean(dsRbarStandard(10,:));
            
            varBotStandard = var(dsRbarStandard(1,:))/dsT;
            varTopStandard = var(dsRbarStandard(10,:))/dsT;
            
            if (evalPctile==evalPctileVec(1))
            
                disp('Standard ESTIMATOR');
                disp('')
                disp('Bottom point estimate');
                disp(peBotStandard);
                disp('Bottom t-Statistic');
                disp(peBotStandard/sqrt(varBotStandard));

                disp('Top point estimate');
                disp(peTopStandard);
                disp('Top t-Statistic');
                disp(peTopStandard/sqrt(varTopStandard));            

                disp('Difference point estimate');
                disp(peTopStandard-peBotStandard);
                disp('Difference t-Statistic');
                disp((peTopStandard-peBotStandard)/sqrt(varBotStandard + varTopStandard));  
                
            end
             
        end
    end
    disp('');    
end

diary off;


