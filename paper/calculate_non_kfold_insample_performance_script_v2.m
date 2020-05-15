% For each methodology/culture, calculate three best models:
% 1: bestmodel_rankcorr: Best model using spearman's rank correlation between signals and forward looking squared return signal
% 2: bestmodel_binary: Best model using RMSE of |ret| * I(rank(|ret|)>.75) - 1/0 signal
% 3: bestmodel_absrmse: Best model using RMSE of |ret| * rank(|ret|) - signal

% Note that model is re-estimated using entire in sample (to do this we
% just select the equivalent model from the finance culture (which was
% estimated using full insample anyway!

rolling_rets = thesemodels(1,1).rolling_rets;
rolling_retsq = thesemodels(1,1).rolling_retsq;
rolling_retrank = NaN(size(rolling_retsq));
rolling_retrank(~master_params.out_of_sample) = tiedrank(rolling_retsq(~master_params.out_of_sample));

model_signal_ranks = [thesemodels.rolling_rank];
% model_onoff_signal = [thesemodels.risk_off];

% Determine optimal optimization-sample model
retsq_rankcorr = corr(rolling_retsq(culture_params.optimization_insample),model_signal_ranks(culture_params.optimization_insample,:),'rows','pairwise','type','spearman')';
% retsq_binary = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*(model_onoff_signal(culture_params.optimization_insample,:)-(rolling_retrank(culture_params.optimization_insample,:)>master_params.trade_prctile/100)).^2));
% absret_rmse = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*(model_signal_ranks(culture_params.optimization_insample,:)-rolling_retrank(culture_params.optimization_insample)).^2))';
absret_rmse = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*model_signal_ranks(culture_params.optimization_insample,:).^2))';

[~, x_bestmodel_rankcorr] = max(retsq_rankcorr);
% [~, x_bestmodel_binary] = min(retsq_binary);
[~, x_bestmodel_absrmse] = min(absret_rmse);

if iCulture ==1
    all_models(iMethodology,iCulture).bestmodel_rankcorr = thesemodels(x_bestmodel_rankcorr);
%     all_models(iMethodology,iCulture).bestmodel_binary = thesemodels(x_bestmodel_binary);
    all_models(iMethodology,iCulture).bestmodel_absrmse = thesemodels(x_bestmodel_absrmse);
else
    all_models(iMethodology,iCulture).bestmodel_rankcorr = all_models(iMethodology,1).models(x_bestmodel_rankcorr);
%     all_models(iMethodology,iCulture).bestmodel_binary = all_models(iMethodology,1).models(x_bestmodel_binary);
    all_models(iMethodology,iCulture).bestmodel_absrmse = all_models(iMethodology,1).models(x_bestmodel_absrmse);
end
