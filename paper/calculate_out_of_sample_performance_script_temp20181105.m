% rolling_retsq_temp = all_models(1,1).bestmodel_rankcorr.rolling_retsq(randperm(size(rolling_retsq,1)));
rolling_retsq_temp = all_models(1,1).bestmodel_rankcorr.rolling_retsq([1:end 1:0]);
% rolling_retsq_temp(rolling_retsq_temp>prctile(rolling_retsq_temp,90)) = prctile(rolling_retsq_temp,90);
rolling_retrank_temp = mean(rolling_retsq_temp> rolling_retsq_temp(~master_params.true_out_of_sample)',2);

% bestmodel_rankcorr = [all_models.bestmodel_rankcorr];
% best_model_signal_ranks = [bestmodel_rankcorr.rolling_rank];
% 
% bestmodel_binary = [all_models.bestmodel_binary];
% best_model_onoff_signal = [bestmodel_binary.risk_off];
% 
% bestmodel_absrmse = [all_models.bestmodel_absrmse];
% % bestcorr_model_onoff_signal = [bestmodel_absrmse.risk_off];
% best_model_signal_rmse = [bestmodel_absrmse.rolling_rank];

retsq_rankcorr_is_temp = reshape(corr(rolling_retsq_temp(~master_params.out_of_sample),best_model_signal_ranks(~master_params.out_of_sample,:),'rows','pairwise','type','spearman'),size(all_models));
retsq_binary_is_temp = reshape(sqrt(mean(rolling_retsq_temp(~master_params.out_of_sample).*(best_model_onoff_signal(~master_params.out_of_sample,:)-(rolling_retrank_temp(~master_params.out_of_sample)>master_params.trade_prctile/100)).^2)),size(all_models));
retsq_absrmse_is_temp = reshape(sqrt(mean(rolling_retsq_temp(~master_params.out_of_sample).*(best_model_signal_rmse(~master_params.out_of_sample,:)-rolling_retrank_temp(~master_params.out_of_sample)).^2)),size(all_models));

retsq_rankcorr_oos_temp = reshape(corr(rolling_retsq_temp(master_params.true_out_of_sample),best_model_signal_ranks(master_params.true_out_of_sample,:),'rows','pairwise','type','spearman'),size(all_models));
retsq_binary_oos_temp = reshape(sqrt(mean(rolling_retsq_temp(master_params.true_out_of_sample).*(best_model_onoff_signal(master_params.true_out_of_sample,:)-(rolling_retrank_temp(master_params.true_out_of_sample,:)>master_params.trade_prctile/100)).^2)),size(all_models));
retsq_absrmse_oos_temp = reshape(sqrt(mean(rolling_retsq_temp(master_params.true_out_of_sample).*(best_model_signal_rmse(master_params.true_out_of_sample,:)-rolling_retrank_temp(master_params.true_out_of_sample)).^2)),size(all_models));

[reshape(permute(cat(3,retsq_rankcorr_is_temp(:,:,1),retsq_rankcorr_oos_temp(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,retsq_binary_is_temp(:,:,1),retsq_binary_oos_temp(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,retsq_absrmse_is_temp(:,:,1),retsq_absrmse_oos_temp(:,:,1)),[3 2 1]),[6,3])]