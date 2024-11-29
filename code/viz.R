'Plot LPC Sample Size Study Results

Usage:
    this.R TRAIN TEST FIT PDF1 PDF2
' -> doc

if (interactive()) {
    a = docopt::docopt(doc, args = list("made/train.RDS",
                                        "made/test.RDS",
                                        "made/fit.RDS",
                                        "recovery.300.pdf", 
                                        "predict.300.pdf") )
} else {
    a = docopt::docopt(doc)
}
# print(a)
#############################################################################


library(stom)
library(dplyr)
f = glue::glue

dat = readRDS(a$TRAIN) 
dat2 = readRDS(a$TEST) 
fit = readRDS(a$FIT)  # fit.300.RDS


ds = precis(fit, pars = as_vec("S,G,delta,D,gamma"), depth = 3)

pdf(a$PDF1, width = 11, height=8.5)
plot(ds$rhat)

# Check recovery

# Age & Age threshold distribution
hist(dat$age, breaks=40, main="Simulated Age & Item Distribution (train set)", xlab = "",
     xlim=c(-.3,35))
for (i in seq(dat2$delta)) {
    dt = max(dat2$delta[i], -1) |> round()
    lines(rep(dt,2), c(-1,0), col=2, lwd=3)
}
title(sub = f("Item age threshold (months): {paste(round(dat$delta),collapse=', ')}"),
      cex.sub=.8, adj=0)

par(mfrow=c(2,2))

# Item threshold recovery
d = precis(fit, depth=3, pars="delta")
true = with(dat, c(delta))
jit = rnorm(length(true), 0, .18)
plot(true+jit, d$mean, xlab="True", ylab="Model Estimate",
     main = "Age threshold", ylim = range(d$q5,d$q95,-10,40), col="white")
abline(0,1, col="grey")
for (i in 1:nrow(d)) {
    if (dat$delta[i] < 0) next
    tp = dat$item_type[i]
    x_ = rep(true[i], 2) + jit[i]
    y_ = c(d$q5[i], d$q95[i])
    if (tp == -1) c_ = 1
    if (tp == 1)  c_ = 2
    if (tp == 2)  c_ = 2 # 4
    lines(x_, y_, col=col.alpha(c_), lwd=5)
    points(x_[1], d$mean[i], col=2, pch=19)
    # text(x_[1], d$mean[i]-1.8, labels = i, cex=.9)
}

set.seed(10)
# Person misfit recovery
d = precis(fit, pars="gamma")
true = with(dat, c(gamma))
true[5] = true[5] - .0036  # adj to unstack the bars
plot(true, d$mean, xlab="True", ylab="Model Estimate",
     main = "gamma", ylim=range(d$q5,d$q95), col="white")
abline(0,1, col="grey")
for (i in 1:nrow(d)) {
    if (dat$delta[i] < 0) next
    x_ = rep(true[i], 2)
    y_ = c(d$q5[i], d$q95[i])
    lines(x_, y_, col=col.alpha(2, sqrt(dat$delta[i]/46) ), lwd=5)
    points(x_[1], d$mean[i], col=2, pch=19)
    text(x_[1], d$mean[i]+sample(c(-.015,.015), 1), labels = round(dat$delta[i]), cex=.9)
}

# Item param recovery
d = precis(fit, depth=3, pars="G")
true = with(dat, c(G))
plot(true, d$mean, ylim=range(d$q5, d$q95), col=0,
     xlab="True", ylab="Model Estimate",
     main = "Guess")
abline(0,1, col="grey")
for (i in 1:nrow(d)) {
    x_ = rep(true[i], 2)
    y_ = c(d$q5[i], d$q95[i])
    lines(x_, y_, lwd=5, col=2 |> col.alpha(.3))
    points(x_[1], d$mean[i], pch=19, col=2)
    text(x_[1], d$mean[i]+sample(c(-.025,.025), 1), labels = round(dat$delta[i]), cex=.9)
}


d = precis(fit, depth=3, pars="S")
true = with(dat, c(S))
plot(true, d$mean, ylim=range(d$q5, d$q95), col=0,
     xlab="True", ylab="Model Estimate",
     main = "Slip")
abline(0,1, col="grey")
for (i in 1:nrow(d)) {
    x_ = rep(true[i], 2)
    y_ = c(d$q5[i], d$q95[i])
    lines(x_, y_, lwd=5, col=2 |> col.alpha(.3))
    points(x_[1], d$mean[i], pch=19, col=2)
    text(x_[1], d$mean[i]+sample(c(-.025,.025), 1), labels = round(dat$delta[i]), cex=.9)
}


