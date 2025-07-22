
#let citet(citation) = { 
    cite(citation, form: "prose") 
}

#import "@preview/wordometer:0.1.4": word-count, total-words, total-characters

#show: word-count

// #show figure.where(
//   kind: table
// ): set figure.caption(position: top)
// 
// #show figure.where(
//   kind: image
// ): set figure.caption(position: top)

#show figure: set figure.caption(position: top)

// title 

#set page(
  // paper: "us-letter",
  /*
  header: align(
    right + horizon,
    title
  ),
  */
  numbering: "1",
  columns: 1,
)

#align(center, text(20pt, weight: "bold")[
  Housing precarity in precarious times
])

/*
#align(center)[
  #set par(justify: false)
  *Abstract* \
  
]

(#total-words words, #total-characters characters)
*/

= Introduction

// housing precarity
// energy crisis
Over the past few years, European households have faced multiple crises including the pandemic, inflation, and war in Ukraine. In response, European states implemented various measures in which social welfare systems played a major role. 
  
These crises are expected to primarily impact households' ability to cover housing costs, however, this study focuses on housing precarity as a more comprehensive concept that encompasses not only affordability challenges but also deteriorating housing quality to better understand how shocks translate into housing conditions.
  
In addition, while existing research on housing precarity largely relies on single case studies @waldron2023 @lombard2023 @listerborn2023, this paper offers a comparative perspective. Using EU-SILC survey data from nine European countries representing diverse housing regimes, welfare systems, and geographic regions (Western and Eastern Europe), this study pursues two objectives.
  
First, it analyses trends in housing precarity levels from 2013 to 2023. Preliminary data indicate that the crises have affected not only housing affordability as reflected by the rising share of households overburdened by housing costs but also contributed to decreasing housing quality (rising overcrowding, higher share of households living in a dwelling with leaks/dampness etc).
  
However, the European countries differ in their trajectories regarding housing precarity and the policy response to the crises. Therefore, the second aim of the paper is to examine how the selected European governments modified their welfare systems to address rising housing costs and evaluate the effectiveness of these interventions in reducing housing precarity.

= Housing precarity

Most of the research on housing precarity is descriptive as it focuses on defining it and measuring its dimensions. 
At best, some authors show which household attributes are associated with higher levels of housing precarity. 
For instance, #citet(<waldron2023>) shows that housing precarity is more prevalent among private renters with low-income, primary education and renters who are widowed, indebted and unable to save regularly.

There are various definitions of housing precarity, but all of them to some extent focus on similar aspects. 
First aspect concerns the affordability of housing. 
Second aspect concerns tenure security which is related to the extent of tenure rights and the risk of eviction or displacement. 
Third aspect concerns the quality of housing, which includes the physical condition of the dwelling. 
Final condition relates to the characteristics of the neighbourhood @clair2019 @waldron2023 @debrunner2024 @ong2022. 

The disagreement between different definitions of housing precarity stems from two main sources. 
First, the definitions differ in the number and extent of dimensions they include. For example, #citet(<debrunner2024>) include two dimensions 
related to neighbourhood characteristics - neighbourhood quality, which includes access to facilities in the neighbourhood and perception of safety from crime, and also community cohesion, which includes the extent of social ties and trust in the neighbourhood. 
Similarly, #citet(<ong2022>) also include two dimensions related to neighbourhood characteristics - its socioeconomic status and neighbourhood crime and hostility. 
Second, the definitons differ in the particular measures they use to operationalise the dimensions which is related to the data they use. 
One difference between the definitions is tendency to use objective or subjective measures. For instance, with regard to the affordability, #citet(<clair2019>) and #citet(<waldron2023>) use subjective measure (declaration of respondents whether the housing costs are a heavy burden), while #citet(<ong2022>) and #citet(<debrunner2024>) use objective measure as they consider the share of income spent on housing costs when evaluating affordability.

= Housing benefits

