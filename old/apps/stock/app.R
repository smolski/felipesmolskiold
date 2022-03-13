library(shiny)
library(quantmod)
library(shinyWidgets)
library(BatchGetSymbols)
library(highcharter)
library(dplyr)

# SP500
df.sp500 <- GetSP500Stocks()
#tickers <- df.sp500$tickers
colnames(df.sp500)[1]='cod'
colnames(df.sp500)[2]='company'


# IBOVESPA
# df.ibov <- GetIbovStocks()
library(readr)
df.ibov = read_delim("IBOVDia_12-01-22.csv",
                     ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"),
                     trim_ws = TRUE, skip = 1)
colnames(df.ibov)[2]='company'
colnames(df.ibov)[1]='tickers'
print(df.ibov$tickers)
df.ibov$cod=paste0(df.ibov$tickers, '.SA')
acoes=as.data.frame(rbind(df.ibov[c(6,2)],df.sp500[1:2]))

## ETFs selecioinados
etf = data.frame(
  stringsAsFactors = FALSE,
  cod = c("BOVA11","IVVB11","SMAL11",
          "ECOO11","BRAX11","BOVV11","DIVO11","SMAC11",
          "MATB11","IRFM11","IB5M11","FIXA11","IMAB11",
          "XFIX11","XINA11","NASD11","EURP11","ACWI11",
          "EMEG11","ASIA11","ESGB11","HTEK11","TECK11",
          "DNAI11","MILL11","GOVE11"), company = 1
)
etf$cod=paste0(etf$cod, '.SA')
acoes=as.data.frame(rbind(etf, acoes))





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
                             label = "Códigos Ações",
                             choices = acoes$cod,
                             selectize=FALSE
                             # selected = 1
                             ),
                 
                 # dateRangeInput("fechas",
                 #                "Intervalo de datas",
                 #                start = "2021-06-01",
                 #                format = "dd/mm/yyyy",
                 #                separator = 'a',
                 #                end = as.character(Sys.Date())),
                 
                 # checkboxInput("checkbox", "Último mês", value = FALSE)
                 # 
                 #                  br(),
                 #                  br(),
                 
                 # checkboxInput("log", "Escala logartmica",
                 #               value = FALSE),
                 # 
                 # checkboxInput("ajuste",
                 #               "Ajuste dos dados pela inflaÃ§Ã£o (teste)", value = FALSE)
               ),
               
               mainPanel(
                 highchartOutput("heatmap")
                 #  textOutput("var_seleccionada")
                 # plotOutput("plot"),
                 # highchartOutput("heatmap")


                 
                 # textOutput("b")
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
               # from = input$fechas[1],
               # to = input$fechas[2],
               auto.assign = FALSE)
  })
  # output$plot <- renderPlot({
  #   
  #   dataAjustada = reactive({
  #     if(input$ajuste) return(data())
  #     cat("Cálculo de Ajuste \n")
  #     adjust(data())
  #     
  #   })
    
    # output$var_seleccionada <- renderText(
    #   
    #   paste("Empresa selecionada:", input$siglas)
    #   
    # )
    
    # chartSeries(data(),
    #             theme = chartTheme("white"),
    #             type = "candle",
    #             up.col='green',
    #             dn.col='red',
    #             # subset = ifelse(input$checkbox=="TRUE","last 1 months", "NULL") ,
    #             # log.scale = input$log,
    #             TA = c(addVo(), addEMA(50, col='black'), addEMA(20, col='blue'), addMACD(), addCCI(), addBBands())

    output$heatmap <- renderHighchart({
      
      
      hchart(data()) %>%
             hc_add_series(SMA(Cl(data()), n = 10), yAxis = 0, name = "Fast MA 10") %>% 
               hc_add_series(SMA(Cl(data()), n = 500), yAxis = 0, name = "Slow MA 500")  
        
      
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