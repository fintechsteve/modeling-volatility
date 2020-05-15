%% Load in Equities Data
% [returns.data,~,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\US Equity_TI.xls','Returns','C11:L11745');
% [~,returndates,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\US Equity_TI.xls','Returns','B11:B11745');
% [~,returns.names,~]=xlsread('C:\Users\websi\Documents\MATLAB\RealData\US Equity_TI.xls','Returns','C9:L9');
% returns.dates = datenum(returndates);
% save equity_returns.mat returns
 
load equity_returns.mat
[T, N] = size(returns.data);
returns.data = returns.data(randperm(T),:);
wts_vector = [.0604, .0308, .0996, .1267, .0799, .1348, 0.1766, .2413, .0209, .0290]; % Fixed sector weights
master_params.data_description = 'US Equity Sector Returns (Scrambled)';
