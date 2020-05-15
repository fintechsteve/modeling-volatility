%% Load in Currency Data
load currency_returns.mat

wts_vector = [0, .091, .036, .576, .119, .136, 0, 0, .042]; % Fixed DXY weights
master_params.data_description = 'Developed Markets Currency Returns (Detrended)';


Y = sum(returns.data.*wts_vector,2);
Ysq_hp = hp_filter(Y.^2,129600);

returns.data = bsxfun(@(a,b) (a./b), returns.data,sqrt(Ysq_hp)./mean(sqrt(Ysq_hp)));

Y_detrend = sum(returns.data.*wts_vector,2);

% sacf_data = sacf(Y.^2,65);
% title('Autocorrelogram - Currency Squared Returns');
% spacf_data = spacf(Y.^2,65);
% title('Partial Autocorrelogram - Currency Squared Returns');
% 
% sacf_data = sacf(Y_detrend.^2,65);
% title('Autocorrelogram - Currency Squared Returns (Detrended)');
% spacf_data = spacf(Y_detrend.^2,65);
% title('Partial Autocorrelogram - Currency Squared Returns (Detrended)');
