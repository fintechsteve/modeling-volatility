% C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls


%% Load in Data
% [returns.data,~,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls','Returns','C11:K11224');
% [~,returndates,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls','Returns','B11:B11224');
% [~,returns.names,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls','Returns','C9:K9');
% returns.dates = datenum(returndates);
% save currency_returns.mat returns

load currency_returns.mat
[T,N] = size(returns.data);

%% Calculate DXY
dxy_vector = [0, .091, .036, .576, .119, .136, 0, 0, .042];
dxy = sum(returns.data.*dxy_vector,2);

%% Set up Master Parameters
master_params.verbose = true;

master_params.look_ahead = 1; %20; (Just look ahead one day for now)
master_params.trade_prctile = 75;

T_oos_start = find(returns.dates>datenum('31-Dec-2004'),1,'first');
master_params.out_of_sample = [false(T_oos_start-1,1); true(T-T_oos_start+1,1)];

master_params.wts = dxy_vector;

%% Create a model array with the following dimensions
% Dimension 1: Methodology: 1 = Turbulence. 2 = GARCH. 3 = Blender
% Dimension 2: Culture: 1= Finance/Insample overfitting. 2 = Econmetrics/Iterative fitting. 3 = Data Science/k-folds
% Dimension 3+: Hyperparemeters for individual models

for iMethodology = [1:3]; % [1 2 3]
    
    % Reset parameters each iteration
    methodology_params = master_params;
    
    switch iMethodology
        case 1 % Mahalanobis Distance
            % Mahalanobis Parameters
            methodology_params.search_choices.cov_horiz = [130 260 390 520 780];
            methodology_params.search_choices.ma = [1 5 10 20 40 65];
            
            model_fun = @trade_mahalanobis;
            
        case 2 % GARCH Estimation
            methodology_params.search_choices.mvgarch_p = [1 2 3 4 5];
            methodology_params.search_choices.mvgarch_q = [0 1 2 3 4 5];
            
            methodology_params.mvgarch_o = 0;
            methodology_params.mvgarch.qmax = 5;
            
            model_fun = @trade_garch;
            
        case 3 % ML Blender
            
            model_fun = @trade_mlblender;
            
    end

    for iCulture = 1:3
        
        % Reset parameters each iteration
        culture_params = methodology_params;
        
        switch iCulture
            case 1 % Finance / Fully insample estimation
                culture_params.estimation_insample = ~master_params.out_of_sample;
                culture_params.optimization_insample = ~master_params.out_of_sample;
                culture_params.optimization_insample_ml1 = ~master_params.out_of_sample;
                
            case 2 % Econometrics / Iterative fitting
                
                T_est_is = find(returns.dates>datenum('31-Dec-1998'),1,'first');
                culture_params.estimation_insample = [true(T_est_is,1); false(T-T_est_is,1)];
                if iMethodology == 3
                    culture_params.optimization_insample = [false(floor((T_est_is+T_oos_start-1)/2),1); true(floor((T_oos_start-T_est_is)/2),1); false(T-T_oos_start+1,1)];
                    culture_params.optimization_insample_ml1 = ~(culture_params.out_of_sample|culture_params.estimation_insample|culture_params.optimization_insample);
                else
                    culture_params.optimization_insample = ~(culture_params.out_of_sample|culture_params.estimation_insample);
                end

            case 3 % Data science / k-folds
                culture_params.nfold = 5;
                T_est_is = find(returns.dates>datenum('31-Dec-1998'),1,'first');
                culture_params.estimation_insample = [true(T_est_is,1); false(T-T_est_is,1)];
                culture_params.optimization_insample = ~(culture_params.out_of_sample|culture_params.estimation_insample);
        end
        
        if all(size(all_models)>=[iMethodology,iCulture])&&numel(all_models(iMethodology,iCulture).models) > 0 % Have we already run this model? If so just reload the results
            thesemodels = all_models(iMethodology,iCulture).models;
        else
            if iMethodology == 3 && iCulture < 3 % Run dumb ML blender here, using results from dumb mahalanobis and dumb GARCH
                % Get returns and signals from mahalanobis and GARCH models
                rolling_rets = all_models(1,1).models(1,1).rolling_rets;
                rolling_retsq = all_models(1,1).models(1,1).rolling_retsq;
                rolling_retsqsig = rolling_retsq>median(rolling_retsq(culture_params.estimation_insample));
                rolling_retsqrank = mean(rolling_retsq> rolling_retsq(culture_params.estimation_insample)',2);
                
                model_signal_ranks = [all_models(1,iCulture).models.rolling_rank all_models(2,iCulture).models.rolling_rank];
                model_onoff_signal = [all_models(1,iCulture).models.risk_off all_models(2,iCulture).models.risk_off];
                
                for iAlpha = 1:10
                    xalpha = iAlpha/10;
                    fprintf('ML alpha = %0.1f\n',xalpha);
                    [Brankcorr{iAlpha},Srankcorr{iAlpha}] = lasso(model_signal_ranks(culture_params.optimization_insample_ml1,:), rolling_retsqrank(culture_params.optimization_insample_ml1),'Alpha',xalpha);
                    [Bbinary{iAlpha},Sbinary{iAlpha}] = lasso(model_onoff_signal(culture_params.optimization_insample_ml1,:), rolling_retsq(culture_params.optimization_insample_ml1),'Alpha',xalpha);
                    %                     [Bbinarycorr{iAlpha},Sbinarycorr{iAlpha}] = lassoglm(model_onoff_signal(culture_params.optimization_insample_ml1,:), rolling_retsqsig(culture_params.optimization_insample_ml1),'binomial','Alpha',xalpha);
                end
                
                clear thesemodels;
                for iAlpha = 1:10
                    for iLambda = 1:length(Srankcorr{iAlpha}.Lambda)
                        thesemodels(iAlpha,iLambda).rolling_rets = rolling_rets;
                        thesemodels(iAlpha,iLambda).rolling_retsq = rolling_retsq;
                        thesemodels(iAlpha,iLambda).smoothed_signal = [];
                        avg_binary = model_onoff_signal*Bbinary{iAlpha}(:,iLambda);
                        thesemodels(iAlpha,iLambda).risk_off = avg_binary > median(avg_binary(~culture_params.out_of_sample));
                        thesemodels(iAlpha,iLambda).rolling_rank = model_signal_ranks*Brankcorr{iAlpha}(:,iLambda);
                        thesemodels(iAlpha,iLambda).model_params = culture_params;
                        thesemodels(iAlpha,iLambda).model_params.alpha = iAlpha/10;
                        thesemodels(iAlpha,iLambda).model_params.lambdarank = Srankcorr{iAlpha}.Lambda(iLambda);
                        thesemodels(iAlpha,iLambda).model_params.lambdabinary = Srankcorr{iAlpha}.Lambda(iLambda);
                        thesemodels(iAlpha,iLambda).model_params.Brankcorr = Brankcorr{iAlpha}(:,iLambda);
                        thesemodels(iAlpha,iLambda).model_params.Bbinary = Bbinary{iAlpha}(:,iLambda);
                    end
                end
                0;
            else
                thesemodels = search_model_parameters(dxy, returns.data, culture_params, model_fun);
            end
            all_models(iMethodology,iCulture).models = thesemodels;
        end

        rolling_rets = thesemodels.rolling_rets;
        rolling_retsq = thesemodels.rolling_retsq;
        model_signal_ranks = [thesemodels.rolling_rank];
        model_onoff_signal = [thesemodels.risk_off];
        
        switch iCulture
            case 1 % Finance / Fully insample estimation
                
                % Determine optimal in sample model
                retsq_rankcorr = corr(rolling_retsq(culture_params.estimation_insample),model_signal_ranks(culture_params.estimation_insample,:),'rows','pairwise','type','spearman')';
                signal_weight = model_onoff_signal(culture_params.estimation_insample,:)./sum(model_onoff_signal(culture_params.estimation_insample,:),1) - ...
                    ~model_onoff_signal(culture_params.estimation_insample,:)./sum(~model_onoff_signal(culture_params.estimation_insample,:),1);
                retsq_binary = sum(rolling_retsq(culture_params.estimation_insample).*signal_weight);
                retsq_binarycorr = corr(rolling_retsq(culture_params.estimation_insample),model_onoff_signal(culture_params.estimation_insample,:),'rows','pairwise')';
                
                [~, x_bestmodel_rankcorr] = max(retsq_rankcorr);
                [~, x_bestmodel_binary] = max(retsq_binary);
                [~, x_bestmodel_binarycorr] = max(retsq_binarycorr);
                
                all_models(iMethodology,iCulture).bestmodel_rankcorr = thesemodels(x_bestmodel_rankcorr);
                all_models(iMethodology,iCulture).bestmodel_binary = thesemodels(x_bestmodel_binary);                
                all_models(iMethodology,iCulture).bestmodel_binarycorr = thesemodels(x_bestmodel_binarycorr);                
                
            case 2 % Econometrics / Iterative fitting
                
                % Determine optimal optimization-sample model
                retsq_rankcorr = corr(rolling_retsq(culture_params.optimization_insample),model_signal_ranks(culture_params.optimization_insample,:),'rows','pairwise','type','spearman')';
                signal_weight = model_onoff_signal(culture_params.optimization_insample,:)./sum(model_onoff_signal(culture_params.optimization_insample,:),1) - ...
                    ~model_onoff_signal(culture_params.optimization_insample,:)./sum(~model_onoff_signal(culture_params.optimization_insample,:),1);
                retsq_binary = sum(rolling_retsq(culture_params.optimization_insample).*signal_weight);
                retsq_binarycorr = corr(rolling_retsq(culture_params.optimization_insample),model_onoff_signal(culture_params.optimization_insample,:),'rows','pairwise')';

                [~, x_bestmodel_rankcorr] = max(retsq_rankcorr);
                [~, x_bestmodel_binary] = max(retsq_binary);
                [~, x_bestmodel_binarycorr] = max(retsq_binarycorr);
                
                all_models(iMethodology,iCulture).bestmodel_rankcorr = all_models(iMethodology,1).models(x_bestmodel_rankcorr);
                all_models(iMethodology,iCulture).bestmodel_binary = all_models(iMethodology,1).models(x_bestmodel_binary);                
                all_models(iMethodology,iCulture).bestmodel_binarycorr = all_models(iMethodology,1).models(x_bestmodel_binarycorr);                
                
            case 3 % Data science / k-folds
                retsq_rankcorr = corr(rolling_retsq(culture_params.optimization_insample),model_signal_ranks(culture_params.optimization_insample,:),'rows','pairwise','type','spearman')';
                retsq_rankcorr = mean(reshape(retsq_rankcorr,size(thesemodels)),3);
                signal_weight = model_onoff_signal(culture_params.optimization_insample,:)./sum(model_onoff_signal(culture_params.optimization_insample,:),1) - ...
                    ~model_onoff_signal(culture_params.optimization_insample,:)./sum(~model_onoff_signal(culture_params.optimization_insample,:),1);
                retsq_binary = sum(rolling_retsq(culture_params.optimization_insample).*signal_weight);
                retsq_binary = mean(reshape(retsq_binary,size(thesemodels)),3);
                retsq_binarycorr = corr(rolling_retsq(culture_params.optimization_insample),model_onoff_signal(culture_params.optimization_insample,:),'rows','pairwise')';
                retsq_binarycorr = mean(reshape(retsq_binarycorr,size(thesemodels)),3);

                [~, x_bestmodel_rankcorr] = max(retsq_rankcorr(:));
                [~, x_bestmodel_binary] = max(retsq_binary(:));
                [~, x_bestmodel_binarycorr] = max(retsq_binarycorr(:));
                
                all_models(iMethodology,iCulture).bestmodel_rankcorr = all_models(iMethodology,1).models(x_bestmodel_rankcorr);
                all_models(iMethodology,iCulture).bestmodel_binary = all_models(iMethodology,1).models(x_bestmodel_binary);                
                all_models(iMethodology,iCulture).bestmodel_binarycorr = all_models(iMethodology,1).models(x_bestmodel_binarycorr);                
                
        end
    end
end

rolling_rets = all_models(1,1).models(1).rolling_rets;
rolling_retsq = all_models(1,1).models(1).rolling_retsq;

bestmodel_rankcorr = [all_models.bestmodel_rankcorr];
best_model_signal_ranks = [bestmodel_rankcorr.rolling_rank];

bestmodel_binary = [all_models.bestmodel_binary];
best_model_onoff_signal = [bestmodel_binary.risk_off];

bestmodel_binarycorr = [all_models.bestmodel_binarycorr];
bestcorr_model_onoff_signal = [bestmodel_binarycorr.risk_off];

retsq_rankcorr_is = reshape(corr(rolling_retsq(~master_params.out_of_sample),best_model_signal_ranks(~master_params.out_of_sample,:),'rows','pairwise','type','spearman'),size(all_models));
signal_weight = best_model_onoff_signal(~master_params.out_of_sample,:)./sum(best_model_onoff_signal(~master_params.out_of_sample,:),1) - ...
               ~best_model_onoff_signal(~master_params.out_of_sample,:)./sum(~best_model_onoff_signal(~master_params.out_of_sample,:),1);
retsq_binary_is = reshape(sum(rolling_retsq(~master_params.out_of_sample).*signal_weight),size(all_models));
retsq_binarycorr_is = reshape(corr(rolling_retsq(~master_params.out_of_sample),bestcorr_model_onoff_signal(~master_params.out_of_sample,:),'rows','pairwise'),size(all_models));

retsq_rankcorr_oos = reshape(corr(rolling_retsq(master_params.out_of_sample),best_model_signal_ranks(master_params.out_of_sample,:),'rows','pairwise','type','spearman'),size(all_models));
signal_weight = best_model_onoff_signal(master_params.out_of_sample,:)./sum(best_model_onoff_signal(master_params.out_of_sample,:),1) - ...
               ~best_model_onoff_signal(master_params.out_of_sample,:)./sum(~best_model_onoff_signal(master_params.out_of_sample,:),1);
retsq_binary_oos = reshape(sum(rolling_retsq(master_params.out_of_sample).*signal_weight),size(all_models));
retsq_binarycorr_oos = reshape(corr(rolling_retsq(master_params.out_of_sample),bestcorr_model_onoff_signal(master_params.out_of_sample,:),'rows','pairwise'),size(all_models));

