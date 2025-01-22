library(shiny)
library(dplyr)
library(ggplot2)

# Fonction utilitaire pour construire un data.frame de résumé
# (Min, Q1, Med, Mean, Q3, Max)
makeSummaryDf <- function(df) {
  vars <- colnames(df)
  
  # On crée un data.frame vide qui aura 7 colonnes
  res <- data.frame(
    Variable = character(0),
    Min      = numeric(0),
    Q1       = numeric(0),
    Median   = numeric(0),
    Mean     = numeric(0),
    Q3       = numeric(0),
    Max      = numeric(0),
    stringsAsFactors = FALSE
  )
  
  for (v in vars) {
    x <- df[[v]]
    if (is.numeric(x)) {
      stats <- summary(x)  # Min, 1st Qu., Median, Mean, 3rd Qu., Max
      newRow <- data.frame(
        Variable = v,
        Min      = as.numeric(stats["Min."]),
        Q1       = as.numeric(stats["1st Qu."]),
        Median   = as.numeric(stats["Median"]),
        Mean     = as.numeric(stats["Mean"]),
        Q3       = as.numeric(stats["3rd Qu."]),
        Max      = as.numeric(stats["Max."]),
        stringsAsFactors = FALSE
      )
      res <- rbind(res, newRow)
    }
  }
  return(res)
}

shinyServer(function(input, output) {
  
  # Reactive : on filtre le dataset en fonction du choix "filter_cyl"
  filteredData <- reactive({
    data <- mtcars
    cylSelected <- as.numeric(input$filter_cyl)
    
    if (length(cylSelected) == 0) {
      # Si aucun cylindre n'est coché => dataset vide
      data <- data[0, ]
    } else {
      data <- data %>% filter(cyl %in% cylSelected)
    }
    return(data)
  })
  
  # ---- Nuage de points ----
  output$plot_mtcars <- renderPlot({
    df <- filteredData()
    ggplot(df, aes_string(x = input$var_x, y = input$var_y, color = "factor(cyl)")) +
      geom_point(size = 3, alpha = 0.8) +
      theme_minimal(base_size = 14) +
      labs(
        x = input$var_x,
        y = input$var_y,
        color = "Cylindres",
        title = paste("Nuage de points de", input$var_y, "en fonction de", input$var_x)
      ) +
      theme(
        plot.title = element_text(face = "bold", color = "#2C3E50", size = 16)
      )
  })
  
  # ---- Boxplot ----
  output$boxplot_mtcars <- renderPlot({
    df <- filteredData()
    
    # Gérer le cas où dataset vide :
    if (nrow(df) == 0) {
      plot.new()
      title("Aucune donnée à afficher (dataset vide)")
      return(NULL)
    }
    # Gérer le cas où var_y n'est pas numérique :
    if (!is.numeric(df[[input$var_y]])) {
      plot.new()
      title("La variable Y n'est pas numérique, impossible de tracer un boxplot.")
      return(NULL)
    }
    
    ggplot(df, aes_string(x = "factor(cyl)", y = input$var_y, fill = "factor(cyl)")) +
      geom_boxplot(alpha = 0.7) +
      theme_minimal(base_size = 14) +
      labs(
        x = "Cylindres",
        y = input$var_y,
        fill = "Cylindres",
        title = paste("Boxplot de", input$var_y, "selon le nb de cylindres")
      ) +
      theme(
        plot.title = element_text(face = "bold", color = "#2C3E50", size = 16)
      )
  })
  
  # ---- Histogramme ----
  output$hist_mtcars <- renderPlot({
    df <- filteredData()
    varHist <- input$var_hist
    
    # Vérifier si la variable est bien numérique
    if (!is.numeric(df[[varHist]]) || nrow(df) == 0) {
      plot.new()
      title("Aucune donnée ou variable non numérique")
    } else {
      ggplot(df, aes_string(x = varHist)) +
        geom_histogram(bins = 10, fill = "steelblue", color = "white", alpha = 0.8) +
        theme_minimal(base_size = 14) +
        labs(
          x = varHist,
          y = "Fréquence",
          title = paste("Histogramme de", varHist)
        ) +
        theme(
          plot.title = element_text(face = "bold", color = "#2C3E50", size = 16)
        )
    }
  })
  
  # ---- Matrice de dispersion (Pairs Plot) ----
  output$pairs_mtcars <- renderPlot({
    df <- filteredData()
    if (nrow(df) == 0) {
      plot.new()
      title("Aucune donnée à afficher")
    } else {
      pairs(df, main = "Matrice de dispersion (Pairs Plot)")
    }
  })
  
  # ---- Résumé Statistique en 3 sous-tableaux ----
  
  # Sous-tableau 1 : mpg, cyl, disp, hp
  output$summary_table1 <- renderTable({
    df <- filteredData()
    subdf <- df[, c("mpg", "cyl", "disp", "hp"), drop = FALSE]
    tbl <- makeSummaryDf(subdf)
    # Limiter le nombre de décimales pour éviter l'empilement
    tbl[, 2:7] <- round(tbl[, 2:7], 2)
    tbl
  }, spacing = "xs")  # "xs" = espacement extra-serré
  
  # Sous-tableau 2 : drat, wt, qsec, vs
  output$summary_table2 <- renderTable({
    df <- filteredData()
    subdf <- df[, c("drat", "wt", "qsec", "vs"), drop = FALSE]
    tbl <- makeSummaryDf(subdf)
    tbl[, 2:7] <- round(tbl[, 2:7], 2)
    tbl
  }, spacing = "xs")
  
  # Sous-tableau 3 : am, gear, carb
  output$summary_table3 <- renderTable({
    df <- filteredData()
    subdf <- df[, c("am", "gear", "carb"), drop = FALSE]
    tbl <- makeSummaryDf(subdf)
    tbl[, 2:7] <- round(tbl[, 2:7], 2)
    tbl
  }, spacing = "xs")
})
