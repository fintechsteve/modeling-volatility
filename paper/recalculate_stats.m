clear
% load kfold_1day_Developed_Markets_Currency_Returns_(Scrambled)_workspace_2019-01-06.mat
load kfold_1day_Developed_Markets_Currency_Returns_workspace_2018-11-06.mat
% load kfold_1day_US_Equity_Sector_Returns_(Scrambled)_workspace_2019-01-05.mat
% load kfold_1day_US_Equity_Sector_Returns_workspace_2018-11-08.mat
% load kfold_20day_Developed_Markets_Currency_Returns_workspace_2018-12-17.mat
% load kfold_20day_US_Equity_Sector_Returns_workspace_2018-11-23.mat
% load kfold_1day_Developed_Markets_Currency_Returns_(Detrended)_workspace_2018-12-13.mat

for iMasterKfolds = 1:master_params.master_kfolds
    all_models = kfolds_models(iMasterKfolds).results;
    fprintf('fold %d\n', iMasterKfolds);
    calculate_out_of_sample_performance_script_v2;

    for xSample = {'is','oos'}
    % Regular in-sample statistics for each fold
    kfolds_performance.rankcorr_model.rankcorr_stat.(xSample)(:,:,iMasterKfolds) = perf.rankcorr_model.rankcorr_stat.is;
%     kfolds_performance.retsq_binary.is(:,:,iMasterKfolds) = retsq_binary.is;
    kfolds_performance.absrmse_model.absrmse_stat.is(:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.is;
    kfolds_performance.absrmse_model.absrmse_stat.rescaled.is(:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.rescaled.is;

    
    % Regular out-of-sample statistics for each fold
    kfolds_performance.rankcorr_model.rankcorr_stat.oos(:,:,iMasterKfolds) = perf.rankcorr_model.rankcorr_stat.oos;
%     kfolds_performance.retsq_binary.oos(:,:,iMasterKfolds) = retsq_binary.oos;
    kfolds_performance.absrmse_model.absrmse_stat.oos(:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.oos;
    kfolds_performance.absrmse_model.absrmse_stat.rescaled.oos(:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.rescaled.oos;

    % in-sample statistics for each fold based on 1000 random permutations of weights.
    kfolds_performance.rankcorr_model.rankcorr_stat.bootstrap.is(:,:,:,iMasterKfolds) = perf.rankcorr_model.rankcorr_stat.bootstrap.is;
    kfolds_performance.absrmse_model.absrmse_stat.bootstrap.is(:,:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.bootstrap.is;
    kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.is(:,:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.rescaled.bootstrap.is;
    
    % out-of-sample statistics for each fold based on 1000 random permutations of weights.
    kfolds_performance.rankcorr_model.rankcorr_stat.bootstrap.oos(:,:,:,iMasterKfolds) = perf.rankcorr_model.rankcorr_stat.bootstrap.oos;
    kfolds_performance.absrmse_model.absrmse_stat.bootstrap.oos(:,:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.bootstrap.oos;
    kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.oos(:,:,:,iMasterKfolds) = perf.absrmse_model.absrmse_stat.rescaled.bootstrap.oos;

    kfolds_performance.avgvol.is(:,:,iMasterKfolds) = reshape(sqrt(mean(rolling_retsq(~master_params.out_of_sample).*ones(size(rankrmse_model_wts.is)))),size(all_models));
    kfolds_performance.avgvol.oos(:,:,iMasterKfolds) = reshape(sqrt(mean(rolling_retsq(master_params.true_out_of_sample).*ones(size(rankrmse_model_wts.oos)))),size(all_models));
        
end

% kfolds_performance.absrmse_model.absrmse_stat.frac.is = kfolds_performance.absrmse_model.absrmse_stat.is./squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.is,3));
% kfolds_performance.absrmse_model.absrmse_stat.frac.oos = kfolds_performance.absrmse_model.absrmse_stat.is./squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.oos,3));
% kfolds_performance.absrmse_model.absrmse_stat.bootstrap.is_mean = nanmean(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.is,3);
% kfolds_performance.absrmse_model.absrmse_stat.bootstrap.oos_mean = nanmean(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.oos,3);

% K-folds average of statistics for in-sample
kfolds_performance.rankcorr_model.rankcorr_stat.avg.is = nanmean(kfolds_performance.rankcorr_model.rankcorr_stat.is,3);
% kfolds_performance.retsq_binary.avg.is = nanmean(kfolds_performance.retsq_binary.is,3);
kfolds_performance.absrmse_model.absrmse_stat.avg.is = nanmean(kfolds_performance.absrmse_model.absrmse_stat.is,3);
% kfolds_performance.absrmse_model.absrmse_stat.avg.frac.is = kfolds_performance.absrmse_model.absrmse_stat.avg.is./squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.is,3));
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.is = nanmean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.is,3);

