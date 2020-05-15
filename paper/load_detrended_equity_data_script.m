%% Load in Equities Data
% [returns.data,~,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\US Equity_TI.xls','Returns','C11:L11745');
% [~,returndates,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\US Equity_TI.xls','Returns','B11:B11745');
% [~,returns.names,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\US Equity_TI.xls','Returns','C9:L9');
% returns.dates = datenum(returndates);
% save equity_returns.mat returns
 
load equity_returns.mat
wts_vector = [.0604, .0308, .0996, .1267, .0799, .1348, 0.1766, .2413, .0209, .0290]; % Fixed sector weights
master_params.data_description = 'US Equity Sector Returns (Detrended)';

Y = sum(returns.data.*wts_vector,2);
Ysq_hp = hp_filter(Y.^2,129600);

returns.data = bsxfun(@(a,b) (a./b), returns.data,sqrt(Ysq_hp)./mean(sqrt(Ysq_hp)));

Y_detrend = sum(returns.data.*wts_vector,2);

% sacf_data = sacf(Y.^2,65);
% title('Autocorrelogram - Equity Squared Returns');
% spacf_data = spacf(Y.^2,65);
% title('Partial Autocorrelogram - Equity Squared Returns');
% 
% sacf_data = sacf(Y_detrend.^2,65);
% title('Autocorrelogram - Equity Squared Returns (Detrended)');
% spacf_data = spacf(Y_detrend.^2,65);
% title('Partial Autocorrelogram - Equity Squared Returns (Detrended)');
