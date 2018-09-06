# Replication code for "Burglary Boost" (JQC - 2016)
# Last Edited by Joseph T. Ornstein (December 6, 2015)

#### Load Packages and Model ####

# NOTE: Check path settings.                              #
#       The location of the NetLogo library and model     #
#       may be different on each machine.                 #

library(RNetLogo)
library(ggplot2)

nl.path <- "C:/Program Files (x86)/NetLogo 5.2.0/"
#NLStart(nl.path) #With GUI
NLStart(nl.path,gui=FALSE) #Without GUI

setwd("~/602 - Research/Crime Contagion/Replication Files/")
NLLoadModel("ornstein.hammond.2016.abm.nlogo")

#### Define Functions ####

#Run simulation and return t, x, and y
simulate <- function(ticks, boost = 1, exogenous_rate = 0.0005, CRR.boost = 1, random.seed = FALSE)
{
  NLCommand(paste("set boost",boost))
  NLCommand(paste("set exogenous-rate",exogenous_rate))
  if (CRR.boost != 1)
  {
    NLCommand("set CRR? true")
    NLCommand(paste("set CRR-boost",CRR.boost))
  }
  else
  {
    NLCommand("set CRR? false")
  }
  if (random.seed != FALSE)
  {
    NLCommand(paste("random-seed",random.seed))
  }
  NLCommand("setup")
  NLDoCommand(ticks,"go")
  t <- NLReport("t")
  x <- NLReport("x")
  y <- NLReport("y")
  output <- data.frame(t,x,y)
  output <- subset(output,t>0)#Remove t=0
  rownames(output) <- NULL #Remove rownames
  return(output)
}

distance <- function(x1,x2,y1,y2)
{
  return(sqrt((x1-x2)^2+(y1-y2)^2));
}

#Knox Statistic Function that takes advantage of data structure (sorts by t)
compute_knox_stat <- function(data,t_threshold,d_threshold)
{
  #Sort Data
  data <- data[order(data$t),];
  n <- length(data$t);
  knox_stat <- 0;
  for (i in 1:(n-1))
  {
    for (j in (i+1):n)
    {
      #Increment Knox Stat if t < threshold and d < threshold
      if (abs(data$t[i] - data$t[j]) <= t_threshold)
      {
        if (distance(data$x[i],data$x[j],data$y[i],data$y[j]) <= d_threshold)
        {
          knox_stat <- knox_stat + 1;
        }
      }
      else
      {
        break
      }
    }
  }
  return(knox_stat);
}

#Permutes the data by randomizing t
permute_data <- function(data)
{
  new.t <- sample(data$t)
  permuted.data <- data.frame(new.t,data$x,data$y)
  names(permuted.data) <- c("t","x","y")
  permuted.data <- permuted.data[order(permuted.data$t),]; #Sort by t
  rownames(permuted.data) <- NULL #remove row names
  return(permuted.data)
}


#Performs the Knox Test (inputs: data, thresholds, and number of permutations)
Knox_Test <- function(data,t_threshold,d_threshold,num_permutations=99)
{
  Knox_Stat <- compute_knox_stat(data,t_threshold,d_threshold)
  Monte_Carlo_Statistics <- c()
  
  for(i in 1:num_permutations)
  {
    permuted.dat <- permute_data(data)
    mc_stat <- compute_knox_stat(permuted.dat,t_threshold,d_threshold)
    Monte_Carlo_Statistics <- c(Monte_Carlo_Statistics,mc_stat)
  }
  Knox_Ratio <- Knox_Stat/mean(Monte_Carlo_Statistics);
  p_value <- (length(Monte_Carlo_Statistics[Monte_Carlo_Statistics > Knox_Stat])+1)/(num_permutations+1); 
  Knox_Output <- data.frame(t_threshold,d_threshold,Monte_Carlo_Statistics,Knox_Stat,Knox_Ratio,p_value)
  return(Knox_Output)
}

#### Figures ####


#### Figure 1: Estimated Knox Ratios Varying Alpha ####
t_threshold <- 2
d_threshold <- 5
num_ticks <- 1460
num_permutations <- 99
time_window <- 90
Knox_Stats <- c()
Knox_Ratios <- c()
p_values <- c()
alpha <- c()

