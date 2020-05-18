<<<<<<< HEAD
%% Load in Equities Data
%[returns.data,~,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\US Equity_TI.xls','Returns','C11:L12340');
%[~,returndates,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\US Equity_TI.xls','Returns','B11:B12340');
%[~,returns.names,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\US Equity_TI.xls','Returns','C9:L9');
%returns.dates = datenum(returndates);
%save 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\equity_returns.mat' returns
 
load 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\equity_returns.mat'
wts_vector = [.0604, .0308, .0996, .1267, .0799, .1348, 0.1766, .2413, .0209, .0290]; % Fixed sector weights
master_params.data_description = 'US Equity Sector Returns';

% returns.data = returns.data(1:12241,:)
=======
%% Load in Equities Data
%[returns.data,~,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\US Equity_TI.xls','Returns','C11:L12340');
%[~,returndates,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\US Equity_TI.xls','Returns','B11:B12340');
%[~,returns.names,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\US Equity_TI.xls','Returns','C9:L9');
%returns.dates = datenum(returndates);
%save 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\equity_returns.mat' returns
 
load 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\equity_returns.mat'
wts_vector = [.0604, .0308, .0996, .1267, .0799, .1348, 0.1766, .2413, .0209, .0290]; % Fixed sector weights
master_params.data_description = 'US Equity Sector Returns';

% returns.data = returns.data(1:12241,:)
>>>>>>> 940ff4ba00825120f7c7c0fcfaadbacd2bd26b5d
% returns.dates = returns.dates(1:12241,:)