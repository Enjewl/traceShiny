###UI
welcome_message_ui <- function(id) {
  fluidRow(
  box(id = "intro", status = "warning", solidHeader = F, collapsible = T, width = 12,
      title = strong('Welcome to TRACE'),
      h5(includeHTML("data/welcome_page/welcome_page.html")),
      br(),
      img(id="GA",src="Graphical Abstract.jpeg", width="35%"),
      h5("Select START to start fresh analysis, or Continue to load in a previous analysis."),
      fluidRow(column(3,
                      valueBox("BEGIN", actionBttn("startbuttonintro", "START",
                                                 style = "jelly",
                                                 color = "primary"),
                               icon = icon("paper-plane"), width = 12, color = "aqua")),
               column(3,
                      valueBox("CONTINUE",
                               actionBttn("continue", "CONTINUE",
                                          style = "jelly",
                                          color = "primary"),
                               icon = icon("upload"), width = 12, color = "aqua"))
      ))
  )
}


Intro <- function(input, output, session) {
observeEvent(input$startbuttonintro, {
  withProgress(message = "Getting everything ready, won't take long...", style = "old",
               value = 0, {
                 incProgress(0.1)

                 incProgress(0.2, detail = "Loading Packages")
                 library(shinyalert)
                 library(dashboardthemes)
                 library(trace)
                 library(dplyr)
                 library(assertr)
                 library(ggpubr)
                 library(tibble)
                 library(tidyr)
                 library(stringr)
                 library(readxl)
                 library(microseq)
                 library(purrr)

                 incProgress(0.8)

                 file.copy(system.file("extdata/trace_config.yaml", package = "trace"), ".")

                 shinyjs::hide("NextButtonLoad", asis = T)

                 if(input$LoadBoxIntro$collapsed == TRUE) {
                   js$collapse("LoadBoxIntro")
                 }
                 shinyjs::show("startbuttonLoad")
                 shinyjs::hide("LoadBox2")
                 shinyjs::hide("LoadBox5")
                 shinyjs::hide("LoadBox3")
                 shinyjs::hide("LoadBox4")
                 shinyjs::hide("NextButtonLoad")
                 shinyjs::hide("NextButtonLoad2")
                 shinyjs::hide("LoadBox_FASTQ1")
                 shinyjs::hide("LoadBox_FASTQ2")
                 updateRadioGroupButtons(session, "DataUpload", selected = "fsa")

                 output$dynamic_content <- renderMenu(sidebarMenu(id = "tabs",
                                                                  menuItem("Upload", icon = icon("spinner"), tabName = "Upload", selected = T,
                                                                           badgeColor = "green", badgeLabel = "new"),
                                                                  menuItem("Documentation", icon = icon("file"), startExpanded = T,
                                                                           menuSubItem("Step 1: Upload", tabName = "Documentation1"),
                                                                           menuSubItem("Step 2: Find Ladders", tabName = "Documentation2"),
                                                                           menuSubItem("Step 3: Find Peaks", tabName = "Documentation3"),
                                                                           menuSubItem("Step 4: Instability Metrics", tabName = "Documentation4"),
                                                                           menuSubItem("Step 5: Analysis", tabName = "Documentation5"))
                 ))
               })
})
}
