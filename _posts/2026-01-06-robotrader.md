---
layout: post
title:  Building a Neural Net To Trade Stocks For Fun And Profit
categories: [Data Analytics,Python,Finance,Trading,Neural Net,pytorch]
excerpt: 
---

Everyone knows it's hard to beat the market. For most people, the smart strategy is to park your savings in an index fund and forget about it. Definitely do not try and pick stocks based on fundamental value (continues the common wisdom), or god forbid technical analysis, which might as well be astrology for finance bros. The patterns, if they even exist, are too subtle, the counterparties too sophisticated - active trading is like donating your savings to the Help Ken Griffin Buy A Fourth Yacht Fund.

Buuuuut trading stocks is fun. Okay, there's no way that I, a mere mortal, can beat Citadel's army of math PhDs, but it still could be fun to try. Stock data is plentiful, and predicting stock prices is the gladiator's arena of data analysis - losing means going broke, but winning means wealth and glory. So here we go: let's build a robotrader!

For a complicated use case like stock trading, I don't want to use something like linear regression, which will miss any non-linear patterns in the data. So for this project, I'm going to train a neural net on a single stock and see if it can beat a basic benchmark - buying and holding that stock. My goal isn't day-trading, but rather capturing price movement over a few days to a month. So I'm just using the Daily Close data for the stock, which I'm grabbing using the yfinance API; but in theory it wouldn't be too difficult to adapt this to any time horizon. This is all going to be paper trading, of course. Please do not take any of this post or accompanying code as financial advice and lose all your money. 

### Part 1: The Data

Training a model on past financial data is tricky, because the trading environment evolves over time. Factors like interest rates, geopolitics, and new technologies like AI all have large impacts on the stock market, so a model trained in a zero-interest rate, low-growth period might faceplant today. Using only recent data avoids this problem; but if we only use very recent data, we won't have enough to train our model well.

To balance these considerations, we'll use 2020 - 2022 as training data, 2023 as validation, and 2024 - present as testing data. There's around 252 trading days a year, so this translates to about 756 data points in our training set - just good enough to be viable. It's important that we don't validate or test on data points that come before our training period, because that might contaminate our model.

As input data to our neural net, we'll use a set of technical indicators for the stock. Notwithstanding the astrology jab above, basing the input on technical indicators instead of raw price/volume data has a few advantages. First, these indicators will be normalized, so we can use them to get a predictable range of outputs for any ticker. Secondly, stock data is time series data - each data point is dependent on all the data points that come before it. Indicators, as you'll see in a moment, are typically a composite of several past data points. So by combining several indicators as inputs, we can encode not only the current price, but also the direction, volatility, and other information about recent price movement that might help the model make a more informed trading decision. We'll use five simple indicators for this project - you can click on the name of the indicator to learn more about it:

