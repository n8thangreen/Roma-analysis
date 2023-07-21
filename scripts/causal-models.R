# g-computation
# marginal regression for ATE
# see
# J Consult Clin Psychol. 2014 October ; 82(5): 773–783. doi:10.1037/a0036515
# https://cran.r-project.org/web/packages/MatchIt/vignettes/estimating-effects.html#moderation-analysis:~:text=Ep1%20-%20Ep0.-,Moderation%20Analysis,-Moderation%20analysis%20involves
# https://ngreifer.github.io/blog/subgroup-analysis-psm/

library(MatchIt)

mP <- matchit(A ~ X1 + X2 + X5*X3 + X4 + 
                X5*X6 + X7 + X5*X8 + X9, data = d,
              exact = ~X5, method = "nearest")
mP

# matching for subgroup analysis, in general subgroup-specific matching

# matching in the full dataset

