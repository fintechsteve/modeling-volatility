clear
% This script runs the run_all_models script multiple times, iterating the
% results repeatedly to test different out of sample periods.

% Please ensure that the load data parameters are commented out on lines 2
% and 3 in the run_all_models script.

%% Define master k-folds approach
master_params.master_kfolds = 10;

master_params.look_ahead = 1;

%% Load data (See note above about commenting out in run_all_model script

% Pick one...
% load_currency_data_script;
% load_equity_data_script;
% load_detrended_equity_data_script;
% load_detrended_currency_data_script;
% load_scrambled_equity_data_script;
load_scrambled_currency_data_script;

%% Create master variable structures
[T,N] = size(returns.data);
Tcircshift = floor(T/master_params.master_kfolds);

T_oos_start = find(returns.dates>datenum('31-Dec-2004'),1,'first');
% T_oos_start = find(returns.dates>datenum('01-Jan-2020'),1,'first');

%% Run master k-folds

for iMasterKfolds = 1:master_params.master_kfolds
    if iMasterKfolds > 1
        % Rotate the return data by 1/10th
        returns.data = circshift(returns.data,Tcircshift);
    end
    
    if ~(exist('kfolds_models','var')&&(size(kfolds_models,2)>=iMasterKfolds)) % If we've already run this one, just skip over it.
        fprintf('Running %d fold of %d folds\n',iMasterKfolds,master_params.master_kfolds);
        clear all_models; % Reset all_models structure
        run_all_models; % Run the master script
        kfolds_models(iMasterKfolds).results = rmfield(all_models,'models');       
    end 
    0;
end

%% Analyze results

calculate_stats_v2;
[panel.rankcorr_model.all; panel.absrmse_model.all; panel.rankcorr_model.avg.all; panel.absrmse_model.avg.all];

% Save results
clear thesemodels model_signal_ranks model_onoff_signal all_models
save(sprintf('kfold_%dday_%s_workspace_%s.mat',master_params.look_ahead,strrep(master_params.data_description,' ','_'),datestr(today,'yyyy-mm-dd')));