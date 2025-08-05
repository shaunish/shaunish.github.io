---
layout: post
title:  Yahtzee Smarter With A Monte Carlo Simulation
categories: [Simulation,Data Analytics,Python]
excerpt: What's the best strategy for playing the game of Yahtzee? Let's find out, using the power of Python and statistics!
---

Yahtzee is a popular board game, which has existed in some form since the 1930s. It 
can be played with others, or as a solitaire game. The game consists of thirteen turns, and the 
objective of the game is to achieve the highest possible score. A full description of the rules can 
be found in the Main Findings section.  
There have been several papers and projects written on the subject of optimizing 
Yahtzee play: see for example Kelly & Liese (2022) and Woodward (2012). These works were 
not considered in writing this paper, as unfortunately they are behind a paywall. 
Main Findings: 
A full description of the rules of Yahtzee: 
The game consists of thirteen turns, and the objective of the game is to achieve the 
highest possible score. Each turn, the player rolls 5 dice. Then, they can choose which of the 
five dice to “hold”, rolling the remaining dice again. They repeat this process once more, rolling 
a total of three times per turn. Then, the player must choose one of the thirteen possible 
categories to score their dice. These are divided into an upper section and a lower section on 
the scoresheet. The upper section contains these six categories: 
Figure 1. Description of upper section categories. Screenshot from Wikipedia. 
If a player achieves a score of at least 63 in the upper section, they receive an additional 35 
point bonus.  
The lower section contains these plays: 
Figure 2. Description of lower section plays. Screenshot from Wikipedia. 
A player may choose a category even if their dice do not fulfill the requirements of that 
category and receive a score of zero. Once a player uses a category, they fill in the score box 
for that category and cannot use that category again in this game. However, if a player has 
already filled their “Yahtzee” box with a score of 50, if they later get another Yahtzee, then they 
get a Yahtzee bonus of 100 points, and then pick a separate category to fill in, as usual. 
Additionally, a Yahtzee can be used as a joker for the Full House, Large Straight, and Small 
Straight categories, if the Yahtzee box and the corresponding upper section box for the roll have 
already been filled in. For example, if a player rolls 5 threes, and they have already chosen the 
Yahtzee box earlier in the game, then they must choose the “Threes” category. If the “Threes” 
category has already been filled in, then they can choose any lower section category - they 
might choose, for example, the Large Straight category and receive 40 points.  
Code and strategy: 
The code written for this project implements the rules as written above in a Python script, 
and simulates a full game of Yahtzee, rolling dice each turn and choosing a category each turn 
until all categories have been chosen. Which dice are held, and which specific category is 
chosen for a given roll, are dependent upon the strategy employed. Three different strategies 
are simulated. Strategy 1 can be thought of as the “naive” strategy, which we can use as a 
baseline. The algorithm for Strategy 1 can be described as follows: 
1. Initial roll. 
2. If we haven’t played the Large Straight yet, check if we rolled a Large Straight. If we 
have, hold all dice. 
3. If we haven’t played the Small Straight yet, check if we rolled a Small Straight. If we 
have, hold the dice that form the Small Straight. 
4. If we don’t have a straight, or we have already played the straight categories, then count 
the dice, and hold any dice values that appear at least twice.  
5. Roll all dice that have not been held, and return to step 2. We get three rolls in total, so 
this step must be performed twice. 
6. Now, we have our final roll result. We must choose which category to fill in. For each 
category still to be played, we check what our score would be if we played that category. 
7. Then, we choose the category for which our score would be the highest. If there are 
more than one category that would yield the same highest score, then we choose one of 
those categories at random. 
8. We remove the chosen category from our available categories, add the score to our 
total, and begin our next turn. 
9. Return to step 1 and repeat until every category has been chosen. 
The algorithm is structured this way - first checking separately for straights, then 
checking for multiple dice - because there are essentially two “types” of scoring categories, 
straights and X of a kind. It is difficult to switch between them: if we start with a straight, then we 
are unlikely to end up with a high scoring X of a kind category, and vice versa. So we check 
which kind of roll we have, and accordingly decide which type of category to go for in 
subsequent rolls. 
Strategy 1 might be the way that a beginner might play Yahtzee. For the most part, it 
makes sense, yet there are some obvious mistakes that someone with more experience might 
not make. Strategy 2, what we might call the “smarter” strategy, attempts to avoid those 
mistakes. Namely: 
1. If there are multiple options for the highest scoring category, we should always choose 
the most difficult or rarest category, to minimize the chance that we later have to take a 
zero for that category. For example, if we roll four of a kind, then the categories Four of a 
Kind, Three of a Kind, and Chance will all yield the same score. Strategy 1 will choose 
one of these three at random, but we should always choose Four of a Kind. 
2. Always holding any dice that appear at least twice only makes sense if Full House is still 
an available category. Otherwise, even if multiple values of dice appear twice, we should 
only keep one. Furthermore, since many of the categories are scored based on the value 
of the dice, we should keep the higher value dice. For example, if we initially roll [5 5 4 4 
2], and we have played the Full House category earlier in the game, then we should only 
keep [5 5]. 
Strategy 2 implements both of these changes to the algorithm, which are clear and 
obvious improvements to Strategy 1. The amount of improvement to the score can be seen in 
the Results section.  
Strategy 3 (the “smartest” strategy) is exactly the same as Strategy 2, with one small 
tweak. Recall that the player receives a bonus of 35 points if the upper section score is at least 
63 at the end of the game. Strategy 3 attempts to increase the chance of receiving this bonus by 
automatically choosing the upper section category for four of a kind rolls with sixes, fives, or 
fours, assuming that the upper section category has not yet been played. 
Before running the simulation, it is unclear whether this is an improvement on Strategy 2. 
While this does increase the chance of an upper section bonus, it is easy to see that it will also 
lower the average score from the Four of a Kind category. 
Each strategy is run 100,000 times, and the mean and the variance of the scores of 
each strategy is captured.  

It is clear that Strategy 2 and Strategy 3 are a large improvement over Strategy 1. The 
number of upper section bonuses is also included in the table, and it is evident that Strategy 3 
does result in an increase in upper section bonuses. Strategy 3 resulted in 6.374% of the runs 
scoring the additional bonus, compared to 2.765% in Strategy 2. We might expect the score for 
Strategy 3 to then increase by an expected (35 points * (0.06374 - 0.02765)) = 1.26 points over 
Strategy 2; but this is an upper bound for the increase in score, as optimizing for a higher score 
in the upper section should lower the score in lower section categories. 
In fact, we can see that Strategy 3 results in a mean score that is 0.81013 higher than 
Strategy 2. Since the true distribution of scores is unknown (we can observe from the 
histograms below that scores are non-normal; they have a long, heavy right-tail and a light left 
tail), we can use a non-parametric test to determine if this result is statistically significant. The 
Mann-Whitney U test for independent samples was used to compare the scores from Strategy 2 
and Strategy 3 with an alpha value of 0.05, and the result was that Strategy 3 results in a higher 
score with a p-value of 0.036. Since this is below the chosen alpha value, we can conclude that 
Strategy 3 results in a small but statistically significant improvement in score. 
