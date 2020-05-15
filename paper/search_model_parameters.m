function all_models = search_model_parameters(Y, X, model_params, model_fun)
% Run backtest for all possible model parameters (specified in fields
% model_params.search_choices.*).

search_choices = model_params.search_choices;
search_fields = fieldnames(search_choices);
nFields = numel(search_fields);

% Pull out the last field
choice_field = search_fields{end};
choice_values = model_params.search_choices.(choice_field);
nChoices = numel(choice_values);

% Remove field from passed-down search field
if nFields > 1
    model_params.search_choices = rmfield(model_params.search_choices,choice_field);
end

all_models =[];

% Loop over choice field
for iChoice = 1:nChoices
    choice_params = model_params;
    choice_params.(choice_field) = choice_values(iChoice);

    if model_params.verbose
        fprintf('%s: %d  ', choice_field, choice_values(iChoice));
    end
    
    % Iterate over other fields or run the actual model
    if nFields > 1
        choice_model = shiftdim(search_model_parameters(Y, X, choice_params, model_fun),-1);
    else
        if isfield(model_params,'nfold')&&model_params.nfold>1
            choice_model = shiftdim(nfold_crossvalidation(Y, X, choice_params, model_fun),-1);
        else
            choice_model = model_fun(Y, X, choice_params);
        end
    end
    if model_params.verbose
        fprintf('\n');
    end
    all_models = [all_models; choice_model];
    
end