Housing benefits are financial support provided by governments to help individuals and families afford housing costs. 
They are viewed as a policy enabling households to live in decent housing conditions at a level that is affordable to them. In contrast to supply-side interventions to housing market such as rent control, housing benefits are designed as demand-side subsidies as they are distributed directly to households so that they can use them to pay for housing costs @griggs2012. 
The full-scale russian invasion to Ukraine and the following energy crisis has, however, highlighted that besides housing affordability, other housing conditions such as ability to heat the dwelling are also important. 
 
Using EU-SILC data, #citet(<griggs2012>) found that housing benefits are important from an income support perspective, as they decrease rent to income ratio and increase residual income after housing costs, thus making housing more affordable for recipients. 
However, the effects of housing benefits vary across countries. #citet(<griggs2012>) found that the effects vary depending on the welfare regime, but the variation is greater within welfare regimes than between them. 
Besides the welfare regime, the effects depend on the particular design of housing benefits. 
Furthermore, even when the benefit is generous, it will not lead to improving housing conditions if the households do not apply for it. 

// take-up: reasons for low take-up

// effects of housing benefits

// downsides of housing benefits: increasing rents, dependency on benefits, lower work intensity, higher unemployment

= Data

We use EU-SILC data to measure housing precarity and simulate eligibility to housing benefits and their effects on housing precarity. 
In particular, we use EU-SILC waves from 2012 to 2023 to show the time trends in housing precarity. 
The analysis of time trends focuses on eight/*nine*/ European countries that represent different welfare regimes and housing regimes. The countries included in the analysis are: Belgium, Czechia, Estonia, Finland, Germany, Italy, the Netherlands, and Romania. /*, their list is presented in @tab-countries.*/
Also, we use the 2023 EU-SILC data to estimate the effects of housing benefits on housing precarity. 

/*

#figure(
  [#table(
    columns: 4,
    fill: (x, y) => if y == 0 { gray },
    [*Country*], [*Region*], [*Welfare regime*], [*Housing regime*],
    [*Belgium*], [West Europe], [conservative], [dual],
    [*Czechia*], [East Europe], [post-communist], [],
    [*Estonia*], [East Europe], [post-communist], [],
    [*Finland*], [North Europe], [social-democratic], [dual],
    [*Germany*], [West Europe], [conservative], [integrated],
    [*Italy*], [South Europe], [conservative], [dual],
    [*Netherlands*], [West Europe], [conservative], [integrated],
    [*Romania*], [East Europe], [post-communist], [],
  ),
  #align(left, [_Sources:_ housing regimes @kemeny2006, welfare regimes @esping1990 @aidukaite2010])
  ], 
  caption: "Countries included in the analysis",
) <tab-countries>
*/

// how do we operationalise housing precarity?
=== Housing precarity indicators

We define housing precarity as a multidimensional concept that includes four dimensions: affordability, security, dwelling quality, and neighbourhood quality. In our operationalisation, we prefer indicators that are objective and included in more EU-SILC waves, which allows us to analyse time trends unlike @clair2019 who rely on the items from ad hoc module on housing. However, due to the data limitations, we do not include neighbourhood quality in the analysis of time trends as the questions related to neighbourhood quality are not included in the EU-SILC survey every year. Comparison with operations of other authors is presented in @precarity-indicators in Appendix.

// affordability
The affordability dimension is operationalised as housing overburden, which is defined as the share of households spending more than 40% of their disposable income on housing costs. Unlike Eurostat, we do not subtract housing allowances from both disposable income and housing costs when calculating housing overburden as the subtraction would not allow calculating the effect of housing benefits. In this regard, we use the same approach as #citet(<griggs2012>) who show rent-to-income ratio before and after housing benefits. For the impact of this choice on the housing overburden rate compare @fig-affordability and @overburden-app in Appendix.

// security
With regard to insecurity, we consider households suffering from housing insecurity as those that had arrears on mortgage or rent or arrears on utility bills in the past 12 months. 

