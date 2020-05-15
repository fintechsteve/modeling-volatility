function model_results = trade_garch(Y, X, model_params)
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

% Loop over p, o, q and pick model with best AIC
hasheddata = sprintf('SomeData\\GARCH\\%s.mat',DataHash(X(estimation_insample,:)));
if isfield(model_params,'save_hashed_data')&&model_params.save_hashed_data&&exist(hasheddata,'file')
    loadeddata = load(hasheddata);
    thisPARAMETERS = loadeddata.thisPARAMETERS;
    thisHT = loadeddata.thisHT;
    model_params.mvgarch_p = loadeddata.model_params.mvgarch_p;
    model_params.mvgarch_q = loadeddata.model_params.mvgarch_q;
else
    % Estimate GARCH parameters in sample, then extrapolate out of sample
    try
        [PARAMETERS, LL, HT] = ccc_mvgarch(X(estimation_insample,:),[],p,o,q);
    catch
        XX = X(estimation_insample,:);
        XX(abs(XX)>.05) = sign(XX(abs(XX)>.05))*.05;
        [PARAMETERS, LL, HT] = ccc_mvgarch(XX,[],p,o,q);
    end    
    model_params.insample_AIC = 2*(p+o+q) - 2*LL;
    
    thisPARAMETERS = PARAMETERS;
    thisHT = HT;

    if isfield(model_params,'save_hashed_data')
        save(hasheddata,'thisPARAMETERS','thisHT','model_params');
    end
end

thisHT = cat(3,repmat(thisHT(:,:,1),[1,1,find(estimation_insample,1)-1]), thisHT);

HT = mvgarch_extrapolate(thisPARAMETERS, thisHT, X, model_params);

% Calculate portfolio volatility
estpfvol = shiftdim(sum(sum(wts.*HT,1).*wts',2),2);
    
model_results.rolling_rets = movmean(Y,[0, look_ahead-1]);
model_results.rolling_retsq = movmean(Y.^2,[0, look_ahead-1]);
model_results.smoothed_signal = estpfvol;

trade_cutoff = prctile(estpfvol(estimation_insample), trade_prctile);

% Lag vol signal. Use this to predict day-ahead volatility
model_results.risk_off = [false; estpfvol(1:end-1) > trade_cutoff];

% Calculate rolling rank by comparing value to how many it beats insample
model_results.rolling_rank = [false; mean(estpfvol(1:end-1)> estpfvol(estimation_insample)',2)];

% Save parameters
model_results.model_params = model_params;