library(stom)

dat = readRDS("made/test.RDS")
fit = readRDS("made/fit.RDS")

ds = precis(fit, depth=2, "Pz2")


set.seed(10)
plot(1, type="n", xlim=c(.5,2.5), ylim=c(-8,8), xaxt='n')
abline(h=0, lty="dashed", col="grey")
for (i in 1:dat$n_subj) {
    x_ = dat$z[i] + 1 + runif(1, -.45, .45)
    m_ = ds$mean[i] |> logit()
    y_ = c(ds$q5[i], ds$q95[i]) |> logit()
    lines(rep(x_,2), y_, lwd=1, col=col.alpha(2))
    points(x_, m_, pch=19, col=2)
}
axis(1, at=c(1, 2), labels=c("Z=0", "Z=1"))
