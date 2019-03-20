# modeling-volatility


Overall objective: Learn how to model volatility using both traditional and more modern data science techniques. Taking into account some of the idiosyncracies of trading strategies.

0) Setting up the environment for the course (Eunice)
   a) Setting up github
   b) Setting up the environment:
      If people have Anaconda, use it.
      https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb
1) Data ingestion: Reading in and visualizing currency data. (Steve/Eunice)
2) Time-series properties of data and currency baskets. DXY 
3) Splitting the sample and saving some for out of sample testing. Basic validation.

4) Strategy 1: Intro to Turbulence. Why its used. Rough theory behind it. Choice of parameters. How to calculate (Static)

5) Creating a model and metric of success: Dynamic asset allocation. mapping between signal and weight. Alternative metrics (correlation between w and retsq, RMSE). Role of benchmark and model bias. Role of insample vs out of sample (some of the pitfalls).

6) Strategy 2: Introduction to GARCH Estimation. Why it is used. Theory behind it and estimation. p and q parameters, look back window. How to calculate (Static) - Sonya
7) Strategy 2 part 2 - GARCH revisited: Forward estimation and challenges of multi-day estimation. - Sonya

8) Strategy 3: Naive machine learning (Gradient boost). Linear only. Linear and squared.
9) Strategy 3+: Portfolio of models. Philosophy of models as securities in a portfolio. Simple just using outputs of models. More complex using models plus X, X^2. Weight normalization.

10) Improved methods of model validation and discussion of backtesting best practices. k-folds. Deviation between data science theory and finance practice. (Third Culture editorial)
