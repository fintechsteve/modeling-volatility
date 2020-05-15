function model_results = trade_mahalanobis(Y, X, model_params)
% Calculate the returns from a mahalanobis filter that neutralizes returns
% when turbulence is above trade_pctile (calculated insample, used out of
% sample).
%
% Inputs:
% Y - Tx1 Return Index to be predicted
% X - TxN Component Return matrix
% model_params: Parameter structure with parameters:
%      Hyper paramaters
%         cov_horiz: Lookback window for Covariance and mean estimation
%         ma: Moving average window for turbulence smoothing
%      Estimation framework parameters
%         estimation_insample: Tx1 logical array for estimation window over
%           which cutoffs and rankings are determined for subsequent out of
%           sample decisions
%         trade_prctile: cutoff for risk on/off
%      Experiment framework parameters
%         look_ahead: Number of days to look ahead (m)
%         save_hashed_data: (Optional) logical flag to save intermediate
%            workings for caching purposes.
%
% Outputs:
% rolling_rets: Tx1 array of unfiltered returns, forward smoothed by m days
% rolling_retsq: Tx1 array of squared returns, forward smooothed by m days
% smoothed_signal: 
% risk_off: 
% rolling_rank: 
% model_params: 

trade_prctile = model_params.trade_prctile;
estimation_insample = model_params.estimation_insample;
look_ahead = model_params.look_ahead;

[ti, smoothed_signal] = mahalanobis(X, model_params);

model_results.rolling_rets = movmean(Y,[0, look_ahead-1]);
model_results.rolling_retsq = movmean(Y.^2,[0, look_ahead-1]);
model_results.smoothed_signal = smoothed_signal;

nan_ti = isnan(smoothed_signal);

trade_cutoff = prctile(smoothed_signal(estimation_insample&~nan_ti), trade_prctile);

% Calculate 1/0 signal based on turbulence cutoff. Lag signal by 1 day. Use this to predict next m day vol
model_results.risk_off = [false; smoothed_signal(1:end-1) > trade_cutoff];

% Calculate rolling rank by comparing value to how many it beats insample
model_results.rolling_rank = [false; mean(smoothed_signal(1:end-1)> smoothed_signal(estimation_insample&~nan_ti)',2)];

% Save parameters
model_results.model_params = model_params;