% This script runs the run_all_models script multiple times, iterating the
% results repeatedly to test different out of sample periods.

% Please ensure that the load data parameters are commented out on lines 2
% and 3 in the run_all_models script.

%% Define master k-folds approach
master_params.master_kfolds = 10;

master_params.look_ahead = 1;

%% Load data (See note above about commenting out in run_all_model script

% Pick one...
load_currency_data_script;
% load_equity_data_script;
% load_detrended_equity_data_script;
% load_detrended_currency_data_script;
% load_scrambled_equity_data_script;
% load_scrambled_currency_data_script;

%% Create master variable structures
[T,N] = size(returns.data);
Tcircshift = floor(T/master_params.master_kfolds);

%% Run master k-folds

for iMasterKfolds = 1:master_params.master_kfolds
    if iMasterKfolds > 1
        % Rotate the return data by 1/10th
        returns.data = circshift(returns.data,Tcircshift);
    end
    
    if ~(exist('kfolds_models','var')&&(size(kfolds_models,2)>=iMasterKfolds)) % If we've already run this one, just skip over it.
        fprintf('Running %d fold of %d folds\n',iMasterKfolds,master_params.master_kfolds);
        clear all_models; % Reset all_models structure
        run_all_models_limited_iterations; % Run the master script
        kfolds_models(iMasterKfolds).results = rmfield(all_models,'models');       
    end 
    0;
end

%% Analyze results

for iMasterKfolds = 1:master_params.master_kfolds
    all_models = kfolds_models(iMasterKfolds).results;
    calculate_out_of_sample_performance_script;
    kfolds_performance.retsq_rankcorr_is(:,:,iMasterKfolds) = retsq_rankcorr_is;
    kfolds_performance.retsq_binary_is(:,:,iMasterKfolds) = retsq_binary_is;
    kfolds_performance.retsq_absrmse_is(:,:,iMasterKfolds) = retsq_absrmse_is;
    
    kfolds_performance.retsq_rankcorr_oos(:,:,iMasterKfolds) = retsq_rankcorr_oos;
    kfolds_performance.retsq_binary_oos(:,:,iMasterKfolds) = retsq_binary_oos;
    kfolds_performance.retsq_absrmse_oos(:,:,iMasterKfolds) = retsq_absrmse_oos;
end

kfolds_performance.retsq_rankcorr_is_avg = nanmean(kfolds_performance.retsq_rankcorr_is,3);
kfolds_performance.retsq_binary_is_avg = nanmean(kfolds_performance.retsq_binary_is,3);
kfolds_performance.retsq_absrmse_is_avg = nanmean(kfolds_performance.retsq_absrmse_is,3);

kfolds_performance.retsq_rankcorr_oos_avg = nanmean(kfolds_performance.retsq_rankcorr_oos,3);
kfolds_performance.retsq_binary_oos_avg = nanmean(kfolds_performance.retsq_binary_oos,3);
kfolds_performance.retsq_absrmse_oos_avg = nanmean(kfolds_performance.retsq_absrmse_oos,3);

% Save results
clear thesemodels model_signal_ranks model_onoff_signal all_models
save(sprintf('kfold_%dday_%s_limited_iterations_workspace_%s.mat',master_params.look_ahead,strrep(master_params.data_description,' ','_'),datestr(today,'yyyy-mm-dd')));