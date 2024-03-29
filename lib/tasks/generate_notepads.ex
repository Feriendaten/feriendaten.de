defmodule Mix.Tasks.GenerateNotepads do
  use Mix.Task

  @requirements ["app.start"]

  @shortdoc "Generate images of notepads with vacation dates written on them."

  @doc """
  Generate images of notepads with vacation dates written on them.

  To generate the images, run:

      mix generate_notepads
  """

  def run(_args) do
    start_date = ~D[2022-01-01]
    end_date = ~D[2025-12-31]

    entries =
      Feriendaten.Calendars.school_vacation_periods_for_germany(
        start_date,
        end_date
      )

    federal_states =
      entries
      |> Enum.map(fn l -> %{name: l.location_name, slug: l.location_slug} end)
      |> Enum.uniq()
      |> Enum.sort()

    vacations =
      entries
      |> Enum.map(fn l -> l.colloquial end)
      |> Enum.uniq()
      |> Enum.sort()

    dir = "/tmp/feriendaten.de-tmp"

    case File.mkdir(dir <> "/Figures") do
      :ok ->
        write_all_files(dir, vacations, federal_states, start_date, end_date, entries)

      {:error, :eexist} ->
        write_all_files(dir, vacations, federal_states, start_date, end_date, entries)

      _ ->
        IO.puts("Could not create directory #{dir}")
    end
  end

  def write_all_files(dir, vacations, federal_states, start_date, end_date, entries) do
    write_notepadnotes_file(dir)
    copy_notepad_background_image(dir)

    for year <- start_date.year..end_date.year do
      for federal_state <- federal_states do
        for vacation <- vacations do
          compressed_entries =
            Enum.filter(entries, fn x ->
              x.location_name == federal_state.name && x.starts_on.year == year &&
                x.colloquial == vacation
            end)
            |> Feriendaten.Calendars.compress_ferientermine()

          unless length(compressed_entries) == 0 do
            [compressed_entry | _] = compressed_entries
            IO.puts("Generating notepad for #{vacation} #{federal_state.name} #{year}.")
            # IO.puts(inspect(compressed_entry))

            head_file_name = "#{compressed_entry.vacation_slug}-#{federal_state.slug}-#{year}"
            file_name = Path.join([dir, head_file_name])

            write_latex_file(
              dir,
              vacation,
              federal_state.name,
              year,
              compressed_entry,
              file_name <> ".tex"
            )

            IO.puts("#{file_name}.tex")
            IO.puts("\n")
            _output_pdflatex = System.cmd("pdflatex", ["#{file_name}.tex"], cd: dir)

            _output_convert =
              System.cmd(
                "convert",
                [
                  "-interlace",
                  "plane",
                  "-sampling-factor",
                  "2x2",
                  "-resize",
                  "1200x",
                  "-strip",
                  "-crop",
                  "650x650+400+70",
                  "-quality",
                  "85%",
                  "#{file_name}.pdf",
                  "#{file_name}.jpeg"
                ],
                cd: dir
              )

            _output_16_9_convert =
              System.cmd(
                "convert",
                [
                  "-interlace",
                  "plane",
                  "-sampling-factor",
                  "2x2",
                  "-resize",
                  "1200x",
                  "-strip",
                  "-crop",
                  "1200x675+0+55",
                  "-quality",
                  "85%",
                  "#{file_name}.pdf",
                  "#{file_name}-16-9.jpeg"
                ],
                cd: dir
              )

            target_dir =
              if Mix.env() == :prod do
                "/home/feriendaten/app/feriendaten.de/priv/static/images/notepad/#{compressed_entry.vacation_slug}"
              else
                "#{Application.app_dir(:feriendaten)}/priv/static/images/notepad/#{compressed_entry.vacation_slug}"
              end

            target_file_name = "#{target_dir}/#{head_file_name}.jpeg"
            target_file_name_19_9 = "#{target_dir}/#{head_file_name}-16-9.jpeg"

            case File.mkdir(target_dir) do
              :ok ->
                File.cp(
                  "#{file_name}.jpeg",
                  target_file_name
                )

                File.cp(
                  "#{file_name}-16-9.jpeg",
                  target_file_name_19_9
                )

              {:error, :eexist} ->
                File.cp(
                  "#{file_name}.jpeg",
                  target_file_name
                )

                File.cp(
                  "#{file_name}-16-9.jpeg",
                  target_file_name_19_9
                )

              _ ->
                IO.puts("Could not create target directory #{target_dir}")
            end

            File.rm_rf("#{file_name}.jpeg")
            File.rm_rf("#{file_name}-16-9.jpeg")
            File.rm_rf("#{file_name}.pdf")
            File.rm_rf("#{file_name}.log")
            File.rm_rf("#{file_name}.tex")
            File.rm_rf("#{file_name}.aux")
            :timer.sleep(150)
          end
        end
      end
    end
  end

  def write_notepadnotes_file(dir) do
    path = Path.join([dir, "notepadnotes.cls"])

    {:ok, file} = :file.open(path, [:write])
    :file.write(file, notepadnotes_content())
  end

  def write_latex_file(_dir, vacation, federal_state, year, compressed_entry, file_name) do
    {:ok, file} = :file.open(file_name, [:write])

    :file.write(
      file,
      tex_file_content(vacation, federal_state, year, compressed_entry)
    )
  end

  def tex_file_content(vacation, federal_state, year, compressed_entry) do
    all_ferientermine =
      if compressed_entry[:days] < 2 do
        compressed_entry[:ferientermin]
      else
        compressed_entry[:ferientermin] <> "\\\\\n\n#{compressed_entry[:days]} Tage"
      end
      |> String.replace("01.", "1.")
      |> String.replace("02.", "2.")
      |> String.replace("03.", "3.")
      |> String.replace("04.", "4.")
      |> String.replace("05.", "5.")
      |> String.replace("06.", "6.")
      |> String.replace("07.", "7.")
      |> String.replace("08.", "8.")
      |> String.replace("09.", "9.")
      |> Feriendaten.Calendars.replace_last_comma_with_und()

    headline =
      "#{vacation}\\\\#{federal_state} #{year}"
      |> String.replace("Weihnachtsferien", "Weihnachts\\-ferien")
      |> String.replace("Winterferien", "Winter\\-ferien")
      |> String.replace("Sommerferien", "Sommer\\-ferien")
      |> String.replace("Herbstferien", "Herbst\\-ferien")
      |> String.replace("Pfingstferien", "Pfingst\\-ferien")
      |> String.replace("Himmelfahrtsferien", "Himmel\\-fahrts\\-ferien")
      |> String.replace("Frühjahrsferien", "Früh\\-jahrs\\-ferien")
      |> String.replace("Osterferien", "Oster\\-ferien")

    ~S"""
    % -- Preamble:
    \documentclass{notepadnotes} % custom document class
    \textsize{40}                % text size (notepad block)
    \angle{3.55}                 % text rotation (angle in °)
    \hyphenation{Weihnachts-ferien Sommer-ferien Winter-ferien Oster-ferien Sommer-ferien Herbst-ferien Saarland Hamburg Hessen Bayern Rheinland Berlin Sachsen Anhalt Württemberg} % hyphenation


    % -- Begining of the document:
    \begin{document}


    \begin{notes}
    headline\\

    all_ferientermine
    \end{notes}


    \end{document}
    """
    |> String.replace("headline", headline)
    |> String.replace("all_ferientermine", all_ferientermine)
  end

  def notepadnotes_content() do
    ~S"""
    % -- Class identification:
    \NeedsTeXFormat{LaTeX2e}
    \LoadClass[12pt]{article}

    \ProvidesClass{notepadnotes}[2022/12/09 Notepad Notes: LaTeX custom class]

    % -- Formatting:
    \RequirePackage[paperheight=9.67in,paperwidth=14.5in,margin=1in]{geometry}
    \RequirePackage{eso-pic,graphicx}
    \RequirePackage[utf8]{inputenc}
    \RequirePackage[T1]{fontenc}
    \RequirePackage{aurical}
    \RequirePackage[english,ngerman]{babel}
    \RequirePackage{setspace}
    \doublespacing
    \setlength{\parindent}{0pt}
    \setlength{\parskip}{6pt}
    \RequirePackage{rotating}

    % -- LaTeX macros:

     % % Defining variables % %
     % --- text size:
     \def \textsize#1{\def\@textsize{#1}}
     \def \@textsize {}

      % --- text rotation (angle):
     \def \angle#1{\def\@angle{#1}}
     \def \@angle {}

     % % environment to write on the notepad % %
     \newenvironment{notes}
     {
       \vspace*{2.25cm} \hspace*{15cm}
       \begin{turn}{\@angle}
       \begin{minipage}[l]{10.8cm}
         \fontfamily{augie}\selectfont
     }
     {
           \bfseries
       \end{minipage}
       \end{turn}
     }

     % % To apply the figure back
     \AtBeginDocument{
       \AddToShipoutPictureBG*{\includegraphics[width=\paperwidth,height=\paperheight]{Figures/notepad-background.jpg}}

       \fontsize{\@textsize}{30}\selectfont
     }

     % -- Alternative fonts:
     % % augie
         %\fontfamily{augie}\selectfont

     % % pbsei
         %\usepackage{pbsi}
         %\bsifamily
    """
  end

  def copy_notepad_background_image(dir) do
    File.cp(
      "#{Application.app_dir(:feriendaten)}/priv/latex/figures/notepad-background.jpg",
      dir <> "/Figures/notepad-background.jpg"
    )
  end
end
