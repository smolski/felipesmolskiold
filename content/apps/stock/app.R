# Carga de paquetes ----
library(shiny)
library(quantmod)
library(shinyWidgets)
library(BatchGetSymbols)

# SP500
df.sp500 <- GetSP500Stocks()
#tickers <- df.sp500$tickers
colnames(df.sp500)[1]='cod'
colnames(df.sp500)[2]='company'


# IBOVESPA
# df.ibov <- GetIbovStocks()
library(readr)
df.ibov = read_delim("D:/Github/felipesmolski2/old/apps/stock/IBOVDia_12-01-22.csv",
                               ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"),
                               trim_ws = TRUE, skip = 1)
colnames(df.ibov)[2]='company'
colnames(df.ibov)[1]='tickers'
print(df.ibov$tickers)
df.ibov$cod=paste0(df.ibov$tickers, '.SA')
acoes=as.data.frame(rbind(df.ibov[c(6,2)],df.sp500[1:2]))





# Carga fichero helpers ----
source("helpers.R")

###################################################################################################
# UI    ###########################################################################################
###################################################################################################
ui <- fluidPage(

  navbarPage(
    theme = "cerulean",  # <--- To use a theme, uncomment this
    "FSmolski",

    tabPanel("Início",

             titlePanel("Stock Market"),

             sidebarLayout(
               sidebarPanel(
                 helpText("Selecione uma ação.
               Fonte: Yahoo finance."),

                 # textInput("siglas", "Siglas", "DIS"),
                 selectInput(inputId = "siglas",
                             label = "Códigos ações",
                             choices = acoes$cod,
                             selected = 1),

                 dateRangeInput("fechas",
                                "Intervalo de datas",
                                start = "2019-01-01",
                                format = "dd/mm/yyyy",
                                separator = 'a',
                                end = as.character(Sys.Date())),



                 br(),
                 br(),

                 checkboxInput("log", "Escala logarítmica",
                               value = FALSE),

                 checkboxInput("ajuste",
                               "Ajuste dos dados pela inflação (teste)", value = FALSE)
               ),

               mainPanel(
                 #  textOutput("var_seleccionada")
                 plotOutput("plot"),
                 textOutput("b")
               )
             )
    )
  )
)

###################################################################################################
# Server###########################################################################################
###################################################################################################

server <- function(input, output) {



  data <- reactive({
    cat("Yahoo Finance \n")
    getSymbols(input$siglas, src = "yahoo",
               from = input$fechas[1],
               to = input$fechas[2],
               auto.assign = FALSE)
  })
  output$plot <- renderPlot({

    dataAjustada = reactive({
      if(input$ajuste) return(data())
      cat("Cálculo de Ajuste \n")
      adjust(data())

    })

    output$var_seleccionada <- renderText(

      paste("Empresa selecionada:", input$siglas)

    )

    chartSeries(dataAjustada(),
                theme = chartTheme("white"),
                type = "candle",
                up.col='green',
                dn.col='red',
                log.scale = input$log,
                TA = NULL)
    addBBands()
  })
  re = reactive({
    paste(input$siglas)
  })
  # output$b = renderText({re()})

  # data <- switch(input$siglas, acoes$cod, acoes$company)

}

###################################################################################################
# Run the app######################################################################################
###################################################################################################

shinyApp(ui, server)
