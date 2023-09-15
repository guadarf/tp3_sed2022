rm(list = ls())
library(ggplot2)
library(dplyr)
library(latex2exp)

setwd("/home/guadarf/SED/TP3/simu")


# tiff(filename="fig/estabilizacion_postCambio.tiff", 
#     units="in", 
#     width=4.5, 
#     height=3.5, 
#     pointsize=12, 
#     res=300)
# ggplot(data,aes(x=hora, y=estado, group=dia, color=dia))+
#   geom_line()
# dev.off()

procesar <-function(data){
    data$estado=0
    data$estado[data$V2>1]=1
    data$hora=((data$V1+(6*3600))%%86400)/3600
    data$dia=(data$V1+(6*3600))%/%86400
    data=as.data.frame(data)
    data=data[data$dia>1,]
  
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


duracion <-function(datos){
  datos$duracion=(datos$hora_despertar_abs-datos$hora_dormir_abs)/3600  
  return(datos)
}

paraGraficar=c()
for (i in seq(23.7, 24.6, 0.02)){
  tc=sprintf("%0.3f", i)
  data=read.table(paste("~/SED/TP3/simu/Qm-tc", tc, ".csv", sep = ""), header = FALSE, sep=',',dec = ".")
  datos=procesar(data)
  datos=duracion(datos)
  datos$tc=i
  paraGraficar=rbind(paraGraficar, datos[length(datos$tc),])
  paraGraficar$duracion[length(paraGraficar$duracion)]=mean(datos$duracion[(length(datos$tc)-20):(length(datos$tc))])
 
}
paraGraficar$puntoMedio=paraGraficar$hora_dormir+(paraGraficar$duracion/2)
paraGraficar$puntoMedio[paraGraficar$puntoMedio>24]=paraGraficar$puntoMedio[paraGraficar$puntoMedio>24]-24

paraGraficar$puntoMedio[paraGraficar$puntoMedio>19]=paraGraficar$puntoMedio[paraGraficar$puntoMedio>19]-24
paraGraficar$puntoMedio_rel=(-1)*paraGraficar$puntoMedio+paraGraficar$puntoMedio[paraGraficar$tc==24.2]

tiff(filename="fig/TCvsSD.tiff", 
     units="in", 
     width=4.5, 
     height=3.5, 
     pointsize=12, 
     res=300)
ggplot(paraGraficar,aes(x=tc, y=duracion))+
  geom_point()+
  labs(y = "Duración de sueño (h)", x = TeX("$t_{c} (h)$"))  

dev.off()

tiff(filename="fig/TCvsPuntoMedio.tiff", 
     units="in", 
     width=4.5, 
     height=3.5, 
     pointsize=12, 
     res=300)
ggplot(paraGraficar,aes(x=tc, y=puntoMedio_rel))+
  geom_point() + geom_line()+
  labs(y = "Fase de sueño relativa (h)", x = TeX("$t_{c} (h)$"))
dev.off()


paraGraficar=c()
for (i in seq(0.70, 1.3, 0.02)){
  Vvh=sprintf("%0.3f", i)
  print(i)
  data=read.table(paste("~/SED/TP3/simu/Qm-Vvh", Vvh, ".csv", sep = ""), header = FALSE, sep=',',dec = ".")
  datos=procesar(data)
  datos=duracion(datos)
  datos$Vvh=i
  paraGraficar=rbind(paraGraficar, datos[length(datos$Vvh),])
  paraGraficar$duracion[length(paraGraficar$duracion)]=mean(datos$duracion[(length(datos$Vvh)-10):(length(datos$Vvh))])
  
}
paraGraficar$puntoMedio=paraGraficar$hora_dormir+(paraGraficar$duracion/2)
paraGraficar$puntoMedio[paraGraficar$puntoMedio>24]=paraGraficar$puntoMedio[paraGraficar$puntoMedio>24]-24
paraGraficar$puntoMedio[paraGraficar$puntoMedio>12]=paraGraficar$puntoMedio[paraGraficar$puntoMedio>12]-24
paraGraficar$puntoMedio_rel=(-1)*paraGraficar$puntoMedio+paraGraficar$puntoMedio[paraGraficar$Vvh==1]



tiff(filename="fig/VvhvsSD.tiff", 
     units="in", 
     width=4.5, 
     height=3.5, 
     pointsize=12, 
     res=300)
ggplot(paraGraficar,aes(x=Vvh, y=duracion))+
  geom_point()+
  labs(y = "Duración de sueño (h)", x = TeX("$V_{vh}$"))  

dev.off()

tiff(filename="fig/VVhvsPuntoMediovs.tiff", 
     units="in", 
     width=4.5, 
     height=3.5, 
     pointsize=12, 
     res=300)
ggplot(paraGraficar,aes(x=Vvh, y=puntoMedio_rel))+
  geom_point() + geom_line()+
  labs(y = "Fase de sueño relativa (h)", x = TeX("$V_{vh}$"))
dev.off()