for (i in c(1,2,3,5,10))
{
  print(paste("Alpha:",i))
  print(Sys.time())
  dat <- simulate(ticks=num_ticks,boost=i,random.seed=2015) #Random seed set to 2015
  
  for (j in 1:floor(num_ticks/time_window))
  {
    #Loop through all subdats of length time_window
    subdat <- subset(dat,dat$t>(time_window*j-time_window) & dat$t <=(time_window*j));
    Knox_Output <- Knox_Test(subdat,t_threshold,d_threshold,num_permutations)
    
    Knox_Stats <- c(Knox_Stats,Knox_Output$Knox_Stat[1])
    Knox_Ratios <- c(Knox_Ratios,Knox_Output$Knox_Ratio[1])
    p_values <- c(p_values,Knox_Output$p_value[1]);
    alpha <- c(alpha,i)
  }
  print(Sys.time())
}
fig1.data <- data.frame(alpha,Knox_Stats,Knox_Ratios,p_values)
write.csv(fig1.data,file="fig1.csv")

#fig1.data <- read.csv("fig1.csv")

p <- ggplot(fig1.data,aes(x=alpha,y=Knox_Ratios))
p + geom_point() + xlab("Alpha") + ylab("Knox Ratio") +
  geom_abline(intercept=1,slope=0,linetype="dashed") +
  scale_x_continuous(breaks = seq(1,10,1))
ggsave("Fig1.png",dpi=300)


#### Figure 2: Changing Relative Risks ####

#NOTE: This one takes a long time with exongeous_rate = 0.0005
#[1] "Weekday Boost: 1"
#[1] "2015-07-02 09:02:48 EDT"
#[1] "Weekday Boost: 5"
#[1] "2015-07-02 09:28:34 EDT"
#[1] "Weekday Boost: 10"
#[1] "2015-07-02 11:23:05 EDT"
#[1] "Weekday Boost: 20"
#[1] "2015-07-02 16:13:03 EDT"
#[1] "Weekday Boost: 30"
#[1] "2015-07-03 06:35:43 EDT"

#NOTE: Takes less time with exogenous_rate = 0.0001
#[1] "CRR Boost: 1"
#[1] "2015-08-26 12:03:42 EDT"
#[1] "CRR Boost: 5"
#[1] "2015-08-26 12:07:18 EDT"
#[1] "CRR Boost: 10"
#[1] "2015-08-26 12:10:47 EDT"
#[1] "CRR Boost: 20"
#[1] "2015-08-26 12:14:50 EDT"
#[1] "CRR Boost: 30"
#[1] "2015-08-26 12:20:21 EDT"
#[1] "CRR Boost: 40"
#[1] "2015-08-26 12:28:36 EDT"
#[1] "CRR Boost: 50"
#[1] "2015-08-26 12:39:38 EDT"

t_threshold <- 2
d_threshold <- 5
num_ticks <- 90
num_simulations <- 50
num_permutations <- 99
time_window <- 90
Knox_Stats <- c()
Knox_Ratios <- c()
p_values <- c()
crr_boost <- c()
index <- c()

for (i in c(1,5,10,20,30,40,50))
{
  print(paste("CRR Boost:",i))
  print(Sys.time())
  for (j in 1:num_simulations)
  {
    sim_dat <- simulate(ticks=num_ticks,exogenous_rate=0.0001, boost = 1, random.seed=j, CRR.boost = i)
    Knox_Output <- Knox_Test(sim_dat,t_threshold,d_threshold,num_permutations)
    Knox_Stats <- c(Knox_Stats,Knox_Output$Knox_Stat[1])
    Knox_Ratios <- c(Knox_Ratios,Knox_Output$Knox_Ratio[1])
    p_values <- c(p_values,Knox_Output$p_value[1]);
    crr_boost <- c(crr_boost,i)
    index <- c(index,j)
  }
}
fig2_dat <- data.frame(index,crr_boost,Knox_Stats,Knox_Ratios,p_values)
write.csv(fig2_dat,file="fig2_dat.csv")

