'Validate Model with Simulated Data

Usage:
    this.R STAN TRAIN TEST -o <o>

Options:
    --output=<o> -o <o>  Output file path.
' -> doc

if (interactive()) {
    a = docopt::docopt(doc, args = list("model.stan", 
                                        "made/train.RDS",
                                        "made/test.RDS", 
                                        "-o", "made/fit.RDS") )
} else {
    a = docopt::docopt(doc)
}
# print(a)
#############################################################################


# Rscript model.stan fit.R made/train.RDS test.RDS -o fit.RDS
####################
##### Diagnose #####
####################
library(dplyr)

# Prepare data
dat1 = readRDS(a$TRAIN)
dat2 = readRDS(a$TEST)
dat = c(
    dat1,
    list(
        n_obs2  = dat2$n_obs,
        n_subj2 = dat2$n_subj,
        age2    = dat2$age,
        sid2    = dat2$sid,
        iid2    = dat2$iid,
        Y2      = dat2$Y
    )
)


# Fit model
n_chains = 4
n_item = dat$n_item
n_subj = dat$n_subj
n_item_types = dat$n_item_types
write_init_files = function(dir="init", chains=1:n_chains) {
    sapply( chains, function(chain) {
        init = tibble::lst(
            Pi = .5,
            # DCM pars
            S = rbeta(n_item,2,2),
            G = rbeta(n_item,2,2),
            gamma_raw = rbeta(n_item,2,2),
            # Age pars
            D = runif(1, .5, 2),
            delta = rnorm(n_item, 10, 15),
            delta_raw = rnorm(n_item, 10, 15)
        )
        dir.create(dir, showWarnings = F)
        fp = file.path(dir, paste0(chain,".json") )
        cmdstanr::write_stan_json(init, fp)
        fp
    })
}
set.seed(50)
m = cmdstanr::cmdstan_model(a$STAN)
fit = m$sample(data = dat, chains = n_chains, parallel_chains = n_chains,
               iter_warmup = 800, iter_sampling = 300,
               save_warmup = TRUE, refresh = 200,
               init = write_init_files(),
               show_messages = T
)
fit$save_object(a$output)
