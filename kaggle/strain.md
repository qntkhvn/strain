**STRAIN: Sacks, Tackles, Rushing, and Aggression INdex**

*When American football meets materials science*

---

# Introduction

What is considered a success for a pass-rusher on a pass play?
The simplest answer to this question is a sack.
In terms of tracking data, one can think of a sack as reducing the distance between the pass-rusher and quarterback to 0.
More generally, a good starting point for a continuous measure of pass-rushing effectiveness should be based on the **distance** between the rusher and quarterback, with smaller distances indicating greater success.
However, this naive approach has major drawbacks.
Consider the case where a rusher is within two yards of the quarterback, but is then stopped and fails to get any closer for the rest of the play.
This is not a successful rush because the pass-rusher is not continuing to reduce their distance to the quarterback.
Thus, another approach for pass-rushing assessment is to measure the **rate** at which the rusher is getting to the quarterback.
Yet, the rate by itself is also inadequate.
If a defender is 50 yards away and moving towards the quarterback, their moving rate is essentially unimportant due to a significantly far distance.

Therefore, in order to appropriately evaluate rusher performance, the **distance** from the quarterback *and* the **rate** at which this distance is being reduced must both be considered.
We propose **STRAIN**, a new measure for pass-rusher effectiveness, which is computed as the ratio of the aforementioned moving rate and distance quantities.
Our proposed metric has a nice interpretation and is inspired by the concept of "strain rate" in materials science.

# Strain rate in materials science

