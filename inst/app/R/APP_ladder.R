ladder_box_ui1 <- function(id) {
  box(id = "LadderBoxIntro", title = strong("Find Ladders"), status = "warning", solidHeader = F,
      collapsible = T, collapsed = T, width = 12,

      h5(includeHTML("data/find_ladders/find_ladders_landing_page.html")),
      img(id="pipe2",src="pipeline2.jpg", width="20%"),
      br(),
      br(),

      fluidRow(column(3,
                      valueBox("PROCEED", actionBttn("LadderBoxSTART", "START",
                                                 style = "jelly",
                                                 color = "primary"), icon = icon("paper-plane"), width = 12, color = "aqua"))
      ))
}

ladder_box_ui2 <- function(id) {
  box(id = "LadderBox1", title = p("Settings", help_button("ladder_params")), status = "warning", solidHeader = F,
      collapsible = T, width = NULL,

      materialSwitch("advancesettings_Ladder", label = h5(HTML('<h5 style = "text-align:justify;color:#000000">Show Advanced Settings')), value = FALSE, status = "primary"),

      pickerInput("LadderSizes", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Ladder Sizes')), choices = NULL),

      materialSwitch("spikeswitch", label = h5(HTML('<h5 style = "text-align:justify;color:#000000">Use Default Ladder Scan Position')), value = TRUE, status = "primary"),

      conditionalPanel(
        condition = 'input.spikeswitch == false',
        numericInput("spikelocation", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-60px;">Input Ladder Starting Scan Position')),
                     min = 1,
                     value = 1, step = 1)
      ),

      conditionalPanel(
        condition = 'input.advancesettings_Ladder == true',

        materialSwitch("minimum_peak_signal_ladder", label = h5(HTML('<h5 style = "text-align:justify;color:#000000">Use Default Minimum Peak Signal')), value = TRUE, status = "primary"),

        conditionalPanel(
          condition = 'input.minimum_peak_signal_ladder == false',
          numericInput("minimum_peak_signal_number", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-60px;">Input Minimal Peak Signal')),
                       min = 1,
                       value = 1, step = 1)
        ),

        materialSwitch("scan_subset", label = h5(HTML('<h5 style = "text-align:justify;color:#000000">Use Default Scan Subset')), value = TRUE, status = "primary"),

        conditionalPanel(
          condition = 'input.scan_subset == false',

          fluidRow(
            column(12,
            h5(HTML('<h5 style = "text-align:left;color:#000000"><br>Scan Subset Input'))
            )
          ),

          fluidRow(
            column(6,
                   numericInput("scan_subset1", label = h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">From')),
                                value = 0.5,
                                min = 0,
                                step = 0.1)),
            column(6,
                   numericInput("scan_subset2", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">To')),
                                min = 0,
                                value = 0.95, step = 0.1))
          )
        ),

        materialSwitch("ladder_assign_left_to_right", label = h5(HTML('<h5 style = "text-align:justify;color:#000000">Assign Ladder Left to Right')), value = TRUE, status = "primary"),

        numericInput("ladderselectionwindow", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Ladder Selection Window')),
                     min = 1,
                     value = 5, step = 1),

        numericInput("ladder_top_n_branching", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Ladder Branching')),
                     min = 1,
                     value = 5, step = 1),

        numericInput("maxcombinations", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Max Combinations')),
                     min = 1,
                     value = 2500000, step = 1),
      ),

      p(style="text-align: center;", actionBttn("startbuttonFindLadders", "APPLY", size = "lg"))
  )
}

ladder_box_ui3 <- function(id) {
  box(id = "LadderBox2", title = p("Interactive Ladder Fixing", help_button("ladder_fixing")),
      status = "warning", solidHeader = F,
      collapsible = T, width = NULL,

      fluidRow(
        column(6,
               pickerInput("unique_id_selection", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Sample Selection')), choices = NULL)
        ),
        column(1,
               actionButton("up_ladder", NULL, icon("arrow-up"), style='text-align: left; margin-top:50px; font-size:200%'),
               br(),
               actionButton("down_ladder", NULL, icon("arrow-down"), style='text-align: left; margin-top:-20px; font-size:200%')),
        column(3,
               prettySwitch("warning_checkbox", "Select only samples with ladder warnings",
                            value = FALSE, fill = T, status = "success", inline = T)
        ),
        column(3,
               sliderInput("rsq_limit", HTML('<h5 style = "text-align:justify; margin-top:-50px;">r-squared threshold for warning (see table below)'),
                           min = 0.9, max = 1,
                           value = 0.998, step = 0.001))
      ),

      fluidRow(
        column(6,
               sliderInput("find_scan_max", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Snap to tallest scan window')),
                           min = 1, max = 50,
                           value = 10, step = 1)
        ),
        column(6,
               sliderInput("HeightLadder", h5(HTML('<h5 style = "text-align:justify;color:#000000; margin-top:-50px;">Select Plot Height')),
                           min = 1, max = 100,
                           value = 20, step = 1)
        )
      ),
      htmlOutput("text_no_data1"),
      withSpinner(htmlOutput("plotUI")),

      br(),

      fluidRow(
        column(6,
               htmlOutput("laddertext1"),
               p(style="text-align: right;", downloadButton("laddertext1_download"))
        ),
        column(6,
               htmlOutput("laddertext2"),
               p(style="text-align: right;", downloadButton("laddertext2_download"))
        )
      ),

      fluidRow(
        column(6,
               dataTableOutput("rsq_table")),
        column(6,
               dataTableOutput("ladder_summary"))
      )
  )
}


ladder_server <- function(input, output, session, upload_data, continue_module) {
  # help files
  help_click("ladder_params", helpfile = "data/find_ladders/ladder_params.html")

  help_click("ladder_fixing", helpfile = "data/find_ladders/Interactive_ladder_fixing.html")

  fragment_trace_list_reactive <- shiny::reactiveValues()
  manual_ladder_list <- shiny::reactiveValues()
  reactive_ladder <- reactiveValues()
  relayout_data <- shiny::reactiveVal(NULL)
  fragment_ladder_trigger <- shiny::reactiveVal(0)

  # Initialize ladders as NULL
  ladders <- shiny::reactiveValues()

  #Load saved objects if applicable
  observe({
    reactive_ladder$ladder <- continue_module$ladders()
    ladders$scan <- continue_module$scan()
    ladders$size <- continue_module$size()
    reactive_ladder$config <- continue_module$config()
  })

  observeEvent(ignoreInit = F, list(input$MetadataUpload, input$SelectionButton, input$DataFSA, input$fastq, input$fileinputLOAD), {
    reactive_ladder$ladder <- NULL
    ladders$scan <- NULL
    ladders$size <- NULL
    reactive_ladder$config <- NULL
  })

  #Download
  output$laddertext1_download <- shiny::downloadHandler(
    filename = function() {
      paste0(format(Sys.time(), "%Y-%m-%d_%H%M%S"), "_Rsq_table.csv")
    },
    content = function(file) {
      write.csv(rsq_table(), file, row.names = F, col.names = T)
    }
  )

  output$laddertext2_download <- shiny::downloadHandler(
    filename = function() {
      paste0(format(Sys.time(), "%Y-%m-%d_%H%M%S"), "_Ladder_summary.csv")
    },
    content = function(file) {
      df <- trace::extract_ladder_summary(reactive_ladder$ladder)

      rownames(df) <- NULL
      write.csv(df, file, row.names = F, col.names = T)
    }
  )

  observeEvent(input$NextButtonLoad, {

    reactive_ladder$ladder <- NULL
    ladders$scan <- NULL
    ladders$size <- NULL

    if (is.null(upload_data$metadata_table())) {
      shinyalert("WARNING!", "No metadata was loaded!", type = "warning", confirmButtonCol = "#337ab7")
    }

    if (is.null(upload_data$metadata_table())) {
      updatePickerInput(session, "sample_subset_metrics", choices = names(upload_data$fsa_list()))
    }
    else if (!is.null(upload_data$metadata_table())) {
      if (any(grepl("TRUE", upload_data$metadata_table()$metrics_baseline_control))) {
        if (input$group_controls == TRUE) {
        updatePickerInput(session, "sample_subset_metrics", choices = upload_data$metadata_table()[-which(upload_data$metadata_table()$metrics_baseline_control == TRUE),]$unique_id)
        }
        else {
          updatePickerInput(session, "sample_subset_metrics", choices = upload_data$metadata_table()$unique_id)
        }
      }
      else {
        updatePickerInput(session, "sample_subset_metrics", choices = upload_data$metadata_table()$unique_id)
      }
    }

    shinyjs::hide("NextButtonLoad")

    if(input$LadderBoxIntro$collapsed == TRUE) {
      js$collapse("LadderBoxIntro")
    }

    shinyjs::hide("LadderBox1")
    shinyjs::hide("LadderBox2")
    shinyjs::hide("NextButtonLadder")

    output$dynamic_content <- renderMenu(sidebarMenu(id = "tabs",
                                                     menuItem("Upload", icon = icon("spinner"), tabName = "Upload"),
                                                     menuItem("Find Ladders", icon = icon("water-ladder"), tabName = "FindLadders", selected = T,
                                                              badgeColor = "green", badgeLabel = "new"),
                                                     menuItem("Documentation", icon = icon("file"), startExpanded = T,
                                                              menuSubItem("Step 1: Upload", tabName = "Documentation1"),
                                                              menuSubItem("Step 2: Find Ladders", tabName = "Documentation2"),
                                                              menuSubItem("Step 3: Find Peaks", tabName = "Documentation3"),
                                                              menuSubItem("Step 4: Instability Metrics", tabName = "Documentation4"),
                                                              menuSubItem("Step 5: Analysis", tabName = "Documentation5"))
    ))
  })

  observeEvent(input$LadderBoxSTART, {

    shinyjs::hide("NextButtonLoad")

    if(input$LadderBoxIntro$collapsed == FALSE) {
      js$collapse("LadderBoxIntro")
    }
    shinyjs::show("LadderBox1")
    shinyjs::show("LadderBox2")
    shinyjs::hide("NextButtonLadder")

    reactive_ladder$ladder <- NULL
    ladders$scan <- NULL
    ladders$size <- NULL

    updatePickerInput(session, 'LadderSizes', choices = upload_data$laddertable()$Ladder_ID)
    updatePickerInput(session, "unique_id_selection", choices = names(upload_data$fsa_list()))

    output$dynamic_content <- renderMenu(sidebarMenu(id = "tabs",
                                                     menuItem("Upload", icon = icon("spinner"), tabName = "Upload"),
                                                     menuItem("Find Ladders", icon = icon("water-ladder"), tabName = "FindLadders", selected = T),
                                                     menuItem("Documentation", icon = icon("file"), startExpanded = T,
                                                              menuSubItem("Step 1: Upload", tabName = "Documentation1"),
                                                              menuSubItem("Step 2: Find Ladders", tabName = "Documentation2"),
                                                              menuSubItem("Step 3: Find Peaks", tabName = "Documentation3"),
                                                              menuSubItem("Step 4: Instability Metrics", tabName = "Documentation4"),
                                                              menuSubItem("Step 5: Analysis", tabName = "Documentation5"))
    ))
  })

  observe({
    updatePickerInput(session, 'LadderSizes', choices = upload_data$laddertable()$Ladder_ID)
  })


  observeEvent(input$startbuttonFindLadders, {
    tryCatch({
      withProgress(message = 'Finding Ladders ...', style = "old",
                   value = 0, {
                     incProgress(0.1)

                     ladders$scan <- NULL
                     ladders$size <- NULL

                     reactive_ladder$ladder <- lapply(upload_data$fsa_list(), function(x) x$clone())

                     reactive_ladder$config <- load_config()

                     reactive_ladder$config$ladder_channel <- input$LadderChannel
                     reactive_ladder$config$signal_channel <- input$SignalChannel
                     reactive_ladder$config$ladder_sizes = as.numeric(strsplit(upload_data$laddertable()[which(upload_data$laddertable() == input$LadderSizes),]$Expected_ladder_peaks, split = ",")[[1]])
                     reactive_ladder$config$ladder_start_scan <- if(input$spikeswitch == T) NA else input$spikelocation
                     reactive_ladder$config$minimum_ladder_signal <- if(input$minimum_peak_signal_ladder == T) NA else input$minimum_peak_signal_number
                     reactive_ladder$config$ladder_assign_left_to_right <- input$ladder_assign_left_to_right
                     reactive_ladder$config$min_scan <- if(input$scan_subset == T) NA else input$scan_subset1
                     reactive_ladder$config$max_scan <- if(input$scan_subset == T) NA else input$scan_subset2
                     reactive_ladder$config$ladder_top_n_branching <- input$ladder_top_n_branching
                     reactive_ladder$config$ladder_selection_window <- input$ladderselectionwindow
                     reactive_ladder$config$max_combinations <- input$maxcombinations

                     reactive_ladder$scan_subset <- input$scan_subset

                     trace:::find_ladders(reactive_ladder$ladder, reactive_ladder$config,
                                         show_progress_bar = FALSE)

                     ladders$scan <- reactive_ladder$ladder[[input$unique_id_selection]]$ladder_df$scan
                     ladders$size <- reactive_ladder$ladder[[input$unique_id_selection]]$ladder_df$size

                     shinyjs::show("NextButtonLadder")

                     if(input$PeaksBoxIntro$collapsed == TRUE) {
                       js$collapse("PeaksBoxIntro")
                     }
                     shinyjs::hide("PeaksBox1")
                     shinyjs::hide("PeaksBox2")
                     shinyjs::hide("PeaksBox3")
                     shinyjs::hide("PeaksBox4")
                     shinyjs::hide("NextButtonPeaks")

                     output$dynamic_content <- renderMenu(sidebarMenu(id = "tabs",
                                                                      menuItem("Upload", icon = icon("spinner"), tabName = "Upload"),
                                                                      menuItem("Find Ladders", icon = icon("water-ladder"), tabName = "FindLadders", selected = T),
                                                                      menuItem("Find Peaks", icon = icon("mountain"), tabName = "FindPeaks", selected = F,
                                                                               badgeColor = "green", badgeLabel = "new"),
                                                                      menuItem("Documentation", icon = icon("file"), startExpanded = T,
                                                                               menuSubItem("Step 1: Upload", tabName = "Documentation1"),
                                                                               menuSubItem("Step 2: Find Ladders", tabName = "Documentation2"),
                                                                               menuSubItem("Step 3: Find Peaks", tabName = "Documentation3"),
                                                                               menuSubItem("Step 4: Instability Metrics", tabName = "Documentation4"),
                                                                               menuSubItem("Step 5: Analysis", tabName = "Documentation5"))))
                   })
    },
    error = function(e) {
      shinyalert("ERROR!", e$message, type = "error", confirmButtonCol = "#337ab7")
      reactive_ladder$ladder <- NULL
    })
  })

  shiny::observe({
    if (!is.null(reactive_ladder$ladder)) {
      if (input$warning_checkbox == T) {
        warning_list <- list()

        for (i in 1:length(names(reactive_ladder$ladder))) {
          warning_list[[i]] <- ladder_rsq_warning_helper(reactive_ladder$ladder[[i]], input$rsq_limit)
        }

        if (length(warning_list) == 0) {
          updatePickerInput(session, "unique_id_selection",
                            choices = names(reactive_ladder$ladder)
          )
          shinyalert("Success!", "No samples have badly fitting ladders", type = "success", confirmButtonCol = "#337ab7")
          updatePrettySwitch(session, "warning_checkbox", value = FALSE)
        }
        else {
          updatePickerInput(session, "unique_id_selection",
                            choices = names(reactive_ladder$ladder)[which(names(reactive_ladder$ladder) %in% unlist(warning_list))]
          )
        }
      }
      else {
        updatePickerInput(session, "unique_id_selection", choices = names(upload_data$fsa_list()))
      }
    }
  })

  # Reset ladders and relayout_data when unique_id_selection changes
  shiny::observeEvent(input$unique_id_selection, {
    ladders$scan <- NULL
    ladders$size <- NULL
    relayout_data(NULL) # Initialize relayout_data
  })

  shiny::observe({
    if (is.null(reactive_ladder$ladder)) {
      if (input$warning_checkbox == T) {
        shinyalert("ERROR!", "Please run your analysis first", type = "error", confirmButtonCol = "#337ab7")
        updatePrettySwitch(session, "warning_checkbox", value = FALSE)
      }
    }
  })

  shiny::observe({
    if (!is.null(input$unique_id_selection)) {
      if (!is.null(reactive_ladder$ladder)) {
        ladders$scan <- reactive_ladder$ladder[[input$unique_id_selection]]$ladder_df$scan
        ladders$size <- reactive_ladder$ladder[[input$unique_id_selection]]$ladder_df$size
      }
    }
  })

  # Reset relayout_data when plot is clicked or dragged
  shiny::observeEvent(plotly::event_data("plotly_relayout"), {
    relayout_data(plotly::event_data("plotly_relayout"))
  })

  output$plotUI <- renderUI({
    plotlyOutput("plot", height = (300 + input$HeightLadder*20))
  })

  output$plot <- plotly::renderPlotly({
    if (is.null(ladders$scan) || is.null(ladders$size)) {
      # Return a blank plot if ladders are not initialized
      return(plotly::plot_ly())
    }

    shapes_with_labels <- list()
    text_annotations <- list()
    for (i in 1:length(ladders$scan)) {
      shapes_with_labels[[i]] <- list(
        type = "line",
        x0 = ladders$scan[i], # Adjust as needed for the positions of your shapes
        x1 = ladders$scan[i], # Adjust as needed for the positions of your shapes
        y0 = 0.05,
        y1 = 0.45,
        yref = "paper",
        fillcolor = "rgba(0,0,0,0)", # Transparent fill
        line = list(
          color = "black",
          width = 1
        ),
        editable = TRUE # Allow shape editing
      )

      # Add text annotation
      text_annotations[[i]] <- list(
        x = ladders$scan[i], # X-position of the text
        y = max(reactive_ladder$ladder[[input$unique_id_selection]]$trace_bp_df$ladder_signal) / 2, # Adjust Y-position as needed
        text = ladders$size[i],
        showarrow = FALSE, # Remove arrow if not desired
        textanchor = "end", # Horizontal text alignment
        yanchor = "middle", # Vertical text alignment
        font = list(
          color = "black",
          size = 10
        ),
        textangle = 270
      )
    }

    p <- plotly::plot_ly(reactive_ladder$ladder[[input$unique_id_selection]]$trace_bp_df, x = ~scan, y = ~ladder_signal, type = "scatter", mode = "lines",
                         height = 300 + input$HeightLadder*20)
    p <- plotly::layout(p, shapes = shapes_with_labels, annotations = text_annotations, title = reactive_ladder$ladder[[input$unique_id_selection]]$unique_id)
    # allow to edit plot by dragging lines
    plotly::config(p, edits = list(shapePosition = TRUE))
  })

  # Capture relayout_data
  shiny::observe({
    if (!is.null(relayout_data())) {
      ed <- relayout_data()
      scan_positions <- ed[grepl("^shapes.*x.*", names(ed))]
      if (length(scan_positions) != 2) {
        return()
      }
      row_index <- unique(as.numeric(sub(".*\\[(.*?)\\].*", "\\1", names(scan_positions)[1])) + 1)

      # find maximal signal in the user defined region
      selected_scan <- round(as.numeric(scan_positions))[1]
      window_df <- reactive_ladder$ladder[[input$unique_id_selection]]$trace_bp_df[which(reactive_ladder$ladder[[input$unique_id_selection]]$trace_bp_df$scan > selected_scan - input$find_scan_max & reactive_ladder$ladder[[input$unique_id_selection]]$trace_bp_df$scan < selected_scan + input$find_scan_max), ]
      new_scan <- window_df[which(window_df$ladder_signal == max(window_df$ladder_signal)), "scan"]

      # assign scan
      ladders$scan[row_index] <- new_scan[1]
    }
  })

  rsq_table <- shiny::reactive({
    fragment_ladder_trigger()  # Trigger reactivity with fragment_ladder_trigger

    cor_list <- trace:::ladder_fit_cor(reactive_ladder$ladder[[input$unique_id_selection]])
    rsq <- sapply(cor_list, function(x) x$rsq)
    size_ranges <- sapply(cor_list, function(x) x$size_ranges)
    size_ranges_vector <- vector("numeric", ncol(size_ranges))
    for (j in seq_along(size_ranges_vector)) {
      size_ranges_vector[j] <- paste0(size_ranges[1, j], ", ", size_ranges[2, j], ", ", size_ranges[3, j])
    }

    data.frame(
      sizes = size_ranges_vector,
      r_squared = as.character(round(rsq, digits = 4))
    )

  })

  output$rsq_table <- DT::renderDataTable({
    validate(
      need(!is.null(reactive_ladder$ladder), 'You must run the analysis first'))

    ## Colour and values for table colour formatting
    brks <- seq(0.5, 1, .001)
    clrs <- colorRampPalette(c("red", "white", "green"))(length(brks) + 1)

    datatable(rsq_table(),
              options = list(scrollX = TRUE,
                             scrollY = TRUE,
                             server = TRUE,
                             paging = TRUE,
                             pageLength = 15
              ),
              selection = 'single',
              rownames = FALSE) %>%
      formatStyle(c("r_squared"), backgroundColor = styleInterval(brks, clrs))
  })

  output$ladder_summary <- DT::renderDataTable({
    validate(
      need(!is.null(reactive_ladder$ladder), 'You must run the analysis first'))

    df <- trace::extract_ladder_summary(reactive_ladder$ladder)

    rownames(df) <- NULL

    datatable(df,
              options = list(scrollX = TRUE,
                             scrollY = TRUE,
                             server = TRUE,
                             paging = TRUE,
                             pageLength = 15
              ),
              selection = 'single',
              rownames = FALSE)
  })

  output$laddertext1 <- renderUI({
    h5(HTML('<h5 style = "text-align:justify;color:#000000"><b>Ladder R-squared Table (check this to see how well the ladder has fitted)</b>'))
  })

  output$laddertext2 <- renderUI({
    h5(HTML('<h5 style = "text-align:justify;color:#000000"><b>Ladder Summary Table</b>'))
  })

  observeEvent(input$ladder_summary_rows_selected, {
    updatePickerInput(session, "unique_id_selection", selected = upload_data$fsa_list()[[input$ladder_summary_rows_selected]]$unique_id)
  })

  observeEvent(input$up_ladder, {
    tryCatch({
      updatePickerInput(session, "unique_id_selection", selected = if (which(names(upload_data$fsa_list()) == input$unique_id_selection) - 1 == 0)
        upload_data$fsa_list()[[which(names(upload_data$fsa_list()) == input$unique_id_selection)]]$unique_id
        else upload_data$fsa_list()[[which(names(upload_data$fsa_list()) == input$unique_id_selection) - 1]]$unique_id)
    },
    error = function(e) {
      shinyalert("ERROR!", "You've reached the end of the selection, please go the other way!", type = "error", confirmButtonCol = "#337ab7")
    })
  })

  observeEvent(input$down_ladder, {
    tryCatch({
      updatePickerInput(session, "unique_id_selection", selected = if (which(names(upload_data$fsa_list()) == input$unique_id_selection) + 1 > length(names(upload_data$fsa_list())))
        upload_data$fsa_list()[[which(names(upload_data$fsa_list()) == input$unique_id_selection)]]$unique_id
        else upload_data$fsa_list()[[which(names(upload_data$fsa_list()) == input$unique_id_selection) + 1]]$unique_id)
    },
    error = function(e) {
      shinyalert("ERROR!", "You've reached the end of the selection, please go the other way!", type = "error", confirmButtonCol = "#337ab7")
    })
  })

  #have a reactive list that gets updated when you change the stuff
  shiny::observe({
    if (!is.null(input$unique_id_selection)) {
      if (!is.null(ladders$size)) {
        sample_unique_id <- reactive_ladder$ladder[[input$unique_id_selection]]$unique_id

        selected_ladder_df <- reactive_ladder$ladder[[input$unique_id_selection]]$ladder_df
        selected_sample_scans <- selected_ladder_df[which(!is.na(selected_ladder_df$size)), "scan"]

        plot_ladder_df <- as.data.frame(shiny::reactiveValuesToList(ladders))
        plot_scans <- plot_ladder_df[which(!is.na(plot_ladder_df$size)), "scan"]

        # skip if ladder info hasn't been updated
        if (identical(selected_sample_scans, plot_scans)) {
          return()
        } else if (nrow(as.data.frame(shiny::reactiveValuesToList(ladders))) == 0) {
          return()
        }
        manual_ladder_list[[sample_unique_id]] <- as.data.frame(shiny::reactiveValuesToList(ladders))

        trace:::fix_ladders_manual(
          reactive_ladder$ladder[sample_unique_id],
          shiny::reactiveValuesToList(manual_ladder_list)[sample_unique_id]
        )

        fragment_ladder_trigger(fragment_ladder_trigger() + 1)
      }
    }
  })

  observe({
    if (is.null(ladders$scan) || is.null(ladders$size)) {
      shinyjs::show("text_no_data1")
      shinyjs::hide("rsq_table")
      shinyjs::hide("ladder_summary")
      shinyjs::hide("laddertext1")
      shinyjs::hide("laddertext2")
      shinyjs::hide("laddertext1_download")
      shinyjs::hide("laddertext2_download")
    }
    else {
      shinyjs::hide("text_no_data1")
      shinyjs::show("rsq_table")
      shinyjs::show("ladder_summary")
      shinyjs::show("laddertext1")
      shinyjs::show("laddertext2")
      shinyjs::show("laddertext1_download")
      shinyjs::show("laddertext2_download")
    }
  })

  output$text_no_data1 <- renderUI({
    h3(HTML('<b><h3 style = "text-align:justify;color:#FF0000">Please select your inputs and press apply to start analysis.</b>'))
  })

  return(list(
    ladders = reactive(reactive_ladder$ladder),
    config = reactive(reactive_ladder$config),
    spikeswitch = reactive(reactive_ladder$spikeswitch),
    minimum_peak_signal_ladder = reactive(reactive_ladder$minimum_peak_signal_ladder),
    scan_subset = reactive(reactive_ladder$scan_subset),
    scan = reactive(ladders$scan),
    size = reactive(ladders$size)
  ))

}
