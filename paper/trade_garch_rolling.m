function model_results = trade_garch_rolling(Y, X, model_params)
% Calculate the returns from a garch filter that neutralizes returns
% when predicted portfolio volatility is above limit. Returns are rescaled 
% to neutralize unconditional volatility impact of returns zeroed out by filter

trade_prctile = model_params.trade_prctile;
estimation_insample = model_params.estimation_insample;
% ma = model_params.ma;
look_ahead = model_params.look_ahead;

p = model_params.mvgarch_p;
o = model_params.mvgarch_o;
q = model_params.mvgarch_q;
wts = model_params.wts(:);
garch_lookback = model_params.garch_lookback;

% Rolling window for GARCH
[T,N] = size(X);

AIC = NaN(T);
HT = NaN(N,N,T+1);

for t = garch_lookback:T
    % Estimate GARCH parameters in sample, then extrapolate out of sample
    
    est_window = (t-garch_lookback)+(1:garch_lookback);
    [PARAMETERS, LL, thisHT] = ccc_mvgarch(X(est_window,:),[],p,o,q);

    thisHT = mvgarch_extrapolate(PARAMETERS, thisHT, [X(est_window,:); repmat(std(X(est_window,:)),[look_ahead,1])], model_params);
    
    if t == garch_lookback
        HT(:,:,1:garch_lookback+1) = thisHT;
    else
        HT(:,:,t+1) = thisHT(:,:,end);
    end
    AIC(t) = 2*(p+o+q) - 2*LL;
    
end
    
model_params.AIC = AIC;

% Calculate portfolio volatility
estpfvol = shiftdim(sum(sum(wts.*HT,1).*wts',2),2);
    
model_results.rolling_rets = movmean(Y,[0, look_ahead]);
model_results.rolling_retsq = movmean(Y.^2,[0, look_ahead]);
model_results.smoothed_signal = estpfvol;

trade_cutoff = prctile(estpfvol(estimation_insample), trade_prctile);

% Lag vol signal. Use this to predict day-ahead volatility
model_results.risk_off = [false; estpfvol(1:end-1) > trade_cutoff];

% Calculate rolling rank by comparing value to how many it beats insample
model_results.rolling_rank = [false; mean(estpfvol(1:end-1)> estpfvol(estimation_insample)',2)];

% Save parameters
model_results.model_params = model_params;