In [*materials science*](https://en.wikipedia.org/wiki/Materials_science), [*strain*](https://en.wikipedia.org/wiki/Strain_(materials_science)) is the deformation of a material from stress.
The stretching of a rubber band is an example of strain: the longer the stretch, the larger the strain.
Formally, let $L(t)$ be the distance between two points of interest at time $t$, and $L_0$ be the initial distance between those two points.
Then the strain at time $t$ is defined as $\displaystyle s(t)={\frac  {L(t)-L_{0}}{L_{0}}}$.
Notice that this measure is unitless as a ratio of two quantities having the same dimension.
Furthermore, the [*strain rate*](https://en.wikipedia.org/wiki/Strain_rate) is the derivative of strain.
That is, ${\displaystyle {{s}'}(t)={\frac {ds}{dt}} = {\frac {v(t)}{L_{0}}}}$, where $v(t)$ is the rate at which the two points of interest are moving away from/towards each other.
Whereas strain is unitless, the strain rate is measured in inverse of time, usually $\text{seconds}^{-1}$.

# Application to pass-rushing in football

Motivated by its scientific definition, we draw an analogy between strain and pass-rushing in football.
**Just as strain rate is a measure of deformation in materials science, a pass-rusher's efforts involve the application of force/deformation against the offensive line, with the ultimate goal of breaking through the protection to reach the quarterback.
The players can be viewed as "particles" in some material and the defensive "particles" are attempting to exert pressure on the pocket with the aim of compressing and collapsing this pocket around the quarterback.**

In order to apply strain rate to measure NFL pass-rusher effectiveness, we make modifications to how this concept is traditionally defined.

Let $(x_{ijt}, y_{ijt})$ be the $(x, y)$ location on the field of player $j = 1, \cdots, J$ at frame $t = 1, \cdots, T_i$ for play $i = 1, \cdots, n$; and $(x^{QB}_{it}, y^{QB}_{it})$ be the $(x, y)$ location of the quarterback at frame $t$ during play $i$.

* The distance between player $j$ and the quarterback at frame $t$ during play $i$ is $f_{d_{ij}}(t) = \sqrt{(x_{ijt} - x^{QB}_{it})^2 + (y_{ijt} - y^{QB}_{it})^2}$.
* The rate at which player $j$ is moving towards the quarterback at frame $t$ during play $i$ is $\displaystyle f'_{d_{ij}}(t) = \frac{df_{d_{ij}}(t)}{dt}$.
* The STRAIN for player $j$ at frame $t$ during play $i$ is 

$$\text{STRAIN}_{ij}(t) = \frac{-f'_{d_{ij}}(t)}{f_{d_{ij}}(t)} \,.$$

(*Note that to distinguish our metric from strain and strain rate in materials science, we write it in capital letters* (STRAIN) *for the remainder of this report.*)

Recall that by its materials science property, strain is generally defined to increase as the distance between two points **increases**.
In our football setting, the two points of interest are the pass-rusher and the quarterback, and we want our metric to increase as the distance between the pass-rusher and the quarterback **decreases**.
Thus, the negative sign in the numerator of our formula accounts for this. 
Additionally, rather than keeping the initial distance ($L_0$ as previously denoted) between two points constant over time, we update the initial position to be the player locations at the beginning of each frame.
This effectively gives us the STRAIN for each frame throughout a play.

Since we only observe these functions discretely in increments of 10 frames/second, an estimate for our proposed metric STRAIN is 

$$\widehat{\text{STRAIN}}_{ij}(t) = \cfrac{-\cfrac{f_{d_{ij}}(t) - f_{d_{ij}}(t - 1)}{0.1}}{f_{d_{ij}}(t)} \,.$$

Notice that this quantity increases in two ways: 1) the rate at which the rusher is moving towards the quarterback increases, and 2) the distance between the rusher and the quarterback gets smaller.
Both of these are indications of pass-rusher effectiveness.
Finally, our statistic STRAIN is measured in inverse seconds, similar to strain rate.
(There is also an interesting interpretation of the reciprocal of our metric, namely, the amount of time required for the rusher to get to the quarterback at the current location and rate at any given time $t$.)
 

# Analysis

In the forthcoming analysis, we rely on the provided data of all passing plays from the first 8 weeks of the 2021 NFL season.
We include only the frames between the ball snap and when a pass forward or QB sack is recorded for each play.
We also remove all plays with multiple quarterbacks on the field, since we need a uniquely defined quarterback to calculate our measure.
Using PFF scouting data, we only consider defenders with role "Pass rush" for evaluation.

## Example play

To illustrate STRAIN for pass-rusher evaluation, we used a play from the 2018 NFL regular season week 6 matchup between the Las Vegas Raiders and Denver Broncos, which ended with [Broncos QB Teddy Bridgewater getting sacked by Raiders DE Maxx Crosby](https://www.raiders.com/video/de-maxx-crosby-sacks-qb-teddy-bridgewater-for-a-loss-of-6-yards-nfl).
The figure below consists of two elements:
at top, the locations of every Las Vegas (black) and Denver (orange) player on the field during the play, with Maxx Crosby highlighted in blue;
and at bottom, a line graph showing how Crosby's distance from the QB, velocity, and STRAIN change continuously throughout the play.
Note that the point size for each Las Vegas defender corresponds to the estimated STRAIN in each frame as the play progresses.

For the first 2.5 seconds, Crosby is being covered by a Denver player and unable to get close to the quarterback, hence the corresponding STRAIN values are virtually zero.
Suddenly, the STRAIN increases after Crosby is freed up and charges towards Bridgewater.
At 4 seconds after the snap, Crosby's STRAIN is 2.30, which means at his current moving rate, it will take Crosby about 0.43 (1/2.30) seconds to make the distance between him and the quarterback 0 (i.e. essentially sack the quarterback).
This is consistent with the final outcome of the play, as the sack takes place at the very last frame (4.4 seconds) where the estimated STRAIN for Crosby reaches its peak at 3.96.

<center>
<img src="https://raw.githubusercontent.com/qntkhvn/strain/main/figures/example_play.gif" width="650" height="1200">
</center>

## Positional STRAIN curves

The following plot displays the average STRAIN by position for the first 40 frames (4 seconds) after the snap.
We observe a clear difference in STRAIN between edge rushers (OLB's and DE's) and interior linemen (DT's and NT's).
Specifically, edge rushers have higher STRAIN than interior linemen on average, as they are more easily able to approach the quarterback on the edge of the pocket versus, for instance, a nose tackle attacking the line head on.

For an average player, STRAIN increases for the first 0.5 seconds of a play, followed by a decline in the next second.
STRAIN then increases again until around 2.5-3 seconds after the snap before trending down towards the end of the play.
In context, this means a pass-rusher initially moves towards the quarterback, but is then stopped by the offensive line while the quarterback drops back.
When the quarterback stops dropping, the rusher closes the gap and increases STRAIN, before slowing down later on.

<center>
<img src="https://raw.githubusercontent.com/qntkhvn/strain/main/figures/position_curves.png" width="500" height="500">
</center>


## Ranking the best pass-rushers

To determine the most effective pass-rushers, we aggregate and average across all frames played to get the expected STRAIN (**xSTRAIN**) for each player.
Based on the clearly distinct patterns for different positions as previously observed, we evaluate interior pass-rushers (NT's and DT's) separately from edge rushers (OLB's and DE's).
The following tables show the top performing pass-rushers (with at least 100 plays) rated by **xSTRAIN** for the first 8 weeks of the 2021 season.

Our results show many true positives with no surprises.
Myles Garrett and TJ Watt are known as top-tier edge rushers, while Aaron Donald is undoubtedly the best interior defender in football.
Rashan Gary, a young rusher with huge potential, ranks first among all pass-rushers according to our metric.
Our rankings largely match the rankings of experts in the field (for instance, PFF's [edge](https://www.pff.com/news/nfl-2022-edge-rusher-rankings-tiers) and [interior](https://www.pff.com/news/nfl-interior-defensive-line-rankings-tiers-2022) rusher rankings after the 2021 season), lending credibility to our proposed metric as a measure of pass-rushing effectiveness.

<center>
<img src="https://raw.githubusercontent.com/qntkhvn/strain/main/figures/player_rankings.png" width="900" height="1800">
</center>

# Discussion

We have proposed STRAIN, a simple and interpretable statistic for evaluating pass-rushers, with higher STRAIN corresponds to greater pass-rushing ability.
Compared to existing metrics such as [ESPN's Pass Rusher Win Rate (PRWR)](https://www.espn.com/nfl/story/_/id/24892208), STRAIN measures pass-rush effectiveness for every play continuously over time, which is at a much more granular level than simply whether the play resulted in a sack or whether the play was a "success".

As for future directions, STRAIN could be utilized to collectively evaluate the performance of a pass-rushing unit by considering the total amount of STRAIN during a play, which could, in turn, be used to examine the effectiveness of different types of blitzes.
Moreover, while we focused solely on pass-rushers, STRAIN can be easily extended to assessing pass-blockers *as a unit* by simply looking at a quantity such as the total STRAIN or the maximum STRAIN per frame aggregated across the entire play.
It is also possible to apply STRAIN to assess individual offensive pass-blockers, provided that a method of matching blockers to rushers was developed.

Our metric, however, is subject to several limitations.
As currently devised, STRAIN cannot distinguish between a pass-rusher who has to face a single blocker versus a double team.
This problem could be addressed, at least somewhat, by having a method of matching pass-rushers to blockers as previously mentioned.
There are a few situations such as quarterback out-of-pocket scrambling where STRAIN does not appear to be useful.
If a pass-rusher is on the left side and the quarterback scrambles out to the left, the STRAIN for that pass-rusher can drop considerably as the distance between the quarterback and pass-rusher increases, which the defender should not necessarily be negatively affected by in a measure of pass-rushing effectiveness.

# Appendix

All code is available at https://github.com/qntkhvn/strain.

<br>

---

[Gregory J. Matthews](https://github.com/gjm112)<br>Loyola University Chicago

[Quang Nguyen](https://github.com/qntkhvn)<br>Carnegie Mellon University
