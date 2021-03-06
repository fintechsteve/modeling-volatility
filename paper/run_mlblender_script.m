% Get returns and signals from mahalanobis and GARCH models
thisculturedims = size([all_models(1,iCulture).models all_models(2,iCulture).models]);
if numel(thisculturedims) == 2
    thisculturedims(3) = 1;
end

retlen = size(all_models(1,iCulture).models(1,1).rolling_rets,1);

rolling_rets = reshape([all_models(1,iCulture).models(1,1,:).rolling_rets],[retlen, thisculturedims(3)]);
rolling_retsq = reshape([all_models(1,iCulture).models(1,1,:).rolling_retsq],[retlen, thisculturedims(3)]);
rolling_retsqsig = rolling_retsq>prctile(rolling_retsq(culture_params.estimation_insample,:),master_params.trade_prctile);
rolling_retsqrank = NaN(size(rolling_retsqsig));
for iFold = 1:thisculturedims(3)
    rolling_retsqrank(:,iFold) = mean(rolling_retsq(:,iFold) > rolling_retsq(culture_params.estimation_insample,iFold)',2);
end

model_signal_ranks = reshape([all_models(1,iCulture).models.rolling_rank all_models(2,iCulture).models.rolling_rank],[retlen, prod(thisculturedims(1:2)), thisculturedims(3)]);
% model_onoff_signal = reshape([all_models(1,iCulture).models.risk_off all_models(2,iCulture).models.risk_off],[retlen, prod(thisculturedims(1:2)), thisculturedims(3)]);

% What are we optimizing?
% retsq_rankcorr = corr(rolling_retsq(culture_params.optimization_insample),model_signal_ranks(culture_params.optimization_insample,:),'rows','pairwise','type','spearman')';
% retsq_binary = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*(model_onoff_signal(culture_params.optimization_insample,:)-(rolling_retrank(culture_params.optimization_insample,:)>.5)).^2));
% absret_rmse = sqrt(mean(rolling_retsq(culture_params.optimization_insample).*(model_signal_ranks(culture_params.optimization_insample,:)-rolling_retrank(culture_params.optimization_insample)).^2))';

nModel1 = numel(all_models(1,iCulture).models(:,:,1));
nModel2 = numel(all_models(1,iCulture).models(:,:,1));
xRankCorr = (all_models(2,iCulture).bestmodel_rankcorr.model_params.mvgarch_q+1)+6*(all_models(2,iCulture).bestmodel_rankcorr.model_params.mvgarch_p-1);
% xBinary = (all_models(2,iCulture).bestmodel_binary.model_params.mvgarch_q+1)+6*(all_models(2,iCulture).bestmodel_binary.model_params.mvgarch_p-1);


