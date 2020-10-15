clear all; close all; clc;
% Set seed
rng(41, 'twister');
% Define colors
ColorDarkGray = .25*[1,1,1];
ColorGray = .75*[1,1,1];
DraftsDir = [pwd, filesep, 'Charts', filesep];
% Define test function
mu0 = @(x) .45*(2.25+(x-1/2) + 8*(x-1/2).^2 + 6*(x-1/2).^3 - 30*(x-1/2).^4);
% Generate Data
n = 500;
G = 5000;
sigmae = 2;
gridpts = linspace(0,1,G);
bin_min = 4;
bin_max = 10;
linspace_bin_min = linspace(0,1,bin_min+1);
linspace_bin_min(1) = [];
linspace_bin_min(end) = [];
linspace_bin_max = linspace(0,1,bin_max+1);
linspace_bin_max(1) = [];
linspace_bin_max(end) = [];

% Figures 
T = 50;
nT = 1000;
y_gridpts_min_T = NaN(numel(gridpts),T);
y_gridpts_max_T = NaN(numel(gridpts),T);
y_conv_min_T = NaN(bin_min,T);
y_conv_max_T = NaN(bin_max,T);

betparvec = kron(ones(1,T/2),[1,1.2]);

for t = 1:T
    x = betarnd(betparvec(t),betparvec(t),[nT,1]);
    y = mu0(x) + sigmae*randn(nT,1);
    if (t==1), xKeep=x; yKeep=y; end
    [y_conv_min_temp, ~, ~, ~, ~, ~, ~, ~, ~, y_gridpts_min_temp, ~, ~, ~] ...
                            = ccfsEst(y,x,[],ones(size(y)),[],bin_min,gridpts,'quantiles',[],[],[]);
    
    y_gridpts_min_T(:,t) = y_gridpts_min_temp;    
    y_conv_min_T(:,t) = y_conv_min_temp;
    [y_conv_max_temp, ~, ~, ~, ~, ~, ~, ~, ~, y_gridpts_max_temp, ~, ~, ~] ...
                            = ccfsEst(y,x,[],ones(size(y)),[],bin_max,gridpts,'quantiles',[],[],[]);
    y_gridpts_max_T(:,t) = y_gridpts_max_temp;        
    y_conv_max_T(:,t) = y_conv_max_temp;
end


ylimKeep = [.4,2];
% Figure B
FigName = figure;
fplot(mu0,[0,1], 'k', 'LineStyle', '--');
hold on
plot(gridpts, y_gridpts_min_T(:,1), 'Color', ColorGray, 'LineWidth', 2);
hold on
plot(gridpts, y_gridpts_min_T(:,2), 'Color', ColorGray, 'LineWidth', 2);
hold on
plot(gridpts, mean(y_gridpts_min_T(:,1:2),2), 'Color', ColorDarkGray', 'LineWidth', 2);
hold off
ylim(ylimKeep);
set(gca, 'FontSize', 18);
print(FigName, '-dpdf', [DraftsDir, 'FigB.pdf'])

% Figure A
FigName = figure;
fplot(mu0,[0,1], 'k', 'LineStyle', '--');
hold on
plot(xKeep, yKeep, '.', 'MarkerFaceColor', ColorGray, 'MarkerEdgeColor', ColorGray, 'MarkerSize', 4);
hold on
plot(gridpts, mean(y_gridpts_min_T(:,1),2), 'Color', ColorDarkGray, 'LineWidth', 2);
hold off
ylim(ylimKeep);
set(gca, 'FontSize', 18);
print(FigName, '-dpdf', [DraftsDir, 'FigA.pdf'])

% Figure C
FigName = figure;
fplot(mu0,[0,1], 'k', 'LineStyle', '--');
hold on
plot(gridpts, mean(y_gridpts_min_T,2), 'Color', ColorDarkGray, 'LineWidth', 2);
hold off
ylim(ylimKeep);
set(gca, 'FontSize', 18);
print(FigName, '-dpdf', [DraftsDir, 'FigC.pdf'])

% Figure D
FigName = figure;
fplot(mu0,[0,1], 'k', 'LineStyle', '--');
hold on
plot(xKeep, yKeep, '.', 'MarkerFaceColor', ColorGray, 'MarkerEdgeColor', ColorGray, 'MarkerSize', 4);
hold on
plot(gridpts, mean(y_gridpts_max_T(:,1),2), 'Color', ColorDarkGray, 'LineWidth', 2);
hold off
ylim(ylimKeep);
set(gca, 'FontSize', 18);
print(FigName, '-dpdf', [DraftsDir, 'FigD.pdf'])

% Figure E
FigName = figure;
fplot(mu0,[0,1], 'k', 'LineStyle', '--');
hold on
plot(gridpts, y_gridpts_max_T(:,1), 'Color', ColorGray, 'LineWidth', 2);
hold on
plot(gridpts, y_gridpts_max_T(:,2), 'Color', ColorGray, 'LineWidth', 2);
hold on
plot(gridpts, mean(y_gridpts_max_T(:,1:2),2), 'Color', ColorDarkGray, 'LineWidth', 2);
hold off
ylim(ylimKeep);
set(gca, 'FontSize', 18);
print(FigName, '-dpdf', [DraftsDir, 'FigE.pdf'])

% Figure F
FigName = figure;
fplot(mu0,[0,1], 'k', 'LineStyle', '--');
hold on
plot(gridpts, mean(y_gridpts_max_T,2), 'Color', ColorDarkGray, 'LineWidth', 2);
hold off
ylim(ylimKeep);
set(gca, 'FontSize', 18);
print(FigName, '-dpdf', [DraftsDir, 'FigF.pdf'])

close all;

