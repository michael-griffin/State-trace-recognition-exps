#Written by Michael Griffin
#Loads ezANOVA package to run repeated measures ANOVAs, testing for effects
#of memory test type (old/new vs. color), full/divided attention, and study time.

#install.packages("ez", dependencies = TRUE)
library(ez)
library(readxl)


folder = 'data/'
filename = paste0(folder, 'Rformatted_exp3.xlsx') #Update as needed
dat = read_excel(filename, sheet = 1)


#oldnew only
datoldnew = dat[which(dat$Judgment == 'oldnew'),]
anov.oldnew = ezANOVA(datoldnew, dv = Dprime, wid = Subject, within = .(Attention, Studytime))
summary(anov.color)
#color only
datcolor = dat[which(dat$Judgment == 'color'),]
datcolor[,2] = datcolor[,2] * sqrt(2) #This changes absolutely nothing about the analysis, since it affects numerator/denominator equally.
anov.color = ezANOVA(datcolor, dv = Dprime, wid = Subject, within = .(Attention, Studytime))
summary(anov.color)

#combined, tests for interaction
anov.combined = ezANOVA(dat, dv = Dprime, wid = Subject, within = .(Judgment, Attention, Studytime))
summary(anov.combined)


# #Can double check with R's built in aov:
# aov.oldnew = aov(Dprime ~ Attention*Studytime + Error(Subject/(Attention*Studytime)), data=datoldnew)
# aov.color = aov(Dprime ~ Attention*Studytime + Error(Subject/(Attention*Studytime)), data=datcolor) 
# aov.combined = aov(Dprime ~ Attention*Studytime*Judgment + Error(Subject/(Attention*Studytime*Judgment)), data=dat)
# #summary(aov.oldnew)