#Knox Ratios, varying beta
p <- ggplot(fig2_dat,aes(x=crr_boost,y=Knox_Ratios))
p + geom_point() + geom_abline(intercept=1,slope=0,linetype="dashed")


#Compute pct false positives
betas <- c(1,5,10,20,30,40,50)
count_fp <- function(x) 
{ 
  nrow(subset(fig2_dat,crr_boost==x & p_values < 0.05)) /
    nrow(subset(fig2_dat,crr_boost==x))
}
pct_false_positives <- sapply(betas, count_fp)

p <- ggplot(data.frame(betas,pct_false_positives),
            aes(x=betas,y=pct_false_positives*100))
p + geom_point() + labs(x="Beta", y="Percent False Positives")
ggsave("Fig2.png",dpi=300)



#### Table 1: Knox Table with CRR ####
dat <- simulate(ticks=180,random.seed=2015, boost=1,exogenous_rate = 0.0001,CRR.boost = 30) #random seed set to 2015
t_thresholds <- c()
d_thresholds <- c()
Knox_Stats <- c()
Knox_Ratios <- c()
p_values <- c()

for (t_threshold in c(1,7,14,28,56))
{
  for (d_threshold in c(2,5,10,20,30,40))
  {
    print(paste("D Threshold:", d_threshold,", T Threshold:",t_threshold))
    print(Sys.time())
    Knox_Output <- Knox_Test(dat,t_threshold,d_threshold)
    t_thresholds <- c(t_thresholds,t_threshold)
    d_thresholds <- c(d_thresholds,d_threshold)
    Knox_Stats <- c(Knox_Stats,Knox_Output$Knox_Stat[1]);
    Knox_Ratios <- c(Knox_Ratios,Knox_Output$Knox_Ratio[1]);
    p_values <- c(p_values,Knox_Output$p_value[1]);
  }
}
Knox_Table <- data.frame(t_thresholds,d_thresholds,Knox_Stats,Knox_Ratios,p_values)
write.csv(Knox_Table,file="Knox_Table.csv")

#### Figure 3: Hold Alpha at 2 and Vary Knox Test Time Window  #####
dat <- simulate(ticks=1460,boost = 2,exogenous_rate = 0.0005,random.seed=2015) #random seed set to 2015
t_threshold <- 2
d_threshold <- 5
num_permutations <- 99
Knox_Stats <- c()
Knox_Ratios <- c()
p_values <- c()
time_windows <- c()

for (time_window in c(30,60,90,180,360))
{
  #Run loop for as many time_window length periods there are in the data
  print(paste("Time Window:",time_window))
  print(Sys.time())
  for (i in 1:floor(1460/time_window))
  {
    #Loop through all subdats of length time_window
    subdat <- unique(subset(dat,dat$t>(time_window*i-time_window) & dat$t <=(time_window*i),c(t,x,y)));
    Knox_Output <- Knox_Test(subdat,t_threshold,d_threshold,num_permutations)
    
    Knox_Stats <- c(Knox_Stats,Knox_Output$Knox_Stat[1]);
    Knox_Ratios <- c(Knox_Ratios,Knox_Output$Knox_Ratio[1]);
    p_values <- c(p_values,Knox_Output$p_value[1]); 
    time_windows <- c(time_windows,time_window)
  }
  print(Sys.time())
}
fig3_data <- data.frame(time_windows,Knox_Stats,Knox_Ratios,p_values)
write.csv(fig3_data,file="fig3_data.csv")

p <- ggplot(fig3_data,aes(x=time_windows,y=Knox_Ratios))
#p + geom_boxplot() + geom_abline(intercept=1,slope=0,linetype="dashed")
p + geom_point() + xlab("Time Window") + ylab("Knox Ratio") +
  geom_abline(intercept=1,slope=0,linetype="dashed")
ggsave("Fig3.png",dpi=300)


#### Figure 4: Vary time window w/ changing relative risks ####
dat <- simulate(ticks=1460,random.seed=2000, boost=1,exogenous_rate = 0.00025,CRR.boost = 20) #random seed set to 2000
t_threshold <- 2
d_threshold <- 5
num_permutations <- 99
Knox_Stats <- c()
Knox_Ratios <- c()
p_values <- c()
time_windows <- c()

