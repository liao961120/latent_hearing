## 0. Setup output dir
mkdir made

## 1. Simulate data  (Rscript sim.R N_SUBJ SEED -o OUTFILE)
Rscript sim.R       300    1 -o made/train.RDS
Rscript sim.R       300 2024 -o made/test.RDS
Rscript sim-type3.R 300    1 -o made/train-type3.RDS
Rscript sim-type3.R 300 2024 -o made/test-type3.RDS

## 2. Validate model on simulated data (Rscript fit.R STAN TRAIN TEST -o OUTFILE)
Rscript fit.R model.stan  made/train.RDS        made/test.RDS       -o made/fit.RDS
Rscript fit.R model.stan  made/train-type3.RDS  made/test-type3.RDS -o made/fit-type3.RDS

## 3. Plot results (Rscript viz.R TRAIN TEST FIT PDF1 PDF2)
Rscript viz.R        made/train.RDS        made/test.RDS        made/fit.RDS        recovery.pdf        predict.pdf 
Rscript viz-type3.R  made/train-type3.RDS  made/test-type3.RDS  made/fit-type3.RDS  recovery-type3.pdf  predict-type3.pdf 
