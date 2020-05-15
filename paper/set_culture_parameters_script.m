% Reset parameters each iteration
culture_params = methodology_params;

switch iCulture
    case 1 % Finance / Fully insample estimation
        % Note: all sample windows are identical for finance culture
        
        culture_params.culture_description = 'Finance';
        culture_params.estimation_insample = ~master_params.out_of_sample; % Window for estimating parameters of individual models
        culture_params.optimization_insample = ~master_params.out_of_sample; % Window for choosing among models (or hyper parameters in ML case)
        culture_params.optimization_insample_ml1 = ~master_params.out_of_sample; % Window for choosing among model (in ML case)
        
    case 2 % Econometrics / Iterative fitting
        % Note: first 2/3 of insample period is used for estimation of
        % model parameters. Remaining 1/3 is used to choose models and set
        % hyper-parameters. For ML model, the sample is split 2/3, 1/6,
        % 1/6 between model parameters, model selection, blender hyper
        % parameter estimation.
        
        culture_params.culture_description = 'Econometrics';
        T_est_is = find(returns.dates>datenum('31-Dec-1994'),1,'first');
        culture_params.estimation_insample = [true(T_est_is,1); false(T-T_est_is,1)];
        if iMethodology == 3
            culture_params.optimization_insample = [false(floor((T_est_is+T_oos_start-1)/2),1); true(floor((T_oos_start-T_est_is)/2),1); false(T-T_oos_start+1,1)];
            culture_params.optimization_insample_ml1 = ~(culture_params.out_of_sample|culture_params.estimation_insample|culture_params.optimization_insample);
        else
            culture_params.optimization_insample = ~(culture_params.out_of_sample|culture_params.estimation_insample);
        end
        
    case 3 % Data science / k-folds
        % Note: Length of windows is same as econometrics culture, but
        % windows are rotated 5 fold to create k-fold out of sample
        % testing.
        
        culture_params.culture_description = 'Data Science';
        culture_params.nfold = 5;
        T_est_is = find(returns.dates>datenum('31-Dec-1994'),1,'first');
        culture_params.estimation_insample = [true(T_est_is,1); false(T-T_est_is,1)];
        if iMethodology == 3
            culture_params.optimization_insample = [false(floor((T_est_is+T_oos_start-1)/2),1); true(floor((T_oos_start-T_est_is)/2),1); false(T-T_oos_start+1,1)];
            culture_params.optimization_insample_ml1 = ~(culture_params.out_of_sample|culture_params.estimation_insample|culture_params.optimization_insample);
        else
            culture_params.optimization_insample = ~(culture_params.out_of_sample|culture_params.estimation_insample);
        end
        
end
