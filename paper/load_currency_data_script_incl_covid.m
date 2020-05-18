<<<<<<< HEAD
%% Load in Currency Data
% [returns.data,~,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\Currency_TI.xls','Returns','C11:K11834');
% [~,returndates,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\Currency_TI.xls','Returns','B11:B11834');
% [~,returns.names,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\Currency_TI.xls','Returns','C9:K9');
% returns.dates = datenum(returndates);
% save 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\currency_returns.mat' returns

load 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\currency_returns.mat'

wts_vector = [0, .091, .036, .576, .119, .136, 0, 0, .042]; % Fixed DXY weights
master_params.data_description = 'Developed Markets Currency Returns';

% returns.data = returns.data(1:11733,:)
=======
%% Load in Currency Data
% [returns.data,~,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\Currency_TI.xls','Returns','C11:K11834');
% [~,returndates,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\Currency_TI.xls','Returns','B11:B11834');
% [~,returns.names,~]=xlsread('C:\Users\websi\OneDrive\THIRD CULTURE PAPER\Currency_TI.xls','Returns','C9:K9');
% returns.dates = datenum(returndates);
% save 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\currency_returns.mat' returns

load 'C:\Users\websi\OneDrive\THIRD CULTURE PAPER\currency_returns.mat'

wts_vector = [0, .091, .036, .576, .119, .136, 0, 0, .042]; % Fixed DXY weights
master_params.data_description = 'Developed Markets Currency Returns';

% returns.data = returns.data(1:11733,:)
>>>>>>> 940ff4ba00825120f7c7c0fcfaadbacd2bd26b5d
% returns.dates = returns.dates(1:11733,:)