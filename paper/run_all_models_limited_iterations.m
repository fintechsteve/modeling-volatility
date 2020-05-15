%% Choose one script to run
% load_currency_data_script;
% load_scrambled_currency_data_script;
% load_test_currency_data_script;
% load_equity_data_script;

%% Set up Master Parameters
master_params.verbose = true;

% master_params.look_ahead = 20; %(Just look ahead one day for now)
master_params.trade_prctile = 75;

[T,N] = size(returns.data);
T_oos_start = find(returns.dates>datenum('31-Dec-2004'),1,'first');
master_params.out_of_sample = [false(T_oos_start-1,1); true(T-T_oos_start+1,1)];
master_params.true_out_of_sample = [false(T_oos_start+master_params.look_ahead-1,1); true(T-T_oos_start-master_params.look_ahead+1,1)];

master_params.wts = wts_vector; % Save for use in GARCH model

%% Calculate index as weighted sum of returns
index_rets = sum(returns.data.*wts_vector,2);

if isfield(master_params,'test_returns')&&master_params.test_returns
    % Shift index returns back n days so they can be more easily predicted
    index_rets = circshift(index_rets,master_params.look_ahead);
end

%% Create a model array with the following dimensions
% Dimension 1: Methodology: 1 = Turbulence. 2 = GARCH. 3 = Blender
% Dimension 2: Culture: 1= Finance/Insample overfitting. 2 = Econmetrics/Iterative fitting. 3 = Data Science/k-folds
% Dimension 3+: Hyperparemeters for individual models

for iMethodology = [1:3] % [1 2 3]
    
    set_methodology_parameters_script_limited_iterations;
    
    for iCulture = 1:3
        
        set_culture_parameters_script;
        
        % Check to see if model has already run. If it has, just load those
        % results. Otherwise run from scratch (Timesaving feature)
        if exist('all_models','var')&&all(size(all_models)>=[iMethodology,iCulture])&&numel(all_models(iMethodology,iCulture).models) > 0 % Have we already run this model? If so just reload the results
            thesemodels = all_models(iMethodology,iCulture).models;
        else
            fprintf('Running %s methodology with %s culture\n',culture_params.methodology_description, culture_params.culture_description);
            if iMethodology == 3 % Run ML blender here, using results from corresponding mahalanobis and corresponding GARCH
                run_mlblender_script;
            else
                thesemodels = search_model_parameters(index_rets, returns.data, culture_params, model_fun);
            end
            all_models(iMethodology,iCulture).models = thesemodels;
        end

        switch iCulture
            case 1 % Finance / Fully insample estimation

                calculate_non_kfold_insample_performance_script;
                
            case 2 % Econometrics / Iterative fitting

                calculate_non_kfold_insample_performance_script;
                
            case 3 % Data science / k-folds

                calculate_kfold_insample_performance_script;
                
        end
    end
end

calculate_out_of_sample_performance_script;