// quality
The third dimension evaluates housing quality. For this we rely on two measures: overcrowding and ability to keep the dwelling warm. For the purpose of this paper, we consider households suffering from poor housing quality as those that either live in overcrowded dwelling (according to the Eurostat definition of overcrowding) or declare that they are unable to keep their dwelling warm. 

// neighbourhood quality
Finally, we measure neighbourhood quality dimension using three variables that capture problems in the neighbourhood: crime, pollution and noise. Here we consider poor neighbourhood quality as having problems at least in one of the three indicators. 

// To compare our approach of defining housing precarity, see @precarity-indicators in Appendix. 

= Results

== Trends in housing precarity

Trends in housing precarity are presented in @fig-precarity which shows the share of housholds in housing precarity by its depth. The Figure shows that there is not a single trend in housing precarity across the selected countries. Instead, the countries vary in their trajectories with post-communist countries (Czechia, Romania and partly also Estonia) experiencing decrease in housing precarity in the 2010s which reversed in 2022. In Finland, housing precarity also slightly increased in 2022 and 2023. The Netherlands recorded a sharp increase in housing precarity in 2022 due to the rise in energy costs which then dropped as is evidenced also by @fig-affordability which shows housing affordability. In contrast, Belgium and Germany have a stable level of housing precarity, while Italy experienced a steady decrease in housing precarity.

Besides the number of households in housing precarity, @fig-precarity also shows that the increase in the share of households in housing precarity is also associated with increasing depth of housing precarity. When some people move to housing precarity, others move deeper into housing precarity. 

#figure(
  [#image("figs/precarity_dimensions_selected.png", width: 80%)
  #align(left, [_Note:_ EU-SILC does not contain number of available rooms for Germany (2015-2019), thus it is not possible to calculate overcrowding rate.])
  ],
  caption: [
    Housing precarity in time
  ]
) <fig-precarity>


#figure(
  [#image("figs/fig_dim_affordability.png", width: 80%)
  // #align(left, [_Note:_ Data on housing allowances are missing in Finland (2012-2020), Germany (2020-2021) and the Netherlands (2012-2020).])
  ],
  caption: [
    Housing affordability - share of households spending more than 40% of their income on housing costs
  ]
) <fig-affordability>

@fig-insecurity shows the share of households in housing insecurity, that is the households who had arrears on mortgage or rent or arrears on utility bills. Besides the overall insecurity, the figure also shows the constituent parts of the dimension. The chart indicates that arrears on mortgage or rent are correlated with arrears on utility bills. 

#figure(
  [#image("figs/fig_dim_insecurity.png", width: 80%)
  // #align(left, [_Note:_ Data on housing allowances are missing in Finland (2012-2020), Germany (2020-2021) and the Netherlands (2012-2020).])
  ],
  caption: [
    Housing insecurity - share of households with arrears on mortgage, rent or utility
  ]
) <fig-insecurity>

Finally, @fig-quality shows the quality dimension of housing precarity. It shows the share of households with poor quality of housing, which are households living in overcrowded dwellings or unable to keep the dwelling warm, but it also shows the constituent parts of the quality dimension. 

#figure(
  [#image("figs/fig_dim_quality.png", width: 80%)
  // #align(left, [_Note:_ Data on housing allowances are missing in Finland (2012-2020), Germany (2020-2021) and the Netherlands (2012-2020).])
  ],
  caption: [
    Housing quality - share of households in overcrowded dwelling, unable to keep the dwelling warm
  ]
) <fig-quality>

// descriptive stats
// with current take-up vs. with full take-up
== What predicts housing precarity? 

Next we examine which household characteristics are associated with housing precarity and its dimensions according to the 2023 EU-SILC data. The results shown in @tab-all-models indicate that the effects of characteristics may vary when considering overall housing precarity or only a single dimension of precarity such as unaffordability, insecurity or poor housing quality. 
Only quantiles of equivalised income have the same effect across housing precarity and all dimensions as the higher quantile is associated with lower probability of housing precarity, unaffordability, insecurity, and poor housing quality. 

