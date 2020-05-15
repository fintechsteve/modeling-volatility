%% Load in Currency Data
% [returns.data,~,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls','Returns','C11:K11224');
% [~,returndates,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls','Returns','B11:B11224');
% [~,returns.names,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\Currency_TI.xls','Returns','C9:K9');
% returns.dates = datenum(returndates);
% save currency_returns.mat returns

load currency_returns.mat
[T, N] = size(returns.data);
T_oos_start = find(returns.dates>datenum('31-Dec-2004'),1,'first');

returns.data((T_oos_start+20):end,:) = 1e6*randn(T-T_oos_start-20+1,N);

wts_vector = [0, .091, .036, .576, .119, .136, 0, 0, .042]; % Fixed DXY weights
master_params.data_description = 'Developed Markets Currency Returns (Scrambled)';