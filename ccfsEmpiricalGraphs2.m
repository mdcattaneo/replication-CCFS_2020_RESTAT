% Momentum Effect
clear all;

fixedYLim = [-0.025, 0.025];

tic
for spec=7:2:12
    disp(spec)
   for control = {'ind0', 'ind37rel'} 
   %for control = {'ind0'} 
       disp(control);
       % Get the correct files to pull the estimation results
       % Using norminv(.025) and norminv(1-.025) evaluation points
       % ###
        currentDir = dir('###/*.mat');
        f1 = regexpi({currentDir.name}, control, 'match');
        f2 = regexpi({currentDir.name}, ['spec', num2str(spec)], 'match');
        f3 = regexpi({currentDir.name}, 'only', 'match');
        f4 = regexpi({currentDir.name}, 'eval025', 'match');
        %
        listFiles = {currentDir.name};
        idxFile = find(~cellfun(@isempty,f1) & ~cellfun(@isempty,f2) & cellfun(@isempty,f3) & ~cellfun(@isempty,f4));
        % Load data for spec and dataSource
        % ###
        ds = load(['###/', listFiles{idxFile}]);
        % ###
        disp(['###/', listFiles{idxFile}])
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Estimated mu plot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        fig = figure;
        plot(ds.Gridpts, mean(ds.RbarGridpts{ds.IdxJmseEst_v3(end)},2), 'k', 'LineWidth', 2)
        hold on
        if strcmp(control,'ind37rel')
%            if (spec==9), keyboard; end
            %plot(ds.Gridpts, mean(ds.RbarGridptsAlt{ds.IdxJmseEst_v3(end)},2), 'Color', .5*[1,1,1])
            plot(ds.Gridpts, mean(ds.RbarGridptsAlt{ds.IdxJmseEst_v3(end)},2), 'k-.', 'LineWidth', 1.5)
            hold on
        end
        set(gca, 'YLim', fixedYLim);
        line([norminv(.025) norminv(.025)], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        hold on
        line([norminv(.05) norminv(.05)], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        hold on
        line([norminv(.1) norminv(.1)], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        hold on
        line([norminv(1-.025) norminv(1-.025)], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        hold on
        line([norminv(1-.05) norminv(1-.05)], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        hold on
        line([norminv(1-.1) norminv(1-.1)], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')               
        if strcmp(ds.sortVarTransform, 'zscore'), set(gca, 'XLim',...
            [min([-5, ds.muPrimeEvalptsL(ds.IdxJmseEst_v3(end)), ds.muPrimeEvalptsL(ds.IdxJmseEst_v3(end))]-.25) ...
            max([5, ds.muPrimeEvalptsH(ds.IdxJmseEst_v3(end)), ds.muPrimeEvalptsH(ds.IdxJmseEst_v3(end))])+.25]); 
        end
        set(gca, 'FontSize', 18);
        % ###
        print(fig, '-dpdf', ['###/momentum_muEst_', control{1}, '_spec', num2str(spec), '.pdf']);
        tempYLim = get(gca,'YLim');
        close all;        
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Estimated mu plot based on 10 quantile portfolios
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        fig = figure;
        plot(1:10, mean(ds.RbarStandard,2), 'k', 'LineWidth', 2)
        %set(gca, 'YLim', tempYLim)
        set(gca, 'YLim', fixedYLim)
        set(gca, 'FontSize', 18);
        % ###
        print(fig, '-dpdf', ['###/momentum_muEstStandard_', control{1}, '_spec', num2str(spec), '.pdf']);
        close all;
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Optimal number of portfolios through time
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        fig = figure;
        plot(ds.dateym, floor(ds.portVec(ds.IdxJmseEst_v3(end))*(ds.ntVec/ds.n).^(1/2)), 'k', 'LineWidth', 2)
        set(gca, 'FontSize', 18);        
        datetick('x', 'yyyy', 'keeplimits')
        % ###
        print(fig, '-dpdf', ['###/momentum_numberOfPortfolios_', control{1}, '_spec', num2str(spec), '.pdf']);
        close all;
        %
        tmp = floor(ds.portVec(ds.IdxJmseEst_v3(end))*(ds.ntVec/ds.n).^(1/2));
        eval(['spec', num2str(spec), '_' control{1}, '_optJ = tmp;']);
        eval(['spec', num2str(spec), '_dates = ds.dateym;']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Number of firms in the cross section over time
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        if (spec == 5)
            fig = figure('Position', [0, 100, 800, 300]);
            set(gca, 'FontSize', 18);
            plot(ds.dateym, ds.ntVec, 'k', 'LineWidth', 2)
            datetick('x', 'yyyy', 'keeplimits')
            set(gcf, 'PaperOrientation', 'landscape');
            set(gcf, 'PaperPositionMode', 'auto')  
            % ###
            print(fig, '-dpdf', ['###/momentum_numberOfFirms_', control{1}, '_spec', num2str(spec), '.pdf']);
            close all;             
        end
        %
        clearvars -except spec dataSource fixedYLim *optJ spec*dates
   end
   fig = figure;
   %set(gca, 'FontSize', 18, 'FontWeight', 'bold');
   tmp0 = eval(['spec', num2str(spec), '_ind0_optJ']);
   tmp37rel = eval(['spec', num2str(spec), '_ind37rel_optJ']);
   tmpDates = eval(['spec', num2str(spec), '_dates']);
   %
   plot(tmpDates, tmp0, '-k', 'LineWidth', 2);
   hold on
   plot(tmpDates, tmp37rel, 'Color', .7*ones(1,3),'LineWidth', 2);
   hold off
   if (spec==11)
       legend({'No Controls', 'Industry Controls'}, 'Location', 'NorthWest');
   end
   datetick('x', 'yyyy', 'keeplimits');
   set(gca, 'FontSize', 18);
   datetick('x', 'yyyy', 'keeplimits'); 
   % ###
   print(fig, '-dpdf', ['###/momentum_numberOfPortfoliosBoth_spec', num2str(spec), '.pdf']);
   close all;
end
toc