for iFold = 1:size(model_signal_ranks,3)
    %     for iAlpha = 1:10
    %         xalpha = iAlpha/10;
    %         fprintf('ML alpha = %0.1f\n',xalpha);
    %         optimization_insample_ml1 = culture_params.optimization_insample_ml1;
    %         [Brankcorr{iAlpha,iFold},Srankcorr{iAlpha,iFold}] = lasso(model_signal_ranks(optimization_insample_ml1,:,iFold), rolling_retsqrank(optimization_insample_ml1,iFold),'Alpha',xalpha,'Weight',sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
    %         [Bbinary{iAlpha,iFold},Sbinary{iAlpha,iFold}] = lasso(model_onoff_signal(optimization_insample_ml1,:,iFold), (rolling_retsqrank(optimization_insample_ml1,iFold)>master_params.trade_prctile),'Alpha',xalpha,'Weight',sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
    %         [Babsrmse{iAlpha,iFold},Sabsrmse{iAlpha,iFold}] = lasso(model_signal_ranks(optimization_insample_ml1,:,iFold), rolling_retsqrank(optimization_insample_ml1,iFold),'Alpha',xalpha,'Weight',sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
    
    for iAlpha = 1:3
        switch iAlpha
            case 1
                xalpha = 1/10;
            case 2
                xalpha = .5;
            case 3
                xalpha = 1;
        end
        fprintf('ML alpha = %0.1f\n',xalpha);
        optimization_insample_ml1 = culture_params.optimization_insample_ml1;
        Brankcorr{iAlpha,iFold} = lasso(model_signal_ranks(optimization_insample_ml1,:,iFold), rolling_retsqrank(optimization_insample_ml1,iFold),'Alpha',xalpha,'NumLambda',20,'Weight',sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
        %         Bbinary{iAlpha,iFold} = lassoglm(model_onoff_signal(optimization_insample_ml1,:,iFold), (rolling_retsqrank(optimization_insample_ml1,iFold)>master_params.trade_prctile/100),'binomial','Alpha',xalpha,'NumLambda',20,'Weight',sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
        %         Babsrmse{iAlpha,iFold} = lasso(model_signal_ranks(optimization_insample_ml1,:,iFold), rolling_retsqrank(optimization_insample_ml1,iFold),'Alpha',xalpha,'NumLambda',20,'Weight',sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
        %             Bbinary{iAlpha,iFold} = [zeros(nModel1,20); repmat((1:nModel2)'==xBinary,1,20)];
        %             Babsrmse{iAlpha,iFold} = [zeros(nModel1,20); repmat((1:nModel2)'==xRankCorr,1,20)];
        
        %         if max(sqrt(rolling_retsq(optimization_insample_ml1,iFold))) > 1
        %             rret_rescaled = sqrt(rolling_retsq(optimization_insample_ml1,iFold))./max(sqrt(rolling_retsq(optimization_insample_ml1,iFold)));
        %             Bbinary{iAlpha,iFold} = lassoglm(rret_rescaled.*model_onoff_signal(optimization_insample_ml1,:,iFold), rret_rescaled.*(rolling_retsqrank(optimization_insample_ml1,iFold)>master_params.trade_prctile/100),'binomial','Alpha',xalpha,'NumLambda',20);
        %         else
        %             Bbinary{iAlpha,iFold} = lassoglm(sqrt(rolling_retsq(optimization_insample_ml1,iFold)).*model_onoff_signal(optimization_insample_ml1,:,iFold), sqrt(rolling_retsq(optimization_insample_ml1,iFold)).*(rolling_retsqrank(optimization_insample_ml1,iFold)>master_params.trade_prctile/100),'binomial','Alpha',xalpha,'NumLambda',20);
        %         end
        
        
%         Babsrmse{iAlpha,iFold} = lasso(sqrt(rolling_retsq(optimization_insample_ml1,iFold)).*model_signal_ranks(optimization_insample_ml1,:,iFold), sqrt(rolling_retsq(optimization_insample_ml1,iFold)).*rolling_retsqrank(optimization_insample_ml1,iFold),'Alpha',xalpha,'NumLambda',20);
        Babsrmse{iAlpha,iFold} = lasso(sqrt(rolling_retsq(optimization_insample_ml1,iFold)).*model_signal_ranks(optimization_insample_ml1,:,iFold), sqrt(rolling_retsq(optimization_insample_ml1,iFold)).*rolling_retsqrank(optimization_insample_ml1,iFold),'Alpha',xalpha,'NumLambda',20);
        for iLambda = 1:size(Babsrmse{iAlpha,iFold},2)
            if sum(abs(Babsrmse{iAlpha,iFold}(:,iLambda)))==0
                Babsrmse{iAlpha,iFold}(:,iLambda) = ones(size(Babsrmse{iAlpha,iFold}(:,iLambda)))/numel(Babsrmse{iAlpha,iFold}(:,iLambda));
            end
        end
    end
end

clear thesemodels;
for iFold = 1:size(model_signal_ranks,3)
    for iAlpha = 1:3 %10
        for iLambda = 1:size(Babsrmse{iAlpha,iFold},2)
            thesemodels(iAlpha,iLambda,iFold).rolling_rets = rolling_rets;
            thesemodels(iAlpha,iLambda,iFold).rolling_retsq = rolling_retsq;
            thesemodels(iAlpha,iLambda,iFold).smoothed_signal = [];
            %             avg_binary = model_onoff_signal(:,:,iFold)*Bbinary{iAlpha,iFold}(:,iLambda);
            %             thesemodels(iAlpha,iLambda,iFold).risk_off = avg_binary > prctile(avg_binary(~culture_params.out_of_sample),master_params.trade_prctile);
            thesemodels(iAlpha,iLambda,iFold).risk_off = model_signal_ranks(:,:,iFold)*Brankcorr{iAlpha,iFold}(:,iLambda); %Brankcorr{iAlpha,iFold}(:,iLambda); % + Srankcorr{iAlpha,iFold}.Intercept(iLambda);
            thesemodels(iAlpha,iLambda,iFold).rolling_rank = model_signal_ranks(:,:,iFold)*Babsrmse{iAlpha,iFold}(:,iLambda); %Brankcorr{iAlpha,iFold}(:,iLambda); % + Srankcorr{iAlpha,iFold}.Intercept(iLambda);
            thesemodels(iAlpha,iLambda,iFold).model_params = culture_params;
            thesemodels(iAlpha,iLambda,iFold).model_params.alpha = iAlpha/10;
            thesemodels(iAlpha,iLambda,iFold).model_params.lambdarank = iLambda; %Srankcorr{iAlpha,iFold}.Lambda(iLambda);
            %             thesemodels(iAlpha,iLambda,iFold).model_params.lambdabinary = Srankcorr{iAlpha,iFold}.Lambda(iLambda);
            %             thesemodels(iAlpha,iLambda,iFold).model_params.lambdaabsrmse = Sabsrmse{iAlpha,iFold}.Lambda(iLambda);
            %             thesemodels(iAlpha,iLambda,iFold).model_params.Brankcorr = Brankcorr{iAlpha,iFold}(:,iLambda);
            %             thesemodels(iAlpha,iLambda,iFold).model_params.Bbinary = Bbinary{iAlpha,iFold}(:,iLambda);
            thesemodels(iAlpha,iLambda,iFold).model_params.Babsrmse = Babsrmse{iAlpha,iFold}(:,iLambda);
        end
    end
end