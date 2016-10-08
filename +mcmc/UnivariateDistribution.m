classdef UnivariateDistribution < handle

	properties
		mean, median, mode
	end

	properties (Access = private)
		samples
		priorSamples, priorCol
		XRANGE
		xi
		density
		shouldPlot
		killYAxis
		patchProperties
		
		xLabel,
		
		pointEstimateType
		shouldPlotPointEstimate
		col
		HDI
		plotHDI
		plotStyle
		N
		FaceAlpha
		axisSquare
	end

	properties (GetAccess = public, SetAccess = protected)

	end

	methods (Access = public)

		function obj = UnivariateDistribution(posteriorSamples, varargin)
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('samples',@ismatrix);
			p.addParameter('priorSamples',[],@isvector);
			p.addParameter('xLabel','',@isstr);
			p.addParameter('plotStyle','kde',@(x)any(strcmp(x,{'hist','kde'})))
			p.addParameter('shouldPlot',true,@islogical);
			p.addParameter('killYAxis',true,@islogical);
			p.addParameter('priorCol',[0.8 0.8 0.8],@isvector);
			p.addParameter('col',[0.6 0.6 0.6],@isvector);
			p.addParameter('pointEstimateType','mode', @(x)any(strcmp(x,{'mean','median','mode'})));
			p.addParameter('shouldPlotPointEstimate',false,@islogical);
			p.addParameter('FaceAlpha',0.2,@isscalar);
			p.addParameter('patchProperties',{'FaceAlpha',0.8},@iscell);
			p.addParameter('plotHDI',true,@islogical);
			p.addParameter('axisSquare',false,@islogical);
			p.parse(posteriorSamples, varargin{:});
			% add p.Results fields into obj
			fields = fieldnames(p.Results);
			for n=1:numel(fields)
				obj.(fields{n}) = p.Results.(fields{n});
			end

			obj.N = size(obj.samples,2);
			% obj.XRANGE = [min(posteriorSamples) max(posteriorSamples)];
			% obj.YRANGE = [min(priorSamples) max(priorSamples)];

			if isempty(posteriorSamples) || any(isnan(posteriorSamples(:)))
				warning('invalid samples passed into function')
				return
			end
			% Calculate stats upon construction
			obj.mean = mean(obj.samples);
			obj.median = median(obj.samples);
			obj.calculateDensityAndPointEstimates();
			obj.HDI = mcmc.HDIofSamples(obj.samples, 0.95);
			if p.Results.shouldPlot
				obj.plot();
			end

		end
		
		function [pointEstimate] = getPointEstimate(obj)
			pointEstimate = obj.(obj.pointEstimateType);
		end

		function plot(obj)
			switch obj.plotStyle
					case{'hist'}
						obj.plotHist();
					case{'kde'}
						obj.plotDensity();
			end
			obj.formatAxes();
			obj.plotPointEstimate();
			obj.panOptions();
		end

	end
	
	methods (Access = private)
		
		function panOptions(obj)
			ax = gca;
			h = pan;
			setAxesPanMotion(h,ax,'horizontal');
		end
		
		function calculateDensityAndPointEstimates(obj)
			obj.xi = linspace( min(obj.samples(:)), max(obj.samples(:)), 1000);
			obj.xi = [obj.xi(1) obj.xi obj.xi(end)]; % fix to avoid plotting artifacts
			for n=1:obj.N
				[obj.density(:,n), ~] = ksdensity(obj.samples(:,n), obj.xi);
				[~,ind] = max(obj.density(:,n));
				obj.mode(n) = obj.xi( ind );

				obj.density([1,end],n)=0; % fix to avoid plotting artifacts
			end
		end


		function plotHist(obj)
			hold on
			for n=1:obj.N
                try
    				hPost(n)=histogram(obj.samples(:,n),...
    					'Normalization','pdf',...
    					'EdgeColor','none',...
    					'FaceColor',obj.col,...
    					'FaceAlpha',obj.FaceAlpha);
                catch
                    % backward compatability
                    [N,X] = hist(obj.samples(:,n));
                    N = N./sum(N);
                    h = stairs(X,N,'k-');
                end
			end
			axis tight
		end


		function plotDensity(obj)
			hold on
			for n=1:obj.N
				h(n)= fill(obj.xi,...
					obj.density(:,n),...
					obj.col,...
					'EdgeColor','none',...
					'FaceAlpha',obj.FaceAlpha);
				% apply plot options to patch
				set(h(n), obj.patchProperties{:});
			end

		end


		function plotPointEstimate(obj)
			if ~obj.shouldPlotPointEstimate, return, end
			a = axis;
			for n=1:obj.N
				h = line( [obj.(obj.pointEstimateType)(n) obj.(obj.pointEstimateType)(n)],...
					[a(3) a(4)]);
				h.Color = 'k';
			end
		end


		function formatAxes(obj)

			if obj.killYAxis
				mcmc.removeYaxis()
			end

			if obj.plotHDI
				for n=1:obj.N
					mcmc.showHDI(obj.samples(:,n))
				end
			end

			box off
			axis tight
			if obj.axisSquare, axis square, end
			set(gca,'TickDir','out')
			set(gca,'Layer','top');
			xlabel(obj.xLabel, 'interpreter', 'latex')
		end

	end

end