for (time_window in c(30,60,90,180,360))
{
  #Run loop for as many time_window length periods there are in the data
  print(paste("Time Window:",time_window))
  print(Sys.time())
  for (i in 1:floor(1460/time_window))
  {
    #Loop through all subdats of length time_window
    subdat <- unique(subset(dat,dat$t>(time_window*i-time_window) & dat$t <=(time_window*i),c(t,x,y)));
    Knox_Output <- Knox_Test(subdat,t_threshold,d_threshold,num_permutations)
    
    Knox_Stats <- c(Knox_Stats,Knox_Output$Knox_Stat[1]);
    Knox_Ratios <- c(Knox_Ratios,Knox_Output$Knox_Ratio[1]);
    p_values <- c(p_values,Knox_Output$p_value[1]); 
    time_windows <- c(time_windows,time_window)
  }
}
fig4_dat <- data.frame(time_windows,Knox_Stats,Knox_Ratios,p_values)
write.csv(fig4_dat,file="fig4_dat.csv")

mean(fig4_dat$Knox_Ratios[fig4_dat$time_windows==30])
mean(fig4_dat$Knox_Ratios[fig4_dat$time_windows==60])
mean(fig4_dat$Knox_Ratios[fig4_dat$time_windows==90])
mean(fig4_dat$Knox_Ratios[fig4_dat$time_windows==180])
mean(fig4_dat$Knox_Ratios[fig4_dat$time_windows==360])

plot(fig4_dat$time_windows,fig4_dat$Knox_Ratios
     ,xlab="Time Window (Months)",ylab="Knox Ratio")
abline(1,0,col="black",lty=2);

p <- ggplot(fig4_dat,aes(x=time_windows,y=Knox_Ratios))
p + geom_point() + xlab("Time Window") + ylab("Knox Ratio") +
  geom_abline(intercept=1,slope=0,linetype="dashed")
ggsave("Fig4.png",dpi=300)


#### DC Data ####

#NOTE: Per our agreement with MPDC, we cannot post this data publicly.
#Please contact the Metropolitan Police Department or visit http://mpdc.dc.gov/page/statistics-and-data

dat <- read.csv("dc_burglary.csv")

#### Figure 5: Locations of DC Burglaries ####
plot(dat$x,dat$y,asp=1,xlab="Longitude",ylab="Latitude",pch=".")


#### Figure 6: DC Burglaries by Month ####
burglaries <- c()
for (i in unique(dat$year))
{
  for (j in unique(dat$month))
  {
    burglaries <- c(burglaries,length(dat$year[dat$year==i & dat$month==j]));
  }
}
burglaries
sum(burglaries)
length(dat$year)
#cut off the last six months.
burglaries <- burglaries[1:150]
#plot by month
ggdat <- data.frame(seq.Date(as.Date("2000-1-1"),as.Date("2012-6-1"),by="month"),
                    burglaries)
names(ggdat) <- c("Date","Burglaries")
p <- ggplot(ggdat,aes(x=Date,y=Burglaries))
p + geom_line()
ggsave("Fig6.png",dpi=300)

#### Figure 7: Burglaries by Day of the Week ####
burglaries <- c()
for (i in 0:6)
{
  burglaries <- c(burglaries,length(dat$t[dat$t %% 7 == i]));
}
day <- c("Sat","Sun","Mon","Tue","Wed","Thu","Fri")
ggdat <- data.frame(1:length(burglaries),burglaries)
names(ggdat) <- c("index","burglaries")
p <- ggplot(ggdat,aes(x=index,y=burglaries))
p + geom_point() + xlab("Day of the Week") + ylab("Burglaries") +
  scale_x_discrete(labels = day)
ggsave("Fig7.png",dpi=300)

#### Figure 8: Neighborhood risk over time ####

