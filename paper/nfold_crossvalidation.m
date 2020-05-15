function all_models = nfold_crossvalidation(Y, X, model_params, model_fun)
% Split sample into model_params.nfold samples with non-overlapping
% out-of-sample periods for in-model cross validation. Run backtest for all
% possible model parameters (specified in fields
% model_params.search_chosens.*). Compare average performance of n models
% and pick parameters that result in the best cross-validated performance.

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

nfold = model_params.nfold;

% Create baseline sample masks
estimation_insample = model_params.estimation_insample;
optimization_insample = model_params.optimization_insample;
out_of_sample = model_params.out_of_sample;

nfold_sample = ~out_of_sample;
nfold_subsample = estimation_insample(nfold_sample) - optimization_insample(nfold_sample);
est_subsample = estimation_insample(nfold_sample);
opt_subsample = optimization_insample(nfold_sample);
T_nfold = numel(nfold_subsample);
T_cross_sample = sum(nfold_sample);
T_shift = ceil(T_cross_sample / nfold);

if(sum(diff(nfold_subsample)) ~= -2 && sum(abs(diff(nfold_subsample))) ~= 2)
    error('Sample masks not arranged properly. Should be Estimation|Discard|Optimization|Holdback|Out');
end

model_params.estimation_insample = est_subsample;
model_params.optimization_insample = opt_subsample;

all_models = [];
for ifold = 1:nfold
    
    % Reorganize the sample for cross-validation.
    Yshift = circshift(Y(nfold_sample),(ifold-1)*T_shift);
    Xshift = circshift(X(nfold_sample,:),(ifold-1)*T_shift);
    
    choice_model = model_fun(Yshift, Xshift, model_params);
    all_models = [all_models; choice_model];
end
