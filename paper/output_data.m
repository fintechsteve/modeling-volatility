output.data = [rolling_retrank, sqrt(rolling_retsq), returns.data, abs(returns.data), [all_models(1,1).models.rolling_rank], [all_models(2,1).models.rolling_rank]];

output.data(:,2) = output.data(:,2)./(sum(output.data(~master_params.out_of_sample,2)));

ma_vals = arrayfun(@(x) [all_models(1,1).models(x).model_params.ma],1:30);
horiz_vals = arrayfun(@(x) [all_models(1,1).models(x).model_params.cov_horiz],1:30);
turb_names = arrayfun(@(x) sprintf('turb_ma%d_h%d',ma_vals(x),horiz_vals(x)),1:30,'UniformOutput',false);

p_vals = arrayfun(@(x) [all_models(2,1).models(x).model_params.mvgarch_p],1:30);
q_vals = arrayfun(@(x) [all_models(2,1).models(x).model_params.mvgarch_q],1:30);
garch_names = arrayfun(@(x) sprintf('garch_p%d_q%d',p_vals(x),q_vals(x)),1:30,'UniformOutput',false);

Xnames = arrayfun(@(x) sprintf('X%d',x),1:10,'UniformOutput',false);
absXnames = arrayfun(@(x) sprintf('absX%d',x),1:10,'UniformOutput',false);

output.colnames = [{'Yvar','Ywt'},Xnames,absXnames,turb_names,garch_names];

%% Set up Python
pd = py.importlib.import_module('pandas');
np = py.importlib.import_module('numpy');
dr = py.importlib.import_module('datarobot');

drc = dr.Client('oKnSBgs-pA7vhBXgIIpLb9e4RTkgfZKv', 'https://app.datarobot.com/api/v2');

tempInsampleData = output.data(~master_params.out_of_sample,:);
tempArrayRows = num2cell(1:size(tempInsampleData,1))';
            
npa = py.numpy.reshape(num2cell(tempInsampleData(:)'),int32(size(tempInsampleData)),'F');
pdf = py.pandas.DataFrame(npa);
pdf.columns = output.colnames;
pdf.index = py.numpy.reshape(tempArrayRows(:)',int32(size(tempArrayRows)),'F');
            
project = dr.Project.create(pdf,sprintf('Matlab %d day %s',master_params.look_ahead,master_params.data_description));
fprintf('Datarobot project %s created with ID %s...',char(project.project_name),char(project.id));
            
% Get X Variables Feature List
features = project.get_features;

justX = project.create_featurelist('JustX',py.list(output.colnames(3:end)));
            
% Set target: project.set_target(target, mode='auto', metric=None, quickrun=None, worker_count=None, positive_class=None, partitioning_method=None, featurelist_id=None, advanced_options=None, max_wait=600)
advanced_options = dr.AdvancedOptions(pyargs('weights','Ywt'));
project.set_target(pyargs('target','Yvar','metric','Weighted RMSE','featurelist_id',justX.id,'advanced_options',advanced_options,'worker_count',4));
project.unlock_holdout;
            
dr_project_id = char(project.id);
save(sprintf('dr_project_id_%d day %s',master_params.look_ahead,master_params.data_description),'dr_project_id');
fprintf('activated and saved\n');

tempOOSData = output.data(master_params.out_of_sample,:);
tempArrayRows = num2cell(1:size(tempOOSData,1))';
            
npa = py.numpy.reshape(num2cell(tempOOSData(:)'),int32(size(tempOOSData)),'F');
pdf = py.pandas.DataFrame(npa);
pdf.columns = output.colnames;
pdf.index = py.numpy.reshape(tempArrayRows(:)',int32(size(tempArrayRows)),'F');

prediction_dataset = project.upload_dataset(pdf);
fprintf('Datarobot prediction data uploaded %s with ID %s...',char(project.project_name),char(prediction_dataset.id));
                
% Get models
modellist = project.get_models();
nModels = length(modellist);
model_performance = NaN(nModels,3); % validation, cross-validation, holdout, total
for iModel = 1:nModels
    if isnumeric(modellist{iModel}.metrics.get('Weighted RMSE').get('validation'))
        model_performance(iModel,1) = modellist{iModel}.metrics.get('Weighted RMSE').get('validation');
    end
    if isnumeric(modellist{iModel}.metrics.get('Weighted RMSE').get('crossValidation'))
        model_performance(iModel,2) = modellist{iModel}.metrics.get('Weighted RMSE').get('crossValidation');
    end
    if isnumeric(modellist{iModel}.metrics.get('Weighted RMSE').get('holdout'))
        model_performance(iModel,3) = modellist{iModel}.metrics.get('Weighted RMSE').get('holdout');
    end
end

% Find best models for validation (Method 2), Cross-Validation
% (Method 3), Holdout (Method 1 approximation)
[minRMSE, bestModel] = min(model_performance);
insamplemodel = modellist{bestModel(3)};
% method2model = modellist{bestModel(1)};
datasciencemodel = modellist{bestModel(2)};
                
% Run predictions for these models
insample_predict_job = insamplemodel.request_predictions(prediction_dataset.id);
% method2_predict_job = method2model.request_predictions(prediction_dataset.id);
datascience_predict_job = datasciencemodel.request_predictions(prediction_dataset.id);
                
insample_predictions = insample_predict_job.get_result_when_complete;
Toos = sum(master_params.out_of_sample);
insample_predictvals = reshape(double(py.array.array('d', py.numpy.nditer(insample_predictions.as_matrix, pyargs('order', 'F')))), [Toos,2]);

%                 method2_predictions = method2_predict_job.get_result_when_complete;
%                 m2predictvals = reshape(double(py.array.array('d', py.numpy.nditer(method2_predictions.as_matrix, pyargs('order', 'F')))), [Toos,3]);

datascience_predictions = datascience_predict_job.get_result_when_complete;
datascience_predictvals = reshape(double(py.array.array('d', py.numpy.nditer(datascience_predictions.as_matrix, pyargs('order', 'F')))), [Toos,2]);

