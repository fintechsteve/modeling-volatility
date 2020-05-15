clear
% load kfold_1day_Developed_Markets_Currency_Returns_(Scrambled)_workspace_2019-01-06.mat
% load kfold_1day_Developed_Markets_Currency_Returns_workspace_2018-11-06.mat
load kfold_1day_US_Equity_Sector_Returns_(Scrambled)_workspace_2019-01-05.mat
% load kfold_1day_US_Equity_Sector_Returns_workspace_2018-11-08.mat
% load kfold_20day_Developed_Markets_Currency_Returns_workspace_2018-12-17.mat
% load kfold_20day_US_Equity_Sector_Returns_workspace_2018-11-23.mat
% load kfold_1day_Developed_Markets_Currency_Returns_(Detrended)_workspace_2018-12-13.mat

xSamples = {'is','oos'};
xModels = {'rankcorr_model','absrmse_model'};
xStats = {'rankcorr_stat','absrmse_stat','absrmse_stat_rescaled'};
xStatParts = {'value','significance'};
sampleFilters = [~master_params.out_of_sample master_params.true_out_of_sample];

for iMasterKfolds = 1:master_params.master_kfolds
    all_models = kfolds_models(iMasterKfolds).results;
    fprintf('fold %d\n', iMasterKfolds);
    calculate_out_of_sample_performance_script_v2;

    for iModel = 1:2
        xModel = xModels{iModel};

        for iSample = 1:2
            xSample = xSamples{iSample};
            sampleFilter = sampleFilters(:,iSample);
            
            % Regular in/out-sample statistics for each fold
            kfolds_performance.(xModel).rankcorr_stat.value.(xSample)(:,:,iMasterKfolds) = perf.(xModel).rankcorr_stat.(xSample);
            kfolds_performance.(xModel).absrmse_stat.value.(xSample)(:,:,iMasterKfolds) = perf.(xModel).absrmse_stat.(xSample);
            kfolds_performance.(xModel).absrmse_stat_rescaled.value.(xSample)(:,:,iMasterKfolds) = perf.(xModel).absrmse_stat_rescaled.(xSample);
            
            % in/out-sample statistics for each fold based on 1000 random permutations of weights.
            kfolds_performance.(xModel).rankcorr_stat.bootstrap.(xSample)(:,:,:,iMasterKfolds) = perf.(xModel).rankcorr_stat.bootstrap.(xSample);
            kfolds_performance.(xModel).absrmse_stat.bootstrap.(xSample)(:,:,:,iMasterKfolds) = perf.(xModel).absrmse_stat.bootstrap.(xSample);
            kfolds_performance.(xModel).absrmse_stat_rescaled.bootstrap.(xSample)(:,:,:,iMasterKfolds) = perf.(xModel).absrmse_stat_rescaled.bootstrap.(xSample);
            
            kfolds_performance.avgvol.(xSample)(:,:,iMasterKfolds) = reshape(sqrt(mean(rolling_retsq(sampleFilter).*ones(size(bestmodel.(xModel).absrmse_stat.wts.(xSample))))),size(all_models));
        end
    end
end

