data {
    int n_obs;
    int n_subj;
    int n_item;
    array[n_item] int<lower=-1,upper=4> item_type;
    vector[n_subj] age;
    array[n_subj] int<lower=-1,upper=1> z_obs;   // partially observed z status. -1:Unknown / 0:Typical Hearing / 1:Hearing Loss
    array[n_obs] int sid;
    array[n_obs] int iid;
    array[n_obs] int Y;
    real<lower=0,upper=1> Pi;  // fixed to .5
    
    // Prediction on new data
    int n_obs2;
    int n_subj2;
    vector[n_subj2] age2;
    array[n_obs2] int sid2;
    array[n_obs2] int iid2;
    array[n_obs2] int Y2;
}
transformed data {
    real mu_age = mean(age);
    real max_age = max(age);

    // Dummy variables depending on item types
    vector[n_item] g;
    vector[n_item] k_rev;
    for (i in 1:n_item) {
        int tp = item_type[i];
        if (tp == 1 || tp == 3)
            g[i] = 1;
        else
            g[i] = 0;
        if (tp == 1 || tp == 2)
            k_rev[i] = 1;
        else
            k_rev[i] = -1;
    }
}
parameters {
    // Item parameters
    vector<lower=0,upper=1>[n_item] gamma_raw;
    vector<lower=0,upper=1>[n_item] S;
    vector<lower=0,upper=1>[n_item] G;
    // Item age parameters
    real<lower=0> D;        // discrimination
    vector[n_item] delta;   // age thresholds
}
transformed parameters {
    vector[n_item] gamma = .5*gamma_raw;
    matrix[n_obs,2] logM;
    {   
        array[2] matrix[n_subj,n_item] phi;
        real lpi = log(Pi);
        real l1mpi = log1m(Pi);

        for (idx in 1:n_obs) {
            int i = sid[idx];
            int j = iid[idx];
            real k = inv_logit( k_rev[j] * D *(age[i] - delta[j]) );
            real lg = lmultiply(1-k, g[j]*(1-gamma[j]) + (1-g[j])*gamma[j]); // x log(y) / (1-k)*log(gamma[j])
            if (item_type[j] == -1) {
                k = 1;
                lg = 0;
            }
            // Likelihood under different z
            for (w in 1:2) {
                real z = 1;
                if (w == 2) z = 0;
                phi[w,i,j] = exp( z*k*log1m(S[j]) + (1-z)*k*log(G[j]) + lg);
            }
            
            // Marginalized log prob
            int zo = z_obs[i];
            if (zo == -1) {
                logM[idx,1] = bernoulli_lpmf(Y[idx] | phi[1,i,j]) + lpi  ; // P(Y|z=1)
                logM[idx,2] = bernoulli_lpmf(Y[idx] | phi[2,i,j]) + l1mpi; // P(Y|z=0)
            } else if (zo == 1) {
                logM[idx,1] = bernoulli_lpmf(Y[idx] | phi[1,i,j]); // P(Y|z=1)
                logM[idx,2] = log(0);                              // P(Y|z=0)
            } else {
                logM[idx,1] = log(0);                              // P(Y|z=1)
                logM[idx,2] = bernoulli_lpmf(Y[idx] | phi[2,i,j]); // P(Y|z=0)
            }
        }
    }
}
model {
    // Prior
    S ~ beta(2,2);
    G ~ beta(2,2);
    gamma_raw ~ beta(2,2);                 // gamma constrained to [0, .5]
    D ~ exponential(1);
    delta ~ normal(max_age/2, max_age/4);  // prior for LPC_3~6 stage 2 data

    // Mixture
    for (idx in 1:n_obs)
        target += log_sum_exp(logM[idx,]);
}
generated quantities {
    vector[n_subj] Pz;
    vector[n_subj2] Pz2;
    {
        array[n_subj] vector[2] log_z;
        for (i in 1:n_subj) 
            for (d in 1:2) 
                log_z[i,d] = 0;
        // Combine info across items for each subject
        for (idx in 1:n_obs) {
            int i = sid[idx];
            log_z[i,1] += logM[idx,1];  // z=1
            log_z[i,2] += logM[idx,2];  // z=0
        }
        // Loop over subjects to recover latent discrete parameters
        for (i in 1:n_subj) {
            Pz[i] = softmax(log_z[i])[1];
        }
    }

    // Prediction on new data
    {   
        matrix[n_obs2,2] logM2;
        array[2] matrix[n_subj2,n_item] phi;
        real lpi = log(Pi);
        real l1mpi = log1m(Pi);

        for (idx in 1:n_obs2) {
            int i = sid2[idx];
            int j = iid2[idx];
            real k = inv_logit( k_rev[j] * D *(age2[i] - delta[j]) );
            real lg = lmultiply(1-k, g[j]*(1-gamma[j]) + (1-g[j])*gamma[j]); // x log(y) / (1-k)*log(gamma[j])
            if (item_type[j] == -1) {
                k = 1;
                lg = 0;
            }
            
            // Likelihood under different z
            for (w in 1:2) {
                real z = 1;
                if (w == 2) z = 0;
                phi[w,i,j] = exp( z*k*log1m(S[j]) + (1-z)*k*log(G[j]) + lg);
            }
            
            // Marginalized log prob
            logM2[idx,1] = bernoulli_lpmf(Y2[idx] | phi[1,i,j]) + lpi  ; // P(Y|z=1)
            logM2[idx,2] = bernoulli_lpmf(Y2[idx] | phi[2,i,j]) + l1mpi; // P(Y|z=2)
        }

        array[n_subj2] vector[2] log_z;
        for (i in 1:n_subj2) 
            for (d in 1:2) 
                log_z[i,d] = 0;
        // Combine info across items for each subject
        for (idx in 1:n_obs2) {
            int i = sid2[idx];
            log_z[i,1] += logM2[idx,1];  // z=1
            log_z[i,2] += logM2[idx,2];  // z=0
        }
        // Loop over subjects to recover latent discrete parameters
        for (i in 1:n_subj2) {
            Pz2[i] = softmax(log_z[i])[1];
        }
    }
}