par(mfrow=c(1,1))
d = precis(fit, depth=3, pars="D")
true = with(dat, c(D))
plot(true, d$mean, ylim=range(d$q5, d$q95), xlab="True", ylab="Model Estimate",
     main = "Parameter Recovery (item discrimination)")
abline(0,1, col="grey")
for (i in 1:nrow(d)) {
    x_ = rep(true[i], 2)
    y_ = c(d$q5[i], d$q95[i])
    lines(x_, y_, col=col.alpha(2), lwd=5)
}


dev.off()




pdf(a$PDF2, width = 10, height=4)

par(mfrow = c(1,3))

jitter = rnorm(length(dat2$z),0,.05)
samp = table(dat2$z)
names(samp) = c("TH", "HL")
# Latent class z recovery (all)
dz = precis(fit, depth = 1, pars="Pz2")
idx_z0 = which(dat2$z == 0)
idx_z1 = which(dat2$z == 1)
P_spec = mean(dz[idx_z0,]$mean < .5)  # P(0|z=0)
P_sens = mean(dz[idx_z1,]$mean > .5)  # P(1|z=1)
plot(dat2$z+jitter, dz$mean, xaxt="n",
     xlab="", ylab="Mean posterior probability of hearing loss", ylim=c(0,1),
     pch=ifelse(dat2$z==0,0,2),
     col = ifelse(dat2$age < 12, 2,
                  ifelse( dat2$age >=12 & dat2$age <=24, "darkgrey", 4)
     )
)
abline(h=.5,col="grey")
axis(1, at=0:1, labels=c("Typical Hearing\n(TH)", "Hearing Loss\n(HL)"), , tick = F, line = .5)
text(.5, .58, labels = f("Sensitivity\n P(+|HL) = {round(P_sens*100,1)}%"), cex=.9 )
text(.5, .43 , labels = f("Specificity\n P(-|TH) = {round(P_spec*100,1)}%"), cex=.9 )
title(main = c(paste(names(samp), samp, sep=":", collapse=" "),
               "(20 items / All ages)")
)

# Below 12 months old
Age = 12
idx = which(dat2$age < Age)
idx_z0 = which(dat2$z == 0 & dat2$age < Age)
idx_z1 = which(dat2$z == 1 & dat2$age < Age)
P_spec = mean(dz[idx_z0,]$mean < .5)  # P(0|z=0)
P_sens = mean(dz[idx_z1,]$mean > .5)  # P(1|z=1)
samp = table(dat2$z[idx])
names(samp) = c("TH", "HL")

z = dat2$z[idx]
plot(z+jitter[idx], dz$mean[idx], xaxt="n",
     xlab="", ylab="Mean posterior probability of hearing loss",
     pch=ifelse(z==0,0,2),
     col=2,
     ylim=c(0,1))
abline(h=.5,col="grey")
axis(1, at=0:1, labels=c("Typical Hearing\n(TH)", "Hearing Loss\n(HL)"), , tick = F, line = .5)
text(.5, .58, labels = f("Sensitivity\n P(+|HL) = {round(P_sens*100,1)}%"), cex=.9 )
text(.5, .43 , labels = f("Specificity\n P(-|TH) = {round(P_spec*100,1)}%"), cex=.9 )
title(main = c(paste(names(samp), samp, sep=":", collapse=" "),
               "(20 items / Age < 12)")
)

# Above 24 months old
Age = 24
idx = which(dat2$age > Age)
idx_z0 = which(dat2$z == 0 & dat2$age > Age)
idx_z1 = which(dat2$z == 1 & dat2$age > Age)
P_spec = mean(dz[idx_z0,]$mean < .5)  # P(0|z=0)
P_sens = mean(dz[idx_z1,]$mean > .5)  # P(1|z=1)
samp = table(dat2$z[idx])
names(samp) = c("TH", "HL")

z = dat2$z[idx]
plot(z+jitter[idx], dz$mean[idx], xaxt="n",
     xlab="", ylab="Mean posterior probability of hearing loss",
     pch=ifelse(z==0,0,2),
     col = 4,
     ylim=c(0,1))
abline(h=.5,col="grey")
axis(1, at=0:1, labels=c("Typical Hearing\n(TH)", "Hearing Loss\n(HL)"), , tick = F, line = .5)
text(.5, .58, labels = f("Sensitivity\n P(+|HL) = {round(P_sens*100,1)}%"), cex=.9 )
text(.5, .43 , labels = f("Specificity\n P(-|TH) = {round(P_spec*100,1)}%"), cex=.9 )
title(main = c(paste(names(samp), samp, sep=":", collapse=" "),
               f("(20 items / Age > {Age})")) )

dev.off()
