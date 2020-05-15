xSamples = {'is','oos'};
xModels = {'rankcorr_model','absrmse_model'};
sampleFilters = [~master_params.out_of_sample master_params.true_out_of_sample];

rolling_rets = all_models(1,1).bestmodel_rankcorr.rolling_rets;
rolling_retsq = all_models(1,1).bestmodel_rankcorr.rolling_retsq;
rolling_retrank = mean(rolling_retsq> rolling_retsq(~master_params.true_out_of_sample)',2);

bestmodel_all.rankcorr_model = [all_models.bestmodel_rankcorr];
bestmodel_all.absrmse_model = [all_models.bestmodel_absrmse];

for iModel = 1:2
    xModel = xModels{iModel};
    
    bestmodel.(xModel).signal.all = [bestmodel_all.(xModel).rolling_rank];

    for iSample = 1:2
        xSample = xSamples{iSample};
        sampleFilter = sampleFilters(:,iSample);

        % Limit signal to sample
        bestmodel.(xModel).signal.(xSample) = bestmodel.(xModel).signal.all(sampleFilter,:);
        
        % Rank correlation statistic
        perf.(xModel).rankcorr_stat.(xSample) = reshape(corr(rolling_retsq(sampleFilter),bestmodel.(xModel).signal.(xSample),'rows','pairwise','type','spearman'),size(all_models));

        % RMSE and Rescaled RMSE statistic
        bestmodel.(xModel).rolling_signal.(xSample) = NaN(size(bestmodel.(xModel).signal.(xSample)));
        for i = 1:9
            bestmodel.(xModel).rolling_signal.(xSample)(:,i) = mean(bestmodel.(xModel).signal.(xSample)(:,i)>bestmodel.(xModel).signal.(xSample)(:,i)',2);
        end
        
        bestmodel.(xModel).absrmse_stat.wts.(xSample) = bestmodel.(xModel).signal.(xSample)-rolling_retrank(sampleFilter);
        bestmodel.(xModel).absrmse_stat.wts.rescaled.(xSample) = (bestmodel.(xModel).rolling_signal.(xSample)./ mean(abs(bestmodel.(xModel).rolling_signal.(xSample))))-rolling_retrank(sampleFilter);
        perf.(xModel).absrmse_stat.(xSample) = reshape(sqrt(mean(rolling_retsq(sampleFilter).*(bestmodel.(xModel).absrmse_stat.wts.(xSample)).^2)),size(all_models));
        perf.(xModel).absrmse_stat_rescaled.(xSample) = reshape(sqrt(mean(rolling_retsq(sampleFilter).*(bestmodel.(xModel).absrmse_stat.wts.rescaled.(xSample)).^2)),size(all_models));

        for iMC = 1:1000
            randwtperm.(xSample) = randperm(sum(sampleFilter));
            
            bestmodel.(xModel).signal.bootstrap.(xSample) = bestmodel.(xModel).signal.(xSample)(randwtperm.(xSample),:);
            bestmodel.(xModel).absrmse_stat.wts.bootstrap.(xSample) = bestmodel.(xModel).absrmse_stat.wts.(xSample)(randwtperm.(xSample),:);
            bestmodel.(xModel).absrmse_stat.wts.rescaled.bootstrap.(xSample) = bestmodel.(xModel).absrmse_stat.wts.rescaled.(xSample)(randwtperm.(xSample),:);
                
            perf.(xModel).rankcorr_stat.bootstrap.(xSample)(:,:,iMC) = reshape(corr(rolling_retsq(sampleFilter),bestmodel.(xModel).signal.bootstrap.(xSample),'rows','pairwise','type','spearman'),size(all_models));
            perf.(xModel).absrmse_stat.bootstrap.(xSample)(:,:,iMC) = reshape(sqrt(mean(rolling_retsq(sampleFilter).*(bestmodel.(xModel).absrmse_stat.wts.bootstrap.(xSample)).^2)),size(all_models));
            perf.(xModel).absrmse_stat_rescaled.bootstrap.(xSample)(:,:,iMC) = reshape(sqrt(mean(rolling_retsq(sampleFilter).*(bestmodel.(xModel).absrmse_stat.wts.rescaled.bootstrap.(xSample)).^2)),size(all_models));
            
        end
    end
end