Tenure status also has mostly consistent effects across all dimensions with owners with outstanding mortgage and tenants with market and reduced rent have higher probability of housing precarity and its dimensions than owners without outstanding mortgage. 
The only exception are tenants whose accommodation is provied rent-free who are slightly more likely to be in housing precarity than owners without mortgage. At the same time, they are less likely to suffer from housing unaffordability and more likely to live in poor housing conditions. 

// Age 
// Econ. status
Concerning age of the head of the household, younger age is associated with higher probability of housing precarity, but it varies with regard to particular dimensions. Younger households are more likely to be in unaffordable and poor quality housing, but they are less likely to be insecure than households with middle-aged heads. The position of younger households may also complicate the fact that the households whose head is neither employed nor retired (Economic status: Other, that is students, unemployed, etc.) are more likely to be precarious.  
In contrast, older households are less likely to be precarious. Also, being retired is associated with lower probability of unaffordability. 

// HH type
The composition of household also affects housing precarity. The type of household least affected by housing precarity is a household composed of several adults, all other types of housholds (adults with children, lone parent or lone adult) are more likely to be precarious. Curiously, adults with children are less likely to suffer from unaffordability, but they are more likely to be insecure and live in poor quality of housing, possibly due to overcrowding of their households. 

// dwelling type
The same applies to households living in flats - they are more likely to be precarious and live in poor housing quality, but less likely to live in unaffordable dwelling than households living in detached house. Households living in semi-detached houses are also less likely to live in unaffordable housing, but their housing is more likely to be of poor quality. However, their housing precarity is not statistically distinguishable from households living in detached houses. 

Finally, the models also include variable capturing whether the dwelling was renovated in the past 5 years. The results show that renovation is associated with slightly lower housing precarity. When looking at the models explaining particular dimensions, the models show that renovation have only statistically significant effect in the model explaining poor housing quality - renovation is associated with lower probability of poor housing quality indicating the the households were more likely to keep their dwelling warm because of the renovation. In contrast, the respondents who do not know if the dwelling was renovated are more likely to be in housing precarity. 
In the public policy debates, it is argued that there is a trade-off with regard to renovations. They can improve insulation of the dwelling and reduce energy costs, but at the same time they may contribute to rising rents and thus unaffordability. To test whether, the effects of renovation differs between owners and tenants we estimated models with an interaction between tenure status and renovation. The results are presented in the Appendix in @app-tab-interaction and Figures 7-10 which do not indicate that the renovations would increase unaffordability among the tenants.
However, the effects of renovation vary across countries (see Tables 2-9 in the Appendix). In the case of Czechia and Germany, living in a renovated dwelling is associated with higher probability of unaffordability. 

#include "tabs/all_models.typ"

== Effect of housing benefits on housing precarity

To estimate the effect of housing benefits on housing precarity, we simulate the eligibility to housing benefits. The details on eligibility to housing benefits and the calculation of housing benefits were sourced from EUROMOD country reports. Based on the simulation, we can compare the households that are eligible to housing benefits and receive the benefits with those that are eligible but do not receive the benefits. Then we match the recipients with non-recipients based on the amount of housing benefits the households are eligible for.  

The matching is done using `MatchIt` R package @matchit using take up of housing benefits as the treatment and the amount household is eligible to, composition of the household, disposable income before housing benefits, region, tenure status as covariates. 

=== Czech Republic

So far, we have only matching done for the Czech Republic. The covariates balance is shown in @app-cze-covars in Appendix. 

Based on the matched data, we then estimate the effect of housing benefit on individual dimensions and indicators of housing precarity. The results are shown in @matching-models. Concerning dimensions of housing precarity, the models indicate that only in the case of affordability taking benefits improve the situation of the households by increasing affordability. In the case of insecurity and quality, the models show no statistically significant effect. The same holds true for most of the indicators such as arrears on mortgage or rent, arrears on utilities and overcrowding. Only in the case of ability to keep warm the model has the opposite effect than expected, as the households taking benefits are less likely to declare that they are able to keep their dwelling warm. This suggest that despite matching the data, there is some self-selection of the households into recipients and non-recipients. 

