function chosen_model = nfold_crossvalidation_with_holdback(Y, X, model_params, model_fun)
% Split sample into model_params.nfold samples with non-overlapping
% out-of-sample periods for in-model cross validation. Run backtest for all
% possible model parameters (specified in fields
% model_params.search_chosens.*). Compare average performance of n models
% and pick parameters that result in the best cross-validated performance.
% Finally, do a holdback test and check for
% overfitting using a 2-sided F-test... if so, ditch filter entirely and
% use unfiltered model.

% Note on preventing target leakage in timeseries estimation.
% 
% Our primary concern is that X variables, consisting of combinations of a
% certain window of past observations may contain information about the
% period of out-of-sample data. To avoid this, we add the actual max
% X-variable smoothing window to a conservative estimate of y variable
% persistence and refrain from using any of the observations immediately
% following the out of sample observation for this window.
%
% Example of how sample is split for T = 1100, nfold = 5 and
% T_oos = 200, T_discard = 100:
%
% Observation 0....100...200...300...400...500...600...700...800...900...1000..1100
%             |     |     |     |     |     |     |     |     |     |     |     |
% Run 1        XXXXXXIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIOOOOOOOOOOOO
% Run 2        IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIOOOOOOOOOOOOXXXXXXIIIIII
% Run 3        IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIOOOOOOOOOOOOXXXXXXIIIIIIIIIIIIIIIIII
% Run 4        IIIIIIIIIIIIIIIIIIOOOOOOOOOOOOXXXXXXIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
% Run 5        IIIIIIOOOOOOOOOOOOXXXXXXIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
%
% I = estimation insample, O = out of sample (optimization_insample), X = tainted data (discard)
%
% Ideally, T_cross_sample > T_oos * nfold

[T, N] = size(X);

nfold = model_params.nfold;

if ~isfield(model_params,'holdback_vartest_alpha')
    model_params.holdback_vartest_alpha = 0.05;
end

% Create baseline sample masks
estimation_insample = model_params.estimation_insample;
optimization_insample = model_params.optimization_insample;
holdback_sample = model_params.holdback_sample;
out_of_sample = model_params.out_of_sample;

nfold_sample = ~(holdback_sample|out_of_sample);
nfold_subsample = estimation_insample(nfold_sample) - optimization_insample(nfold_sample);
est_subsample = estimation_insample(nfold_sample);
opt_subsample = optimization_insample(nfold_sample);
T_nfold = numel(nfold_subsample);
T_cross_sample = sum(nfold_sample);
T_shift = ceil(T_cross_sample / nfold);

chosen_model.params = model_params;

if(sum(diff(nfold_subsample)) ~= -1 && sum(abs(diff(nfold_subsample))) ~= 3)
    error('Sample masks not arranged properly. Should be Estimation|Discard|Optimization|Holdback|Out');
end

chosen_model.Yhat = NaN(T_nfold, nfold);
chosen_model.risk_off = NaN(T_nfold, nfold);
chosen_model.Yoff = NaN(T_nfold,nfold);
model_params.estimation_insample = est_subsample;

for ifold = 1:nfold
    
    % Reorganize the sample for cross-validation.
    Yshift = circshift(Y(nfold_sample),(ifold-1)*T_shift);
    Xshift = circshift(X(nfold_sample,:),(ifold-1)*T_shift);
    
    [chosen_model.Yhat(:,ifold), chosen_model.risk_off(:,ifold)] = model_fun(Yshift, Xshift, model_params);
    chosen_model.Yoff(:,ifold) = Yshift.*chosen_model.risk_off(:,ifold);
end

if any(chosen_model.risk_off(opt_subsample,:)>0)
    chosen_model.vol = nanstd(chosen_model.Yoff(chosen_model.risk_off&opt_subsample));
else
    chosen_model.vol = -Inf;
end
