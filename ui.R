library(shiny)
library(shinythemes)

shinyUI(
  navbarPage(
    title = "Exploration de mtcars",
    theme = shinytheme("flatly"),  # Testez "cerulean", "cosmo", "superhero"...
    
    # 1) Onglet principal : Exploration interactive
    tabPanel(
      title = "Exploration",
      fluidPage(
        fluidRow(
          column(
            width = 12,
            h2("Analyse interactive de mtcars"),
            p("Utilisez les contrôles ci-dessous pour sélectionner les variables, ",
              "filtrer le dataset et choisir des graphiques.")
          )
        ),
        
        fluidRow(
          # Zone de gauche : inputs
          column(
            width = 3,
            wellPanel(
              h4("Choix des variables"),
              # Input : variable X
              selectInput(
                inputId = "var_x",
                label   = "Variable en abscisse (X) :",
                choices = c("Poids" = "wt",
                            "Puissance" = "hp",
                            "Cylindres" = "cyl",
                            "Consommation" = "mpg",
                            "R. Pont" = "drat"),
                selected = "wt"
              ),
              # Input : variable Y
              selectInput(
                inputId = "var_y",
                label   = "Variable en ordonnée (Y) :",
                choices = c("Consommation" = "mpg",
                            "Poids" = "wt",
                            "Puissance" = "hp",
                            "Cylindres" = "cyl",
                            "R. Pont" = "drat"),
                selected = "mpg"
              ),
              # Input : filtre sur le nombre de cylindres
              checkboxGroupInput(
                inputId = "filter_cyl",
                label   = "Filtrer par cylindre(s) :",
                choices = c("4 cylindres" = "4",
                            "6 cylindres" = "6",
                            "8 cylindres" = "8"),
                selected = c("4","6","8")
              ),
              h4("Histogramme"),
              selectInput(
                inputId = "var_hist",
                label   = "Variable pour l'histogramme :",
                choices = c("mpg", "wt", "hp", "cyl", "drat"),
                selected = "mpg"
              ),
              helpText("Choisissez la variable à représenter dans l'histogramme.")
            )
          ),
          
          # Zone de droite : différents onglets de visualisation
          column(
            width = 9,
            tabsetPanel(
              # Onglet 1 : Nuage de points
              tabPanel(
                "Nuage de points",
                br(),
                h4("Graphique : Nuage de points"),
                plotOutput("plot_mtcars", height = "400px")
              ),
              # Onglet 2 : Boxplot
              tabPanel(
                "Boxplot",
                br(),
                h4("Graphique : Boxplot"),
                plotOutput("boxplot_mtcars", height = "400px")
              ),
              # Onglet 3 : Histogramme
              tabPanel(
                "Histogramme",
                br(),
                h4("Graphique : Histogramme"),
                plotOutput("hist_mtcars", height = "400px")
              ),
              # Onglet 4 : Pairs Plot
              tabPanel(
                "Pairs Plot",
                br(),
                h4("Matrice de dispersion"),
                plotOutput("pairs_mtcars", height = "500px")
              ),
              # Onglet 5 : Résumé Statistique (découpé en 3 sous-tableaux)
              tabPanel(
                "Résumé Statistique",
                br(),
                h4("Table de résumé - découpée en 3 sections"),
                fluidRow(
                  style = "font-size:6px;",
                  column(4, tableOutput("summary_table1")),
                  column(4, tableOutput("summary_table2")),
                  column(4, tableOutput("summary_table3"))
                )
                
              )
            )
          )
        )
      )
    ),
    
    # 2) Onglet Documentation
    tabPanel(
      title = "Documentation",
      fluidPage(
        # On peut agrandir la taille du texte ici :
        tags$head(
          tags$style(HTML("
            .docText {
              font-size: 18px;
              line-height: 1.6;
            }
            h2.docTitle {
              font-size: 28px; 
              font-weight: bold;
            }
          "))
        ),
        fluidRow(
          column(
            width = 8,
            h2("Mode d'emploi de l'application", class = "docTitle"),
            div(class = "docText",
                p("Cette application permet une exploration interactive du jeu de données ",
                  "'mtcars'. Les fonctionnalités :"),
                tags$ul(
                  tags$li(
                    strong("Choix X/Y :"),
                    "Sélectionnez la variable pour l'axe des abscisses et celle ",
                    "pour l'axe des ordonnées (Nuage de points)."
                  ),
                  tags$li(
                    strong("Filtre cylindre :"),
                    "Pour n'afficher que certaines voitures (4, 6 ou 8 cylindres)."
                  ),
                  tags$li(
                    strong("Histogramme :"),
                    "Choisissez la variable à afficher en histogramme."
                  ),
                  tags$li(
                    strong("Boxplot :"),
                    "Le boxplot compare la variable Y en fonction du nombre de cylindres."
                  ),
                  tags$li(
                    strong("Pairs Plot :"),
                    "Visualisez la matrice de dispersion pour toutes les variables."
                  ),
                  tags$li(
                    strong("Résumé Statistique :"),
                    "Les principales mesures (Min, 1er quartile, Médiane, etc.) ",
                    "pour toutes les variables, organisées en trois tableaux."
                  )
                ),
                p("Le code complet est disponible sur GitHub, vous pouvez le cloner, ",
                  "installer les packages nécessaires (shiny, shinythemes, dplyr, ggplot2) ",
                  "et lancer l'appli directement.")
            )
          )
        )
      )
    )
  )
)
