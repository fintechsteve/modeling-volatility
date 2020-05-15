function [ti, smoothed_ti] = mahalanobis(returns, model_params)
% Calculate mahalanobis distance on returns for a given estimation horizon
% and moving average
%
% Version history
% 1.0       9/30/2017       Initial version
% 1.1       1/20/2018       Corrected windowing error, replicated TI

[nRows, nCols] = size(returns);
cov_horiz = model_params.cov_horiz;
ma = model_params.ma;

% okRows = ~any(isnan(returns),2);
% returns = [NaN(1,nCols); diff(log(Xnew))];

if any(isinf(returns(:)))
    error('Infinite returns');
end

hasheddata = sprintf('SomeData\\Mahalanobis\\%d\\%s_%d.mat',model_params.cov_horiz,DataHash(returns),model_params.cov_horiz);
if isfield(model_params,'save_hashed_data')&&model_params.save_hashed_data&&exist(hasheddata,'file')
    loadeddata = load(hasheddata);
    ti = loadeddata.ti;
else

    ti = NaN(nRows,1);
    
    for iWindow = cov_horiz:nRows
        covreturns = returns(iWindow-cov_horiz+(1:cov_horiz),:);
        
        covmat = cov(covreturns);
        RetMinusMu = covreturns(end,:) - mean(covreturns,1);
        
        ti(iWindow) = (RetMinusMu * (covmat \ RetMinusMu'))/nCols;
    end
    
    if isfield(model_params,'save_hashed_data')
        save(hasheddata,'ti');
    end
end
smoothed_ti = movmean(ti,[ma-1,0]);