for iModel = 1:2
    xModel = xModels{iModel};
    
    for iSample = 1:2
        xSample = xSamples{iSample};
        
        % K-folds average of statistics for in/out-sample
        kfolds_performance.(xModel).rankcorr_stat.avg.value.(xSample) = nanmean(kfolds_performance.(xModel).rankcorr_stat.value.(xSample),3);
        kfolds_performance.(xModel).absrmse_stat.avg.value.(xSample) = nanmean(kfolds_performance.(xModel).absrmse_stat.value.(xSample),3);
        kfolds_performance.(xModel).absrmse_stat_rescaled.avg.value.(xSample) = nanmean(kfolds_performance.(xModel).absrmse_stat_rescaled.value.(xSample),3);
        
        % K-folds average of statistics for in/out-sample using bootstrapped random permutations
        kfolds_performance.(xModel).rankcorr_stat.avg.bootstrap.(xSample) = nanmean(kfolds_performance.(xModel).rankcorr_stat.bootstrap.(xSample),4);
        kfolds_performance.(xModel).absrmse_stat.avg.bootstrap.(xSample) = nanmean(kfolds_performance.(xModel).absrmse_stat.bootstrap.(xSample),4);
        kfolds_performance.(xModel).absrmse_stat_rescaled.avg.bootstrap.(xSample) = nanmean(kfolds_performance.(xModel).absrmse_stat_rescaled.bootstrap.(xSample),4);
        
        % What fraction of random bootstrapped samples have a k-folds averaged statistic that is
        % greater than the actual k-fold averaged sample statistics (in/out sample)?
        kfolds_performance.(xModel).rankcorr_stat.avg.significance.(xSample) = mean(kfolds_performance.(xModel).rankcorr_stat.avg.value.(xSample) < kfolds_performance.(xModel).rankcorr_stat.avg.bootstrap.(xSample), 3);
        kfolds_performance.(xModel).absrmse_stat.avg.significance.(xSample) = mean(kfolds_performance.(xModel).absrmse_stat.avg.value.(xSample) < kfolds_performance.(xModel).absrmse_stat_rescaled.avg.bootstrap.(xSample), 3);
        kfolds_performance.(xModel).absrmse_stat_rescaled.avg.significance.(xSample) = mean(kfolds_performance.(xModel).absrmse_stat_rescaled.avg.value.(xSample) < kfolds_performance.(xModel).absrmse_stat_rescaled.avg.bootstrap.(xSample), 3);
        
        % What fraction of random bootstrapped samples have a non-kfold statistic that is
        % greater than the actual non-kfold sample statistics (in sample)?
        kfolds_performance.(xModel).rankcorr_stat.significance.(xSample) = squeeze(mean(kfolds_performance.(xModel).rankcorr_stat.value.(xSample) < permute(kfolds_performance.(xModel).rankcorr_stat.bootstrap.(xSample),[1 2 4 3]), 3));
        kfolds_performance.(xModel).absrmse_stat.significance.(xSample) = squeeze(mean(kfolds_performance.(xModel).absrmse_stat.value.(xSample) < permute(kfolds_performance.(xModel).absrmse_stat_rescaled.bootstrap.(xSample),[1 2 4 3]), 3));
        kfolds_performance.(xModel).absrmse_stat_rescaled.significance.(xSample) = squeeze(mean(kfolds_performance.(xModel).absrmse_stat_rescaled.value.(xSample) < permute(kfolds_performance.(xModel).absrmse_stat_rescaled.bootstrap.(xSample),[1 2 4 3]), 3));

        % Calc stats as fraction of average volatility.
        kfolds_performance.(xModel).absrmse_stat.frac.value.(xSample) = kfolds_performance.(xModel).absrmse_stat.value.(xSample)./kfolds_performance.avgvol.(xSample);
        kfolds_performance.(xModel).absrmse_stat_rescaled.frac.value.(xSample) = kfolds_performance.(xModel).absrmse_stat_rescaled.value.(xSample)./kfolds_performance.avgvol.(xSample);
        kfolds_performance.(xModel).absrmse_stat.avg.frac.value.(xSample) = nanmean(kfolds_performance.(xModel).absrmse_stat.frac.value.(xSample),3);
        kfolds_performance.(xModel).absrmse_stat_rescaled.avg.frac.value.(xSample) = nanmean(kfolds_performance.(xModel).absrmse_stat_rescaled.frac.value.(xSample),3);
        
    end
    for iStatPart = 1:2
        xStatPart = xStatParts{iStatPart};
        for iStat = 1:3
            xStat = xStats{iStat};
            panel.(xModel).(xStat).(xStatPart) = reshape(permute(cat(3,kfolds_performance.(xModel).(xStat).(xStatPart).is(:,:,1),...
                                                                       kfolds_performance.(xModel).(xStat).(xStatPart).oos(:,:,1)),[3 2 1]),[6,3]);
            panel.(xModel).(xStat).avg.(xStatPart) = reshape(permute(cat(3,kfolds_performance.(xModel).(xStat).avg.(xStatPart).is(:,:,1),...
                                                                       kfolds_performance.(xModel).(xStat).avg.(xStatPart).oos(:,:,1)),[3 2 1]),[6,3]);
        end
        panel.(xModel).(xStatPart) = [panel.(xModel).rankcorr_stat.(xStatPart) panel.(xModel).absrmse_stat.(xStatPart) panel.(xModel).absrmse_stat_rescaled.(xStatPart)];
        panel.(xModel).avg.(xStatPart) = [panel.(xModel).rankcorr_stat.avg.(xStatPart) panel.(xModel).absrmse_stat.avg.(xStatPart) panel.(xModel).absrmse_stat_rescaled.avg.(xStatPart)];
    end
    panel.(xModel).all = [panel.(xModel).value panel.(xModel).significance];
    panel.(xModel).avg.all = [panel.(xModel).avg.value panel.(xModel).avg.significance];
end

[panel.rankcorr_model.all; panel.absrmse_model.all; panel.rankcorr_model.avg.all; panel.absrmse_model.avg.all];

% 
% cat(2,[[reshape(permute(cat(3,kfolds_performance.(xModel).rankcorr_stat.is(:,:,1),kfolds_performance.(xModel).rankcorr_stat.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat.is(:,:,1),kfolds_performance.(xModel).absrmse_stat.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat.frac.is(:,:,1),kfolds_performance.(xModel).absrmse_stat.frac.oos(:,:,1)),[3 2 1]),[6,3])];
% [reshape(permute(cat(3,kfolds_performance.(xModel).rankcorr_stat.avg.is(:,:,1),kfolds_performance.(xModel).rankcorr_stat.avg.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat.avg.is(:,:,1),kfolds_performance.(xModel).absrmse_stat.avg.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat.avg.frac.is(:,:,1),kfolds_performance.(xModel).absrmse_stat.avg.frac.oos(:,:,1)),[3 2 1]),[6,3])]],...
% [[reshape(permute(cat(3,kfolds_performance.(xModel).rankcorr_stat.significance.is(:,:,1),kfolds_performance.(xModel).rankcorr_stat.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat.significance.is(:,:,1),kfolds_performance.(xModel).absrmse_stat.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat_rescaled.significance.is(:,:,1),kfolds_performance.(xModel).absrmse_stat_rescaled.significance.oos(:,:,1)),[3 2 1]),[6,3])];
% [reshape(permute(cat(3,kfolds_performance.(xModel).rankcorr_stat.avg.significance.is(:,:,1),kfolds_performance.(xModel).rankcorr_stat.avg.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat.avg.significance.is(:,:,1),kfolds_performance.(xModel).absrmse_stat.avg.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
%     reshape(permute(cat(3,kfolds_performance.(xModel).absrmse_stat_rescaled.avg.significance.is(:,:,1),kfolds_performance.(xModel).absrmse_stat_rescaled.avg.significance.oos(:,:,1)),[3 2 1]),[6,3])]])
