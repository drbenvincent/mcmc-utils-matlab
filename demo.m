% demo

try
	pathOfPackage = '~/git-local/mcmc-utils-matlab';
	addpath(pathOfPackage)
catch
	error('Set ''pathToPackage'' to parent of the +mcmc package')
end

mcmc.setPlotTheme('fontsize',16, 'linewidth',2)



%% generate faux mcmc data
mu = [1 -1]; Sigma = [.9 .4; .4 .3];
samples = mvnrnd(mu, Sigma, 10^5);
%plot(samples(:,1),samples(:,2),'.');
variableNames={'retroflux units, $\rho$','awesomeness, $\alpha$'};



%% univariate distribution
figure(1), clf
subplot(1,2,1)
uni = mcmc.UnivariateDistribution(samples(:,1),...
	'xLabel', variableNames{1});
title('plotstyle=''density''')

subplot(1,2,2)
uni2 = mcmc.UnivariateDistribution(samples(:,2),...
	'xLabel', variableNames{2},...
	'plotStyle','hist');
title('plotstyle=''hist''')



%% bivariate distribution
figure(2), clf
subplot(1,3,1)
bi1 = mcmc.BivariateDistribution(samples(:,1),samples(:,2),...
	'xLabel',variableNames{1},...
	'yLabel',variableNames{2});
title('plotstyle=''density''')

subplot(1,3,2)
bi2 = mcmc.BivariateDistribution(samples(:,1),samples(:,2),...
	'xLabel',variableNames{1},...
	'yLabel',variableNames{2},...
	'plotStyle','hist');
title('plotstyle=''hist''')
tempAxisLims = axis;

subplot(1,3,3)
bi3 = mcmc.BivariateDistribution(samples(:,1),samples(:,2),...
	'xLabel',variableNames{1},...
	'yLabel',variableNames{2},...
	'plotStyle','contour',...
	'probMass',0.5);
title('plotstyle=''contour''')
axis(tempAxisLims)

%% Triplot / Corner plot
% For 2 parameters or more, a corner plot is useful to look at all the
% univariate and all combinations of bivariate marginal distributions.
figure(3), clf
tri = mcmc.TriPlotSamples(samples,...
	variableNames,...
	'figSize', 15);






%% CODE BELOW IS UNDER DEVELOPMENT ========================================


% %% mcmc container (a subpackage)
% % We will have a variety of mcmc containers which will provide helpful
% % functions.
% import('mcmc.container.*')
%
% % JAGS
% jagsMcmcObject = JAGSmcmc(samples, stats, mcmcparams);
%
% % just a set of samples
% simpleMcmcObject = SimpleMcmc(samples);
