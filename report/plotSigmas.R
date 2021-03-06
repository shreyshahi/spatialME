# Plot the sigmas and taus from the homo and heteroskedastic models

rm(list = ls())
library(plyr)
library(ggplot2)

load('./../models//withoutCorr.Rdata')
withoutHetero = sigmas
load('./../models//withCorr.Rdata')
withHetero = sigmas

load('./../simpleModels//simpleWoCorr.Rdata')
withoutHomo = sigmas
load('./../simpleModels//simpleCorr.Rdata')
withHomo = sigmas

withCorr = withHetero
withCorr$tau = withHomo$tau
withCorr$phi = withHomo$phi
withCorr$type = "withCorrelation"

withoutCorr = withoutHetero
withoutCorr$tau = withoutHomo$tau
withoutCorr$phi = withoutHomo$phi
withoutCorr$type = "withoutCorrelation"

withCorr = withCorr[,-6]

data = rbind(withCorr, withoutCorr)

heteroSigma = function(M, s1, s2){
  return(s1 + (s2 - s1)/2.25 * (min(max(M,5),7.25) - 5))
}

makePlot = function(df){
  idxWith = which(df$type == "withCorrelation")
  idxWithout = which(df$type == "withoutCorrelation")
  
  per = unique(df$variable)[1]
  
  mags = seq(4,8,0.25)
  N = length(mags)
  
  tau_with_homo = rep(df$tau[idxWith], N)
  phi_with_homo = rep(df$phi[idxWith], N)
  tau_without_homo = rep(df$tau[idxWithout], N)
  phi_without_homo = rep(df$phi[idxWithout], N)
  
  tau_with_hetero = sapply(mags, heteroSigma, df$t1[idxWith], df$t2[idxWith])
  phi_with_hetero = sapply(mags, heteroSigma, df$s1[idxWith], df$s2[idxWith])
  tau_without_hetero = sapply(mags, heteroSigma, df$t1[idxWithout], df$t2[idxWithout])
  phi_without_hetero = sapply(mags, heteroSigma, df$s1[idxWithout], df$s2[idxWithout])
  
  dphi = data.frame(M = mags, phi = c(phi_with_homo, phi_without_homo, phi_with_hetero, phi_without_hetero),
                    corr = c(rep("withCorr",N), rep("withoutCorr",N), rep("withCorr",N), rep("withoutCorr",N)),
                    model = c(rep("homo", 2*N), rep("hetero", 2*N)))
  dtau = data.frame(M = mags, tau = c(tau_with_homo, tau_without_homo, tau_with_hetero, tau_without_hetero),
                    corr = c(rep("withCorr",N), rep("withoutCorr",N), rep("withCorr",N), rep("withoutCorr",N)),
                    model = c(rep("homo", 2*N), rep("hetero", 2*N)))
  
  fnamePhi = paste("./rawPlots/phi_", per, ".jpg", sep = "")
  p = ggplot(dphi, aes(x = M, y = phi, color = corr, linetype = model))
  p = p + geom_line() + theme_bw(base_size = 28) + ylab(expression(phi)) + scale_y_continuous(lim = c(0.4,1))
  ggsave(plot = p, file = fnamePhi)
  
  fnameTau = paste("./rawPlots/tau_", per, ".jpg", sep = "")
  p = ggplot(dtau, aes(x = M, y = tau, color = corr, linetype = model))
  p = p + geom_line() + theme_bw(base_size = 28) + ylab(expression(tau))+ scale_y_continuous(lim = c(0.1,0.6))
  ggsave(plot = p, file = fnameTau)
}

d_ply(data, "variable", makePlot)