rolling_rets = all_models(1,1).bestmodel_rankcorr.rolling_rets;
rolling_retsq = all_models(1,1).bestmodel_rankcorr.rolling_retsq;
rolling_retrank = mean(rolling_retsq> rolling_retsq(~master_params.true_out_of_sample)',2);

bestmodel_rankcorr = [all_models.bestmodel_rankcorr];
best_model_signal_ranks = [bestmodel_rankcorr.rolling_rank];

bestmodel_binary = [all_models.bestmodel_binary];
best_model_onoff_signal = [bestmodel_binary.risk_off];

bestmodel_absrmse = [all_models.bestmodel_absrmse];
% bestcorr_model_onoff_signal = [bestmodel_absrmse.risk_off];
best_model_signal_rmse = [bestmodel_absrmse.rolling_rank];

rankrmse_model_signal.is = best_model_signal_rmse(~master_params.out_of_sample,:);
rankcorr_model_signal.is = best_model_signal_ranks(~master_params.out_of_sample,:);
% best_model_onoff_signal.is = best_model_onoff_signal(~master_params.out_of_sample,:);

perf.rankcorr_model.rankcorr_stat.is = reshape(corr(rolling_retsq(~master_params.out_of_sample),rankcorr_model_signal.is,'rows','pairwise','type','spearman'),size(all_models));
% retsq_binary.is = reshape(sqrt(mean(rolling_retsq(~master_params.out_of_sample).*(best_model_onoff_signal.is-(rolling_retrank(~master_params.out_of_sample)>master_params.trade_prctile/100)).^2)),size(all_models));
rolling_signalrmse.is = NaN(size(best_model_signal_rmse(~master_params.out_of_sample,:)));
for i = 1:9
    rolling_signalrmse.is(:,i) = mean(best_model_signal_rmse(~master_params.out_of_sample,i)>best_model_signal_rmse(~master_params.out_of_sample,i)',2);
end
rankrmse_model_wts.is = rankrmse_model_signal.is-rolling_retrank(~master_params.out_of_sample);
% rankrmse_wts.is_rescaled = (rolling_signalrmse.is-rolling_retrank(~master_params.out_of_sample));
% rankrmse_wts.is_rescaled = rankrmse_wts.is_rescaled ./ mean(abs(rankrmse_wts.is_rescaled));
rankrmse_model_wts.is_rescaled = (rolling_signalrmse.is./ mean(abs(rolling_signalrmse.is)))-rolling_retrank(~master_params.out_of_sample);
perf.absrmse_model.absrmse_stat.is = reshape(sqrt(mean(rolling_retsq(~master_params.out_of_sample).*(rankrmse_model_wts.is).^2)),size(all_models));
perf.absrmse_model.absrmse_stat.rescaled.is = reshape(sqrt(mean(rolling_retsq(~master_params.out_of_sample).*(rankrmse_model_wts.is_rescaled).^2)),size(all_models)); %.*(best_model_signal_rmse(~master_params.out_of_sample,:)-rolling_retrank(~master_params.out_of_sample)).^2)),size(all_models));


rankrmse_model_signal.oos = best_model_signal_rmse(master_params.true_out_of_sample,:);
rankcorr_model_signal.oos = best_model_signal_ranks(master_params.true_out_of_sample,:);
% best_model_onoff_signal.oos = best_model_onoff_signal(master_params.true_out_of_sample,:);

