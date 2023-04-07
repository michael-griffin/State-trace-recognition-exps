#Written by Michael Griffin
#Last modified 6.9.2019

#Requires STACMR-R/ and Java Source/ folders in addition to the data file.

#Simplified version of CMR code run for the State-trace PIRST paper, for specifics see:
#Kalish, M. L., Dunn, J. C., Burdakov, O. P., & Sysoev, O. (2016). 
#A statistical test of the equality of latent orders.


#Loads a single experiment's data file then returns a p-value. 
#Can modify test to add in partial order constraints, or change nsamples to adjust
#the number of bootstrap samples used (reducing will shorten runtime).

# library(R.matlab)
library(readxl)

exp = 3
folder = 'data/'
readname = paste0(c(folder, 'fullsummary_formatted_exp', exp, '.xlsx'), collapse = '')

dat = read_excel(readname)


dirbase = getwd()
dirsim = paste0(dirbase, '/STACMR-R')
#needed prev working directory for source to properly load in functions. Afterwards can switch back.
setwd(dirsim)
source("staCMRsetup.R") 

partial = 0
npoints = 8
nhalf = npoints/2
nsamples = 10000 #can drop to 1000 for shorter runtime.

#Can construct partial orders with lists. So: 1<2, 2<3 would be list(c(1:3))
E = list(c(1:4),c(5:8)) #c(5,1),c(6,2),c(7,3),c(8,4))
#E = list(c(4,3,2,1), c(8,7,6,5,4))

cmrstats = data.frame(matrix(vector(), 0, 4,
                      dimnames=list(c(), c("pval", "datafit", "avgfits", "stdfit"))),
                      stringsAsFactors=F)

#Format data 
nsubs = dim(dat)[1]
datnew = data.frame(matrix(vector(), nsubs*4,3+nhalf))
colnames(datnew) = c('subn', 'depend', 'att', 't1', 't2', 't3', 't4')
crow = 1
for (k in 1:nsubs){
  for (depend in 1:2){
    for (att in 1:2){
      ccols = (depend-1)*(npoints) + (att-1)*nhalf + 1
      ccols = ccols:(ccols+nhalf-1)
      
      datnew[crow,1:3] = c(k, depend, att)
      datnew[crow,4:dim(datnew)[2]] = dat[k,ccols]
      
      crow = crow+1
    }
  }
}

if (partial) {
  output = staCMRFIT(datnew, nsample=nsamples, partial= E)
} else {
  output = staCMRFIT(datnew, nsample=nsamples)
}

cmrstats[j,"pval"] = output$p
cmrstats[j,"datafit"] = output$datafit
cmrstats[j,"avgfits"] = mean(output$fits)
cmrstats[j,"stdfit"] = sd(output$fits)

setwd(dirbase)
