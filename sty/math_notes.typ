#import "@local/yongfu:1.0.0": *
#show: Math

$
up(Y)_(i,j) & tilde "Bernoulli"(p) \
          p & = cases(
            (1 - S_j)^(z_i k)
            G_j^((1-z_i)k)
            (1 - gamma_j)^(1-k) & script("[type-1 & type-3 items]"), 

            (1 - S_j)^(z_i k)
            G_j^((1-z_i)k)
            gamma_j^(1-k)       & script("[type-2 & type-4 items]") , 
          ) \
          k & = cases( 
            "logit"^(-1)( D("Age"_i - delta_j) ) #h(48pt) & script("[type-1 & type-2 items]"),
            "logit"^(-1)( D(delta_j - "Age"_i) )          & script("[type-3 & type-4 items]"),
          ) \
\
& "[Priors]"\
 2 S_j, 2 G_j, 2 gamma_j &tilde "Beta"(2,2) #h(6pt) script("(" S_j"," G_j "," gamma_j in "[0,.5])")\
 z_i      &tilde "Bernoulli"(pi) \
// & pi       = .5 \
delta_j    & tilde "Normal"(0,20) \
D        & tilde "Expoential"(1)
$ <model-spec>

