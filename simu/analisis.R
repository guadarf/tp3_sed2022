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
    despertar=c()
    dormir=c()
    dia_a=c()
    dia_d=c()
    for (i in 1:(length(data$V1)-1)){
      
      if(data$estado[i]==0 & data$estado[i+1]==1){
        
        despertar=rbind(despertar,data$hora[i])
        dia_d=rbind(dia_d,data$dia[i])
        } else if(data$estado[i]==1 & data$estado[i+1]==0){
        dormir=rbind(dormir,data$hora[i])
        dia_a=rbind(dia_a,data$dia[i])
        }
      }
    
    hora_despertar=c()
    hora_dormir=c()
    dia_id=c()
    for (i in 1:(length(dormir)-1)){
      hora_dormir=rbind(hora_dormir,dormir[i])
      hora_despertar=rbind(hora_despertar,despertar[dia_d==dia_a[i+1]])
      dia_id=rbind(dia_id, dia_a[i+1])
    }
    datos=data.frame(hora_despertar=hora_despertar,
                     hora_dormir=hora_dormir,
                     dia=dia_id
    )
  return(datos)
}

#Esto no anda bien si horario de despertar es a la tarde o a la noche 
#y si horario de dormir es despues de las doce de la noche
#pero cualquier corte que pongamos podria andar mal
duracion <-function(datos){
  dormir= 24-datos$hora_dormir
  datos$duracion=datos$hora_despertar+dormir  
  datos$puntoMedio=datos$hora_dormir+(datos$duracion/2)
  datos$puntoMedio[datos$puntoMedio>24]=datos$puntoMedio[datos$puntoMedio>24]-24
  return(datos)
}


datos=procesar(data)
datos=duracion(datos)