% K-folds average of statistics for out-of-sample
kfolds_performance.rankcorr_model.rankcorr_stat.avg.oos = nanmean(kfolds_performance.rankcorr_model.rankcorr_stat.oos,3);
% kfolds_performance.retsq_binary.avg.oos = nanmean(kfolds_performance.retsq_binary.oos,3);
kfolds_performance.absrmse_model.absrmse_stat.avg.oos = nanmean(kfolds_performance.absrmse_model.absrmse_stat.oos,3);
% kfolds_performance.absrmse_model.absrmse_stat.avg.frac.oos = kfolds_performance.absrmse_model.absrmse_stat.avg.oos./squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.avg.bootstrap.oos,3));
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.oos = nanmean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.oos,3);

% K-folds average of statistics for in-sample using bootstrapped random permutations
kfolds_performance.rankcorr_model.rankcorr_stat.avg.bootstrap.is = nanmean(kfolds_performance.rankcorr_model.rankcorr_stat.bootstrap.is,4);
kfolds_performance.absrmse_model.absrmse_stat.avg.bootstrap.is = nanmean(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.is,4);
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.is = nanmean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.is,4);

% K-folds average of statistics for out-of-sample using bootstrapped random permutations
kfolds_performance.rankcorr_model.rankcorr_stat.avg.bootstrap.oos = nanmean(kfolds_performance.rankcorr_model.rankcorr_stat.bootstrap.oos,4);
kfolds_performance.absrmse_model.absrmse_stat.avg.bootstrap.oos = nanmean(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.oos,4);
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.oos = nanmean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.oos,4);

% What fraction of random bootstrapped samples have a k-folds averaged statistic that is
% greater than the actual k-fold averaged sample statistics (in sample)?
kfolds_performance.rankcorr_model.rankcorr_stat.avg.significance.is = mean(kfolds_performance.rankcorr_model.rankcorr_stat.avg.is < kfolds_performance.rankcorr_model.rankcorr_stat.avg.bootstrap.is, 3);
kfolds_performance.absrmse_model.absrmse_stat.avg.significance.is = mean(kfolds_performance.absrmse_model.absrmse_stat.avg.is < kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.is, 3);% < kfolds_performance.absrmse_model.absrmse_stat.avg.bootstrap.is, 3);
% kfolds_performance.absrmse_model.absrmse_stat.avg.frac.is_significance = mean(kfolds_performance.absrmse_model.absrmse_stat.avg.frac.is < kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.is./kfolds_performance.absrmse_model.absrmse_stat.bootstrap.frac.is, 3);
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.significance.is = mean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.is < kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.is, 3);

% What fraction of random bootstrapped samples have a k-folds averaged statistic that is
% greater than the actual k-fold averaged sample statistics (out of sample)?
kfolds_performance.rankcorr_model.rankcorr_stat.avg.significance.oos = mean(kfolds_performance.rankcorr_model.rankcorr_stat.avg.oos < kfolds_performance.rankcorr_model.rankcorr_stat.avg.bootstrap.oos, 3);
kfolds_performance.absrmse_model.absrmse_stat.avg.significance.oos = mean(kfolds_performance.absrmse_model.absrmse_stat.avg.oos < kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.oos, 3); % < kfolds_performance.absrmse_model.absrmse_stat.avg.bootstrap.oos, 3);
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.significance.oos = mean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.oos < kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.bootstrap.oos, 3);