// matching

#figure(
  [#table(
    columns: 8,
    stroke: none,
    fill: (x, y) => if y == 0 { gray },
    [], [*Unafford-ability*], [*Insecurity*], [*Poor quality*], 
    [*Arrears on mortgage/rent*], [*Arrears on utilities*], [*Over-crowding*], [*Able to keep warm*],
    table.cell(rowspan: 2, [Intercept]), [0.79+],	[-3.72\*\*\*], [-1.50\*\*\*],	[-4.10\*\*\*],	[5.35\*\*\*],	[-2.96\*\*\*],	[0.92\*],
    [(0.44)],	[(0.48)],	[(0.28)],	[(0.52)],	[(0.78)],	[(0.33)],	[(0.36)],
    table.cell(rowspan: 2, [Taking benefits]),	[-0.75\*],	[-0.02],	[0.26],	[-0.07],	[-0.03],	[-0.18],	[-0.73\*\*],
    [(0.30)],	[(0.33)],	[(0.20)],	[(0.36)],	[(0.55)],	[(0.23)],	[(0.25)],
    table.cell(rowspan: 2, [Amount of benefits eligible for]),	[0.31\*\*\*],	[0.08\*\*\*],	[0.05\*\*\*],	[0.09\*\*\*],	[-0.08\*\*\*],	[0.08\*\*\*],	[0.01],
    [(0.03)],	[(0.01)],	[(0.01)],	[(0.01)],	[(0.02)],	[(0.01)],	[(0.01)],
    table.cell(rowspan: 2, [Disposable income without benefits]),	[-0.00\*\*\*],	[0.00],	[0.00\*\*],	[0.00],	[-0.00+],	[0.00\*\*\*],	[0.00\*\*],
    [(0.00)],	[(0.00)],	[(0.00)],	[(0.00)],	[(0.00)],	[(0.00)],	[(0.00)],
    table.hline(),
    [N],	[496],	[496],	[496], [496],	[496], [496], [496],
    [pseudo-R2],	[0.54],	[0.12],	[0.04],	[0.13],	[0.11],	[0.11],	[0.05]

  )
  #align(left, [_Note:_ + p < 0.1, \* p < 0.05, \*\* p < 0.01, \*\*\* p < 0.001])
  ],
  caption: "Results of regressions on matched data",
) <matching-models>

/*
*/

= Discussion

This paper highlights three issues:

1. Housing precarity increased during few last years due to effects of energy crisis following the Russian full-scale invasion to Ukraine. In some countries, this reversed the trend of decreasing housing precarity. 

2. Trade-offs exist. The results of regression models explaining housing precarity and its dimension indicate that the same characteristics may have different effects across dimensions. 

3. The effects of housing benefits are limited and may decrease housing precarity only partly through increasing affordability as the eligibility is based on the ratio between housing costs and income. 


#bibliography("literature.bib", style: "apa")


= Appendix

== Comparison of housing precarity indicators

#show figure: set block(breakable: true)