#NW Burglaries
#For each month, compute the number of burglaries
burglariesNW <- c()
for (i in unique(dat$year))
{
  for (j in unique(dat$month))
  {
    burglariesNW <- c(burglariesNW,length(dat$year[dat$year==i & dat$month==j & dat$y>1.0025*dat$x-268000]))
  }
}
burglariesNW
sum(burglariesNW)
length(dat$year)
#cut off the last six months.
burglariesNW <- burglariesNW[1:150]

#SE Burglaries
#For each month, compute the number of burglaries
burglariesSE <- c()
for (i in unique(dat$year))
{
  for (j in unique(dat$month))
  {
    burglariesSE <- c(burglariesSE,length(dat$year[dat$year==i & dat$month==j & dat$y<1.0025*dat$x-268000]))
  }
}
burglariesSE
sum(burglariesSE)
length(dat$year)
#cut off the last six months.
burglariesSE <- burglariesSE[1:150]

#GGPlot
ggdat <- data.frame(seq.Date(as.Date("2000-1-1"),as.Date("2012-6-1"),by="month"),
                    burglariesNW, burglariesSE)
names(ggdat) <- c("Date","BurglariesNW","BurglariesSE")
p <- ggplot(ggdat,aes(x=Date))
p + ylab("Burglaries") +
  geom_point(aes(y=burglariesNW),shape="o",size=2.5) +
  geom_point(aes(y=burglariesSE),shape="x",size=2.5) +
  stat_smooth(aes(y=burglariesNW), se=FALSE,color="black") +
  stat_smooth(aes(y=burglariesSE), se=FALSE, color="black")
ggsave("Fig8.png",dpi=300)

#Built-in: Lowess Lines
plot(c(1:length(burglariesNW)),burglariesNW,type="p",xlab="Month",ylab="Burglaries",col="black",pch=1,cex=0.6,ylim=c(0,500))
lines(stats::lowess(burglariesNW),col="black")
points(c(1:length(burglariesSE)),burglariesSE,col="black",pch=4,cex=0.6)
lines(stats::lowess(burglariesSE),col="black")

#### Figure 9: Knox Ratios from DC data, varying time window ####

t_threshold <- 7
d_threshold <- 200
num_permutations <- 99
Knox_Stats <- c()
Knox_Ratios <- c()
p_values <- c()
time_windows <- c()

for (time_window in c(30,60,90,180,360))
{
  #Run loop for as many time_window length periods there are in the data
  print(paste("Time Window:",time_window))
  print(Sys.time())
  for (i in 1:floor(max(dat$t)/time_window))
  {
    #Loop through all subdats of length time_window
    subdat <- unique(subset(dat,dat$t>(time_window*i-time_window) & dat$t <=(time_window*i),c(t,x,y)));
    Knox_Output <- Knox_Test(subdat,t_threshold,d_threshold,num_permutations)
    
    Knox_Stats <- c(Knox_Stats,Knox_Output$Knox_Stat[1]);
    Knox_Ratios <- c(Knox_Ratios,Knox_Output$Knox_Ratio[1]);
    p_values <- c(p_values,Knox_Output$p_value[1]); 
    time_windows <- c(time_windows,time_window)
  }
}
fig9_dat <- data.frame(time_windows,Knox_Stats,Knox_Ratios,p_values)
write.csv(fig9_dat,file="fig9_dat.csv")

mean(fig9_dat$Knox_Ratios[fig9_dat$time_windows==30])
mean(fig9_dat$Knox_Ratios[fig9_dat$time_windows==60])
mean(fig9_dat$Knox_Ratios[fig9_dat$time_windows==90])
mean(fig9_dat$Knox_Ratios[fig9_dat$time_windows==180])
mean(fig9_dat$Knox_Ratios[fig9_dat$time_windows==360])

plot(fig9_dat$time_windows,fig9_dat$Knox_Ratios
     ,xlab="Time Window (Months)",ylab="Knox Ratio")
abline(1,0,col="black",lty=2);

p <- ggplot(fig9_dat,aes(x=time_windows,y=Knox_Ratios))
p + geom_point() + xlab("Time Window") + ylab("Knox Ratio") +
  geom_abline(intercept=1,slope=0,linetype="dashed")
ggsave("Fig9.png",dpi=300)



#### NLQuit ####
NLQuit()