library(easypackages)
libraries("foreign","tidyverse","tictoc")
#========= Data Acquisition =======================
tic()
df1=read.csv("https://data.cdc.gov/api/views/hmz2-vwda/rows.csv?accessType=DOWNLOAD")
toc()
# This repository from CDC has tons for interesting data https://www.cdc.gov/nchs/nvss/vsrr/provisional-tables.htm
tic()
df2=df1%>%rename_all(. %>% toupper() %>% gsub("[.]", "_", .))%>%
filter(STATE!="UNITED STATES",YEAR==2020,MONTH=="June")%>%
pivot_wider(names_from = INDICATOR, values_from = DATA_VALUE)%>%
rename_all(.%>% toupper()%>%gsub("NUMBER OF ","", .)%>%gsub(" ","_", .))
df2$STATE=str_to_title(df2$STATE)

db1=read.dbf("../Data/Raw/cb_2018_us_state_500k.dbf",as.is=T)
df3=left_join(db1,df2, by=c("NAME"="STATE")) #join only subsets that are common
df3=df3%>%mutate(DIFF=LIVE_BIRTHS-DEATHS,POS_NEG=ifelse(DIFF>=0,"POS","NEG"))
write.dbf(df3,"../Data/Processed/cb_2018_us_state_500k.dbf")

toc()