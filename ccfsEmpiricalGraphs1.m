% Size Effect
clear all;

tic
for spec=1:2:5
    disp(spec)
   for dataSource={'CRSP', 'NYSE'}
       disp(dataSource)
       fixedXLim = [-6 6];
       if strcmp(dataSource, 'CRSP'), fixedYLim = [0, 0.07]; end
       if strcmp(dataSource, 'NYSE'), fixedYLim = [-.01, 0.03]; end
       % Get the correct files to pull the estimation results
       % Using norminv(.025) and norminv(1-.025) evaluation points
       % ###
        currentDir = dir('###/*.mat');
        f1 = regexpi({currentDir.name}, dataSource, 'match');
        f2 = regexpi({currentDir.name}, ['spec', num2str(spec), '_'], 'match');
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
        set(gca, 'YLim', fixedYLim, 'XLim', fixedXLim);
        % 
        hold on
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
        %set(gca, 'FontSize', 18, 'FontWeight', 'bold');
        set(gca, 'FontSize', 18);
        %set(gca,'LineWidth',2)
        % ###
        print(fig, '-dpdf', ['###/size_muEst_', dataSource{1}, '_spec', num2str(spec), '.pdf']);
        %tempYLim = get(gca,'YLim');
        close all;
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Estimated mu plot based on 10 quantile portfolios
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fig = figure;
        plot(1:10, mean(ds.RbarStandard,2), 'k', 'LineWidth', 2)
        %set(gca, 'YLim', tempYLim)
        set(gca, 'YLim', fixedYLim);
        %set(gca, 'FontSize', 18, 'FontWeight', 'bold');
        set(gca, 'FontSize', 18);
        % ###
        print(fig, '-dpdf', ['###/size_muEstStandard_', dataSource{1}, '_spec', num2str(spec), '.pdf']);
        close all;
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Optimal number of portfolios through time
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fig = figure;
        %set(gca, 'FontSize', 18, 'FontWeight', 'bold');        
        plot(ds.dateym, floor(ds.portVec(ds.IdxJmseEst_v3(end))*(ds.ntVec/ds.n).^(1/2)), 'k', 'LineWidth', 2);
        set(gca, 'FontSize', 18);
        datetick('x', 'yyyy', 'keeplimits')     
        % ###
        print(fig, '-dpdf', ['###/size_numberOfPortfolios_', dataSource{1}, '_spec', num2str(spec), '.pdf']);
        close all;
        tmp = floor(ds.portVec(ds.IdxJmseEst_v3(end))*(ds.ntVec/ds.n).^(1/2));
        eval(['spec', num2str(spec), '_' dataSource{1}, '_optJ = tmp;'])
        eval(['spec', num2str(spec), '_dates = ds.dateym;'])        
        %
        if (spec == 5)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Number of firms in the cross section over time
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
            %fig = figure('Position', [0, 100, 800, 300]);
            fig = figure;
            plot(ds.dateym, ds.ntVec, 'k',  'LineWidth', 1.5);
            datetick('x', 'yyyy', 'keeplimits')
            pbaspect([2.5 1 1]);
            %set(gca, 'FontSize', 14, 'FontWeight', 'bold');            
            set(gca, 'FontSize', 12);
            set(gcf, 'PaperOrientation', 'landscape');
            set(gcf, 'PaperPositionMode', 'auto')
            % ###
            print(fig, '-dpdf', ['###/size_numberOfFirms_', dataSource{1}, '_spec', num2str(spec), '.pdf']);
            close all;             
        end
        %
        clearvars -except spec dataSource *optJ spec*dates     
   end
   fig = figure;
   %set(gca, 'FontSize', 18, 'FontWeight', 'bold');
   tmpCRSP = eval(['spec', num2str(spec), '_CRSP_optJ']);
   tmpNYSE = eval(['spec', num2str(spec), '_NYSE_optJ']);
   tmpDates = eval(['spec', num2str(spec), '_dates']);
   %
   plot(tmpDates, tmpCRSP, '-k', 'LineWidth', 2);
   hold on
   plot(tmpDates, tmpNYSE, 'Color', .7*ones(1,3),'LineWidth', 2);
   hold off
   if (spec == 5)
       legend({'All Stocks', 'NYSE Only'}, 'Location', 'NorthWest');
   end
   datetick('x', 'yyyy', 'keeplimits');
   set(gca, 'FontSize', 18);
   datetick('x', 'yyyy', 'keeplimits');       
   % ###
   print(fig, '-dpdf', ['###/size_numberOfPortfoliosBoth_spec', num2str(spec), '.pdf']);
   close all;
end
toc