1. [**Percentage Price Oscillator.**](https://www.investopedia.com/articles/investing/051214/use-percentage-price-oscillator-elegant-indicator-picking-stocks.asp) A longer-term measure of momentum using the ratio of two exponential moving averages.

2. [**Simple Momentum**](https://www.fidelity.com/learning-center/trading-investing/technical-analysis/technical-indicator-guide/momentum-oscillator) N-day momentum is just the normalized change in price over the past n days. We'll use 5 day momentum here.

3. [**Aroon**](https://www.investopedia.com/ask/answers/112814/what-aroon-indicator-formula-and-how-indicator-calculated.asp) Okay, this is kind of an obscure one, but I think it's valuable. Aroon is a measure of how long it's been since the last high or last low, the idea being that past trends tend to continue into the future.

4. [**Money Flow Index**](https://www.investopedia.com/terms/m/mfi.asp) This is an indicator that incorporates volume. In short, it measures how much buying volume there was in the past vs selling volume. We'll use 30 day MFI here.

5. [**Volatility**](https://www.investopedia.com/terms/v/volatility.asp) Our final indicator will be volatility, which is just the standard deviation of closing price. We'll use the last 15 trading days for our window.

Why these five indicators? Between them of them, they comprise short- and long-term momentum, trend strength, volume, and volatility, which is hopefully a nice distillation of the stock data for our neural net. There are hundreds of technical indicators described on Wikipedia, and probably thousands more out there, so there's a lot of room to play around with other indicators in the future.

Here's my momentum indicator code as an illustrative example. It's quite straightforward using pandas. This code calculates the n-day momentum and adds it as a new column to the Closing Price DataFrame cp, then returns the modified DataFrame. Momentum is one of the simpler indicators, but none of them stretch past twenty lines of code.

![The momentum indicator code.](/images/robotrader/ind_ex.png)

Now what to use as the target for our neural net? We want to train our model to be long when the stock is going to go up, and short when the stock is going to go down. But stock prices are noisy - we are looking to capture medium-term trends, not day-to-day movements. So to construct our target, let's first calculate the daily return of the stock (i.e. how much the stock increases or decreases from the previous day's closing price, expressed as a percentage). Then, the target for each trading day will be the sum of the daily return for the following five days. Essentially, we'll train our model to be long when it thinks that the return for the next five days will be positive, and short when the return for the next five days will be negative. 

### Part 2: Braaiins!

Now it's time to build the actual neural net that will make our trading decisions. We want to keep it small enough not to overfit to the training data, yet still introduce enough complexity to capture any complex patterns. So we'll use a sequential neural net, alternating linear models with an activation layer until we get our final output - a single signal that will tell us whether to buy, sell, or do nothing. I ended up using this architecture for my neural net (using the pytorch API):

![The neural net architecture.](/images/robotrader/nn_arch.png)

Since we ended up with five indicators, we'll have five features as an input into the first neural net in the sequence.

For our loss function, we'll use Mean Square Error - this will allow us to get not just a positive or negative signal, but also signal strength. Our optimizer will be the efficient pytorch Adam algorithm. With that, we're ready to train.

Neural Nets love to overfit their data, so we have to be careful here. We'll initiate the evaluate -> backpropagation loop, which should start decreasing both training and validation error. We'll continue until the validation error starts creeping up again, although we have to be careful to not cut the training off too early either. Here's the full training loop:

![The neural net training loop.](/images/robotrader/train.png)

Then we just take our trained model and evaluate the testing data, making sure not to backpropagate this time:

![The neural net test function.](/images/robotrader/test.png)

Easy enough! Notice that although we built this to analyze stock data, it's completely agnostic to the type of data coming in. We could use this to predict pretty much anything, although this might not be the optimal architecture for many use cases.

To translate the output of the model into actual trades, we'll choose a threshold. Any outputs above that threshold, the model predicts will have positive return, and we'll go long. Any outputs more negative than the negative threshold (which is just the positive threshold * -1), we'll go short. If it's close to zero, we'll be neutral. I chose 0.25 for the threshold. Then, for each day, just add to our portfolio value the daily return * our position (which is either 1, 0, or -1 for long, neutral, or short respectively). We'll subtract 5 basis points as a transaction cost whenever we change our position. Then we just look at our ending value and see how we did.

It seems that our robotrader is alive! I think I will name him ... Goldman Stacks. I'm picturing C3PO sitting in front of three huge monitors filled with stock charts and quarterly earnings transcripts. How does the little guy perform on our test data?

### Part 3: The Robot Encounters The Real World

I tested the neural net on six large, commonly traded stocks across a few different industries, plus the S&P 500 index. There's an element of randomness to the neural net, so different runs resulted in different outputs. The data below is the average return if you started with $10,000 and followed the robotrader's trades, averaged over 100 runs. Here are the results:

| Ticker  | Average Goldman Stacks Return | Benchmark |
| ------  | ------------------------- | --------- |
|  MSFT  |  $3965.952  |  $2939.848  |
|  XOM  |  $5299.421  |  $3133.002  |
|  GLD  |  $1671.810  |  $11428.533  |
|  T  |  $3291.683  |  $5899.556  |
|  JPM  |  $4091.129  |  $10302.872 |
|  IT  |  $5491.391  |  $-4525.557 |
|  SPY  |  $3805.232  |  $4910.001  |

You win some, you lose some! Our robotrader beat the benchmark strategy of buy and hold for three of the six stocks. Not coincidentally, those three stocks were the ones where buying and holding yielded the lowest return. For GLD and JPM, just holding the stock for the last two years doubled your money! Poor Goldman Stacks couldn't compete.

But I'm happy with this result. Even if it didn't always beat the benchmark, Goldman Stacks never lost money on average, even on stocks like IT that lost value in the testing period.

Still, this shows just how hard it is to beat the market. The S&P grew by a whopping 49% over the two year testing period! Goldman Stacks did pretty well trading SPY, gaining 38%, but you would have been better off just buying and holding. Also, the data above is the average return over 100 runs, which was positive, but many of the individual runs did lose money. On average, Goldman Stacks made money, but in the real world, you only get one attempt, so if I had deployed him in the actual stock market, there's a good chance I would gotten unlucky and lost money. The real world does not care about averages.

### Part 4: Getting Beta At This

There's so much more to build on top of Goldman Stacks to improve him. Playing around with time horizons, the target function, the neural net architecture, and indicators all could yield better results. But even as it stands today, I think Goldman Stacks is pretty useful. He fails when the underlying stocks do so well that buying and holding is better; but in an environment where stocks trade down or sideways, Goldman Stacks does well. As I write this, SPY is near all-time highs and the words 'AI bubble' keep floating around, so it's quite possible that stocks may have a tougher year - the perfect environment for our little robotrader. Who knows, I may actually give Goldman Stacks a small allowance this year and see how he does in the real world!

If you want to check out the full codebase, or want to try it yourself, check out my [Github](https://github.com/shaunish/robotrader) or drop me a [line](mailto:shaunish.mookerji@gmail.com)!