perf.rankcorr_model.rankcorr_stat.oos = reshape(corr(rolling_retsq(master_params.true_out_of_sample),rankcorr_model_signal.oos,'rows','pairwise','type','spearman'),size(all_models));
% retsq_binary.oos = reshape(sqrt(mean(rolling_retsq(master_params.true_out_of_sample).*(best_model_onoff_signal.oos-(rolling_retrank(master_params.true_out_of_sample,:)>master_params.trade_prctile/100)).^2)),size(all_models));
rolling_signalrmse.oos = NaN(size(best_model_signal_rmse(master_params.true_out_of_sample,:)));
for i = 1:9
    rolling_signalrmse.oos(:,i) = mean(best_model_signal_rmse(master_params.true_out_of_sample,i)>best_model_signal_rmse(master_params.true_out_of_sample,i)',2);
end
rankrmse_model_wts.oos = rankrmse_model_signal.oos-rolling_retrank(master_params.true_out_of_sample);
% rankrmse_wts.oos_rescaled = (rolling_signalrmse.oos-rolling_retrank(master_params.true_out_of_sample)).^2;
% rankrmse_wts.oos_rescaled = rankrmse_wts.oos_rescaled ./ mean(abs(rankrmse_wts.oos_rescaled));
rankrmse_model_wts.oos_rescaled = (rolling_signalrmse.oos./ mean(abs(rolling_signalrmse.oos)))-rolling_retrank(master_params.true_out_of_sample);
perf.absrmse_model.absrmse_stat.oos = reshape(sqrt(mean(rolling_retsq(master_params.true_out_of_sample).*(rankrmse_model_wts.oos).^2)),size(all_models));
perf.absrmse_model.absrmse_stat.rescaled.oos = reshape(sqrt(mean(rolling_retsq(master_params.true_out_of_sample).*(rankrmse_model_wts.oos_rescaled).^2)),size(all_models)); %.*(best_model_signal_rmse(master_params.true_out_of_sample,:)-rolling_retrank(master_params.true_out_of_sample)).^2)),size(all_models));

for iMC = 1:1000
    randwtperm.is = randperm(sum(~master_params.out_of_sample));
    randwtperm.oos = randperm(sum(master_params.true_out_of_sample));
    
    rankrmse_model_signal.bootstrap.is = rankrmse_model_signal.is(randwtperm.is,:);
    rankcorr_model_signal.bootstrap.is = rankcorr_model_signal.is(randwtperm.is,:);
    rankrmse_model_wts.bootstrap.is = rankrmse_model_wts.is(randwtperm.is,:);
    rankrmse_model_wts.bootstrap.is_rescaled = rankrmse_model_wts.is_rescaled(randwtperm.is,:);
    
    rankrmse_model_signal.bootstrap.oos = rankrmse_model_signal.oos(randwtperm.oos,:);
    rankcorr_model_signal.bootstrap.oos = rankcorr_model_signal.oos(randwtperm.oos,:);
    rankrmse_model_wts.bootstrap.oos = rankrmse_model_wts.oos(randwtperm.oos,:);
    rankrmse_model_wts.rescaled.bootstrap.oos = rankrmse_model_wts.oos_rescaled(randwtperm.oos,:);
    
    perf.rankcorr_model.rankcorr_stat.bootstrap.is(:,:,iMC) = reshape(corr(rolling_retsq(~master_params.out_of_sample),rankcorr_model_signal.bootstrap.is,'rows','pairwise','type','spearman'),size(all_models));
    perf.absrmse_model.absrmse_stat.bootstrap.is(:,:,iMC) = reshape(sqrt(mean(rolling_retsq(~master_params.out_of_sample).*(rankrmse_model_wts.bootstrap.is).^2)),size(all_models));
    perf.absrmse_model.absrmse_stat.rescaled.bootstrap.is(:,:,iMC) = reshape(sqrt(mean(rolling_retsq(~master_params.out_of_sample).*(rankrmse_model_wts.bootstrap.is_rescaled).^2)),size(all_models));
    
    perf.rankcorr_model.rankcorr_stat.bootstrap.oos(:,:,iMC) = reshape(corr(rolling_retsq(master_params.true_out_of_sample),rankcorr_model_signal.bootstrap.oos,'rows','pairwise','type','spearman'),size(all_models));
    perf.absrmse_model.absrmse_stat.bootstrap.oos(:,:,iMC) = reshape(sqrt(mean(rolling_retsq(master_params.true_out_of_sample).*(rankrmse_model_wts.bootstrap.oos).^2)),size(all_models));
    perf.absrmse_model.absrmse_stat.rescaled.bootstrap.oos(:,:,iMC) = reshape(sqrt(mean(rolling_retsq(master_params.true_out_of_sample).*(rankrmse_model_wts.rescaled.bootstrap.oos).^2)),size(all_models));
end