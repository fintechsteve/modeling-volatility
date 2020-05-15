% Reset parameters each iteration
methodology_params = master_params;

switch iMethodology
    case 1 % Mahalanobis Distance
        % Mahalanobis Parameters
        methodology_params.methodology_description = 'Mahalanobis';
        methodology_params.search_choices.cov_horiz = [520];
        methodology_params.search_choices.ma = [1 65 260];
        
        model_fun = @trade_mahalanobis;
        
    case 2 % GARCH Estimation
        methodology_params.methodology_description = 'GARCH';
        methodology_params.search_choices.mvgarch_p = [1];
        methodology_params.search_choices.mvgarch_q = [0 0 0];
        
        methodology_params.mvgarch_o = 0;
        methodology_params.mvgarch.qmax = 5;
        
        model_fun = @trade_garch;
        
    case 3 % ML Blender
        methodology_params.methodology_description = 'Elastic Net Blender';
        
end
