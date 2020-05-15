% For each methodology/culture, calculate three best models:
% 1: bestmodel_rankcorr: Best model using spearman's rank correlation between signals and forward looking squared return signal
% 2: bestmodel_binary: Best model using RMSE of |ret| * I(rank(|ret|)>.5) - 1/0 signal
% 3: bestmodel_absrmse: Best model using RMSE of |ret| * rank(|ret|) - signal

% Note: Because estimation of each fold rotated returns and signals, we have
% to use the corresponding return for each fold. However, rotating returns
% means that we can use the same optimization_sample filter each time.

retsq_rankcorr = [];
retsq_binary = [];
retsq_absretrmse = [];
for iFold = 1:culture_params.nfold
    rolling_rets = thesemodels(1,1,iFold).rolling_rets;
    rolling_retsq = thesemodels(1,1,iFold).rolling_retsq;
    rolling_retrank = NaN(size(rolling_retsq));
    rolling_retrank(~master_params.out_of_sample) = tiedrank(rolling_retsq(~master_params.out_of_sample));
    model_signal_ranks = [thesemodels(:,:,iFold).rolling_rank];
    model_onoff_signal = [thesemodels(:,:,iFold).risk_off];
    
    retsq_rankcorr(:,iFold) = corr(rolling_retsq(culture_params.optimization_insample),model_signal_ranks(culture_params.optimization_insample,:),'rows','pairwise','type','spearman')';
    retsq_binary(:,iFold) = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*(model_onoff_signal(culture_params.optimization_insample,:)-(rolling_retrank(culture_params.optimization_insample)>master_params.trade_prctile/100)).^2));
    retsq_absretrmse(:,iFold) = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*(model_signal_ranks(culture_params.optimization_insample,:)-rolling_retrank(culture_params.optimization_insample)).^2))';
end
retsq_rankcorr = mean(reshape(retsq_rankcorr,size(thesemodels)),3);
retsq_binary = mean(reshape(retsq_binary,size(thesemodels)),3);
retsq_absretrmse = mean(reshape(retsq_absretrmse,size(thesemodels)),3);

[~, x_bestmodel_rankcorr] = max(retsq_rankcorr(:));
[~, x_bestmodel_binary] = min(retsq_binary(:));
[~, x_bestmodel_absrmse] = min(retsq_absretrmse(:));

all_models(iMethodology,iCulture).bestmodel_rankcorr = all_models(iMethodology,1).models(x_bestmodel_rankcorr);
all_models(iMethodology,iCulture).bestmodel_binary = all_models(iMethodology,1).models(x_bestmodel_binary);
all_models(iMethodology,iCulture).bestmodel_absrmse = all_models(iMethodology,1).models(x_bestmodel_absrmse);