% What fraction of random bootstrapped samples have a non-kfold statistic that is
% greater than the actual non-kfold sample statistics (in sample)?
kfolds_performance.rankcorr_model.rankcorr_stat.significance.is = squeeze(mean(kfolds_performance.rankcorr_model.rankcorr_stat.is < permute(kfolds_performance.rankcorr_model.rankcorr_stat.bootstrap.is,[1 2 4 3]), 3));
kfolds_performance.absrmse_model.absrmse_stat.significance.is = squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.is < permute(kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.is,[1 2 4 3]), 3)); % < permute(kfolds_performance.absrmse_model.absrmse_stat.bootstrap.is,[1 2 4 3]), 3));
kfolds_performance.absrmse_model.absrmse_stat.rescaled.significance.is = squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.is < permute(kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.is,[1 2 4 3]), 3));

% What fraction of random bootstrapped samples have a non-kfold statistic that is
% greater than the actual non-kfold sample statistics (out-of-sample)?
kfolds_performance.rankcorr_model.rankcorr_stat.significance.oos = squeeze(mean(kfolds_performance.rankcorr_model.rankcorr_stat.oos < permute(kfolds_performance.rankcorr_model.rankcorr_stat.bootstrap.oos,[1 2 4 3]), 3));
kfolds_performance.absrmse_model.absrmse_stat.significance.oos = squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.oos < permute(kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.oos,[1 2 4 3]), 3)); % < kfolds_performance.absrmse_model.absrmse_stat.bootstrap.oos, 3));
kfolds_performance.absrmse_model.absrmse_stat.rescaled.significance.oos = squeeze(mean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.oos < permute(kfolds_performance.absrmse_model.absrmse_stat.rescaled.bootstrap.oos,[1 2 4 3]), 3));

cat(2,[[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.rescaled.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.rescaled.oos(:,:,1)),[3 2 1]),[6,3])];
[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.avg.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.avg.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.avg.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.avg.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.oos(:,:,1)),[3 2 1]),[6,3])]],...
[[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.significance.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.rescaled.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.rescaled.significance.oos(:,:,1)),[3 2 1]),[6,3])];
[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.avg.significance.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.avg.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.avg.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.avg.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.significance.oos(:,:,1)),[3 2 1]),[6,3])]])

kfolds_performance.absrmse_model.absrmse_stat.frac.is = kfolds_performance.absrmse_model.absrmse_stat.is./kfolds_performance.avgvol.is;
kfolds_performance.absrmse_model.absrmse_stat.frac.oos = kfolds_performance.absrmse_model.absrmse_stat.oos./kfolds_performance.avgvol.oos;
kfolds_performance.absrmse_model.absrmse_stat.rescaled.frac.is = kfolds_performance.absrmse_model.absrmse_stat.rescaled.is./kfolds_performance.avgvol.is;
kfolds_performance.absrmse_model.absrmse_stat.rescaled.frac.oos = kfolds_performance.absrmse_model.absrmse_stat.rescaled.oos./kfolds_performance.avgvol.oos;
kfolds_performance.absrmse_model.absrmse_stat.avg.frac.is = nanmean(kfolds_performance.absrmse_model.absrmse_stat.frac.is,3);
kfolds_performance.absrmse_model.absrmse_stat.avg.frac.oos = nanmean(kfolds_performance.absrmse_model.absrmse_stat.frac.oos,3);
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.frac.is = nanmean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.frac.is,3);
kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.frac.oos = nanmean(kfolds_performance.absrmse_model.absrmse_stat.rescaled.frac.oos,3);

cat(2,[[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.frac.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.frac.oos(:,:,1)),[3 2 1]),[6,3])];
[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.avg.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.avg.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.avg.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.avg.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.avg.frac.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.avg.frac.oos(:,:,1)),[3 2 1]),[6,3])]],...
[[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.significance.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.rescaled.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.rescaled.significance.oos(:,:,1)),[3 2 1]),[6,3])];
[reshape(permute(cat(3,kfolds_performance.rankcorr_model.rankcorr_stat.avg.significance.is(:,:,1),kfolds_performance.rankcorr_model.rankcorr_stat.avg.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.avg.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.avg.significance.oos(:,:,1)),[3 2 1]),[6,3]),...
    reshape(permute(cat(3,kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.significance.is(:,:,1),kfolds_performance.absrmse_model.absrmse_stat.rescaled.avg.significance.oos(:,:,1)),[3 2 1]),[6,3])]])
