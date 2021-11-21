if (!exists(".inflation")) {
  .inflation <- getSymbols('CPIAUCNS', src = 'FRED', 
     auto.assign = FALSE)
}  


# Ajusta los datos de Google Finance con los valores del índice del 
# precio al consumidor mensual precedente de los precios históricos 
# de la Reserva Federal de St. Louis devueltos en los valores presentes.
adjust <- function(data) {

      latestcpi <- last(.inflation)[[1]]
      inf.latest <- time(last(.inflation))
      months <- split(data)               
      
      adjust_month <- function(month) {               
        date <- substr(min(time(month[1]), inf.latest), 1, 7)
        coredata(month) * latestcpi / .inflation[date][[1]]
      }
      
      adjs <- lapply(months, adjust_month)
      adj <- do.call("rbind", adjs)
      axts <- xts(adj, order.by = time(data))
      axts[ , 5] <- Vo(data)
      axts
}