#figure(
  [#table(
    columns: 4,
    // fill: (x, y) => if y == 0 { gray },
    [*#citet(<clair2019>)*], [*#citet(<waldron2023>)*], [*#citet(<debrunner2024>)*], [*#citet(<ong2022>)*],
    //
    [*affordability*: housing costs are a heavy burden], [*affordability*: housing costs are a heavy burden], [*affordability*: more than 30% of income spent on housing], [*affordability*: more than 30% of income spent on housing and equivalised disposable income is in the lowest 40% of the income distribution], 
    //
    [*security* (1/2): had to move in the past 5 years due to eviction or landlord did not renew the contract or will have to move in the next year], 
    [*security*: rent arrears in last 12 months; crime, violence, or vandalism in the area], 
    [*security*: concern of involuntary relocation in the next 5 years], 
    [*forced move*: had to move because of eviction or property no longer being available], 
    //
    [*quality* (at least 2 out of 6): ability to keep the home adequately warm/cool; bath/shower in the dwelling; toilet in the dwelling; leaks/dampness; overcrowding],
    [*quality* (at least 2 out of 5): leaks/dampness; rooms insufficiently lit; pollution or environmental problems in the area; presence of central heating],
    [*housing satisfaction*: satisfaction with appartment; satisfaction with the location of appartment; satisfaction with neighbourhood; satisfaction with housing costs],
    [*housing quality*: overcrowding],
    //
    [*access to services* (at least 3/5): ability to access banking, postal, transport, grocery and healthcare services],
    [*financial capacity*: making ends meet is difficult; unable to afford unexpected expenses],
    [*neighbourhood quality*: access to community facilities; safety when walking on the street; trust in people in neighbourhood; perception of crime in the neighbourhood; perception of police protection],
    [*neighbourhood socio-economic status*], 
    //
    [], [], 
    [*community cohesion*: spending free time in neighbourhood; participation in volunteer work; participation in volunteer work; help in fixing a problem; importance of working within the neighbourhood; friend relationships; family in neighbourhood; getting help from friends and/or family; help with occasional childcare; visiting people in the neighbourhood; meeting friends and acquaintances when shopping; have done a favour to someone in neighbourhood; perceived connection to neighbourhood; perceived connectedness of family life with neighbourhood; perceived connectedness of the circle of friends with neighbourhood; years lived in the appartment/house], 
    [*neighbourhood crime and hostility*], 
    table.hline(),
    table.cell(colspan: 4, [*Who is in housing precarity?*]),
    [households with score 1 and higher on sum index 0-4 where each dimension can contribute 1], 
    [households with score 1 and higher on sum index 0-6 (rescaled to 0-1) where affordability and housing quality are composed of 1 indicator and security and financial capacity of 2 indicators], 
    [analyse dimensions separately], 
    [above 75th percentile of precarity index (sum index 0-6 where each dimension can contribute 1)]
  )],
  caption: "Indicators of housing precarity by various authors",
) <precarity-indicators>


== Matching overview

=== Czech Republic

#figure(
  [#image("figs/cze-covars.png", width: 80%)
  ],
  caption: [
    Covariates balance
  ]
) <app-cze-covars>


== Robustness checks

// housing overburden
=== Housing overburden according to Eurostat methodology

#figure(
  [#image("figs/fig_dim_affordability_eurostat.png", width: 80%)
  #align(left, [_Note:_ Data on housing allowances are missing in Finland (2012-2020), Germany (2020-2021) and the Netherlands (2012-2020).])
  ],
  caption: [
    Housing overburden according to Eurostat methodology
  ]
) <overburden-app>

=== Models of housing precarity

#include "tabs/be_models.typ"

#include "tabs/cz_models.typ"

#include "tabs/de_models.typ"

#include "tabs/ee_models.typ"

#include "tabs/fi_models.typ"

#include "tabs/it_models.typ"

#include "tabs/nl_models.typ"

#include "tabs/ro_models.typ"

==== Interaction between tenure status and renovation

#include "tabs/all_models_interaction.typ"

#figure(
  [#image("figs/pp_all.png")
  ],
  caption: [
    Predicted probability of housing precarity
  ]
) <pp-all-app>

#figure(
  [#image("figs/pp_affordability.png")
  ],
  caption: [
    Predicted probability of housing unaffordability
  ]
) <pp-aff-app>

#figure(
  [#image("figs/pp_insecurity.png")
  ],
  caption: [
    Predicted probability of housing insecurity
  ]
) <pp-ins-app>

#figure(
  [#image("figs/pp_quality.png")
  ],
  caption: [
    Predicted probability of low housing quality
  ]
) <pp-qual-app>

// how much calculated benefits differ from actual benefits

