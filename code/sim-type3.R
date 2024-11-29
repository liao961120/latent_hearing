'Simulate data for Type-3 items

Usage:
    this.R N_SUBJ SEED -o <o> 

Options:
    --output=<o> -o <o>  Output file path.
' -> doc

if (interactive()) {
    a = docopt::docopt(doc, args = list("170", "99", "-o", "made/m.train.RDS") )
} else {
    a = docopt::docopt(doc)
}
# print(a)
#############################################################################

OUTPUT = a$output

library(dplyr)
source("utils.R")

set.seed(as.integer(a$SEED))
################
##### Data #####
################
n_subj = as.integer(a$N_SUBJ)
age = runif(n_subj, min = 1, max=36)
gp = rep(1:2, each=n_subj/2)

#################
##### Param #####
#################
# Person parameters
z = ifelse(gp == 1, 1, 0)  # hearing loss

# Item parameters
set.seed(999) # same seed for item params
item_type = c( rep(-1,4),  rep(3,16) )   # Type-3
delta     = c( rep(-1,4),  3,  9,  9,  9,  9, 12, 12, 12, 15, 15, 15, 24, 24, 30, 30, 36 )
n_item    = length(item_type)
D         = 1    # discrimination
gamma = runif(n_item, 0, .3)
S     = runif(n_item, .35, .9)
G     = runif(n_item, .02, .4)

phi   = matrix(nrow=n_subj, ncol=n_item)
kk = c()
ss = c()
for (i in 1:n_subj) {
    for (j in 1:n_item) {
        tp = item_type[j]
        if (tp == -1)     k = 1                                    # Valid across all ages
        if (tp %in% 1:2 ) k = inv_logit( D *(age[i] - delta[j]) )  # Valid after delta
        if (tp %in% 3:4 ) k = inv_logit( D *(delta[j] - age[i]) )  # Valid before delta
        
        ss = c(ss,S[j])
        kk = c(kk,k)
        
        if (tp == -1)
            phi[i,j] = exp( z[i]*log(1-S[j]) + (1-z[i])*log(G[j]) )
        if (tp %in% c(1,3))
            phi[i,j] = exp( z[i]*k*log(1-S[j]) + (1-z[i])*k*log(G[j]) ) * (1-gamma[j])^(1-k)
        if (tp %in% c(2,4))
            phi[i,j] = exp( z[i]*k*log(1-S[j]) + (1-z[i])*k*log(G[j]) ) * gamma[j]^(1-k)
    }
}


########################
#### Item responses ####
########################
d = expand.grid(
    sid = 1:n_subj,
    iid = 1:n_item
)
d$gid = gp[d$sid]
d$Y = NA
for (idx in 1:nrow(d)) {
    i = d$sid[idx]
    j = d$iid[idx]
    g = d$gid[idx]
    
    d$Y[idx] = rbinom(1, 1, prob=phi[i,j])
}
z_obs = z


#####################
#### Save Output ####
#####################
dat = c(
    list(
        # Data
        n_obs          = nrow(d),
        n_subj         = n_subj,
        item_type      = item_type,
        n_item         = n_item,
        age            = age,
        gp             = gp,
        z_obs          = z_obs,
        # Param
        phi            = phi,
        Pi             = .5,
        z              = z,          # latent hearing condition 0,1
        gamma          = gamma,      # Person misfit [0~1]: 1-end is good fit
        S              = S,          # Slip
        G              = G,          # Guess
        D              = D,
        delta          = delta
    ),
    d
)
saveRDS(dat, OUTPUT)
