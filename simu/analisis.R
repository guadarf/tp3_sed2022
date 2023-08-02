rm(list = ls())
library(ggplot2)
library(dplyr)

setwd("/home/guadarf/SED/TP3")
data=read.table("~/SED/TP3/simu/Qm-tc23.800.csv", header = FALSE, sep=',',dec = ".")
data$estado=0
data$estado[data$V2>1]=1
data$hora=((data$V1+(6*3600))%%86400)/3600
data$dia=(data$V1+(6*3600))%/%86400
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

    for (i in 1:(length(data$V1)-1)){
      
      if(data$estado[i]==0 & data$estado[i+1]==1){
        
        despertar=rbind(despertar,data$V1[i])
        #dia_d=rbind(dia_d,data$dia[i])
        } else if(data$estado[i]==1 & data$estado[i+1]==0){
        dormir=rbind(dormir,data$V1[i])
        #dia_a=rbind(dia_a,data$dia[i])
        }
      }
    
    hora_despertar=c()
    hora_dormir=c()
    
    if (despertar[1]<dormir[1]){
      despertar=despertar[2:length(despertar),]
    }
    for (i in 1:(length(dormir)-1)){
      hora_dormir=rbind(hora_dormir,dormir[i])
      hora_despertar=rbind(hora_despertar,despertar[i])
      #dia_id=rbind(dia_id, dia_a[i+1])
    }
    
    datos=data.frame(hora_despertar_abs=hora_despertar,
                     hora_despertar=((hora_despertar+(6*3600))%%86400)/3600,
                     hora_dormir_abs=hora_dormir,
                     hora_dormir=((hora_dormir+(6*3600))%%86400)/3600,
                     dia=(hora_despertar+(6*3600))%/%86400
    )
  return(datos)
}

#Esto no anda bien si horario de despertar es a la tarde o a la noche 
#y si horario de dormir es despues de las doce de la noche
#pero cualquier corte que pongamos podria andar mal
duracion <-function(datos){
  datos$duracion=(datos$hora_despertar_abs-datos$hora_dormir_abs)/3600  
  datos$puntoMedio=datos$hora_dormir+(datos$duracion/2)
  datos$puntoMedio[datos$puntoMedio>24]=datos$puntoMedio[datos$puntoMedio>24]-24
  return(datos)
}


datos=procesar(data)
datos=duracion(datos)

