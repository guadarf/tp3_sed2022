rm(list = ls())
library(ggplot2)
library(dplyr)

setwd("/home/guadarf/SED/TP3")
data=read.table("~/SED/powerdevs/output/Qm.csv", header = FALSE, sep=',',dec = ".")
data$estado=0
data$estado[data$V2>1]=1
data$hora=((data$V1+(7.1*3600))%%86400)/3600
data$dia=(data$V1+(7.1*3600))%/%86400
data6=data[data$dia==160,]
data=as.data.frame(data)

data=data[data$dia>1,]

tiff(filename="fig/estabilizacion_postCambio.tiff", 
    units="in", 
    width=4.5, 
    height=3.5, 
    pointsize=12, 
    res=300)
ggplot(data,aes(x=hora, y=estado, group=dia, color=dia))+
  geom_line()
dev.off()

procesar <-function(data){
    hora=c()
    tipo=c()
    dia=c()
    for (i in 1:(length(data$V1)-1)){
      
      if(data$estado[i]==0 & data$estado[i+1]==1){
        tipo=rbind(tipo, "1")
        hora=rbind(hora,data$hora[i])
        dia=rbind(dia,data$dia[i])
        } else if(data$estado[i]==1 & data$estado[i+1]==0){
        tipo=rbind(tipo, "0")
        hora=rbind(hora,data$hora[i])
        dia=rbind(dia,data$dia[i])
        }
      }

  datos=data.frame(tipo=tipo,
                   hora=hora,
                   dia= dia)
  return(datos)
}

datos=procesar(data)
