# Modeling Volatility Trading Using Econometrics and Machine Learning in Python
### by Stephen Lawrence, Ph.D. and Eunice Hameyie-Sanon

With thanks to: Sonya Cates, Maria Garrahan and Chuqi Yang

Overall objective: Learn how to model volatility using both traditional and more modern data science techniques. Taking into account some of the idiosyncracies of trading strategies.

## Introduction
Quantitive finance, econometrics and data science are often taken to be synonymous with one another. However, the skills and techniques used by desk quants, economists and computer scientists differ in both the tools used and the approach taken to the discipline.

Based on research from the paper "Applied Finance: The Third Culture" by Stephen Lawrence, Sonya Cates and Maria Garrahan, "Modeling Volatility Trading Using Econometrics and Machine Learning in Python" walks through the various steps necessary to model currency volatility and build a simple trading strategy based on three different methodologies.

Financial turbulence, based on Mahalanobis' distance metric is a simple dimension reducing metric providing an estimate of how "abnormal" returns are. It is believed by practitioners that abnormal returns are persistent and tend to predict volatility. Desk quants use heuristic measures like turbulence to scale risk positions with scant formal framework to translate signals into the appropriate portfolio risk adjustment.

Economists and risk managers prefer regression-based estimation and prediction such as GARCH, which assumes that the volatility of returns is autocorrelated and predictable by observing the interaction of past returns. This approach provides point estimates and error bounds for future volatilies conditional on recent conditions, which can be used to estimate an optimal risk allocation.

Data scientists approaching the challenge of volatility modeling may be surprised to find out that brute force application of nonlinear techniques like gradient boosting underperform the seeming simplicity of traditional heuristic and econometric models. However, much of this underperformance comes from misunderstanding the role that simple transformations like normalization by covariance matrices have on implicit feature selection.

By blending all three techniques and paying careful attention to validation and holdback methodologies, it is possible to create a trading strategy that outperforms traditional techniques while remaining transparent and rigorous.

## What this session will teach you:
* How to calculate financial turbulence, a simplistic measure of abnormal returns and volatility.
* How to estimate and parameterize a GARCH volatility model and how to extrapolate to get forward predictions of volatility.
* The challenges of using nonlinear data science techniques for volatility prediction and how to meld turbulence, GARCH and nonlinear models.
* How to transform signals into dynamic trading strategies and how to evaluate model performance.
* How to meld techniques and still be rigorous in the application of a modeling framework.

# Lesson Plan
0. Setting up the environment for the course
   1. Setting up github:
      1. If you do not have one, create a Github account per instructions at <https://github.com/>
      2. On your laptop, create a folder where you will save the seminar materials. For example craete folder "ODSC"
      3. Open your terminal window and change your current directory to the folder you create in the previous step.
      4. Clone the seminar repository using command `git clone https://github.com/fintechsteve/modeling-volatility`

   2. Setting up the environment:
      1. If you have anaconda installed on your machine:
         1. In terminal, create a new environment using command `conda create -n odsc-volatility python=3.6`.
         2. Hit "Yes" when prompted
         3. Activate environment using `source activate odsc-volatility`
         4. Install all required packages by running `pip install -r requirements.txt`
      2. If you do not have anaconda or prefer to work remotely:
         1. In the directory where you have cloned the seminar repository (ODSC/modeling-volatility), you will see a Jupyter notebook "Part_01_Loading_Currency_Data.ipynb"
         2. Open Google Chrome and go to <https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb>
         3. Click on "File" -> "Upload Notebook"
         4. Upload the notebook "Part_01_Loading_Currency_Data.ipynb" to colab
         5. You are ready to run your model from Colab.
      3. Loading the dataset:
         1. Run the notebook (from colab or locally in your terminal with command `jupyter notebook`. Make sure your current working directory is "ODSC/modeling-volatility")
         
1. Data ingestion: Reading in and visualizing currency data.
2. Time-series properties of data and currency baskets. DXY Index
3. Splitting the sample and saving some for out of sample testing. Basic validation.
   Metrics for success. define concept of a basic model and RMSE test.

4. Strategy 1:
   1. **Part 1** - Intro to Turbulence. Why it is used. Rough theory behind it. Choice of parameters. How to calculate.
   2. **Part 2** - Creating a model and metric of success: Dynamic asset allocation. mapping between signal and weight. Alternative metrics (correlation between w and retsq, RMSE). Role of benchmark and model bias. Role of insample vs out of sample (some of the pitfalls).

5. Strategy 2:
   1. **Part 1** - Introduction to GARCH Estimation: Why it is used. Theory behind it and estimation. p and q parameters, look back window. How to calculate
   2. **Part 2** - GARCH revisited: Forward estimation and challenges of multi-day estimation.

6. Strategy 3:
   1. **Part 1** - Naive machine learning: Linear only. Linear and squared.
   2. **Part 2** - Strategy 3+: Portfolio of models. Philosophy of models as securities in a portfolio. Simple just using outputs of models. More complex using models plus X, X^2. Weight normalization. 
