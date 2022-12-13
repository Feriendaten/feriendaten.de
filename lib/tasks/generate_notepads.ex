defmodule Mix.Tasks.GenerateNotepads do
  use Mix.Task

  @requirements ["app.start"]

  @shortdoc "Generate images of nodepads with vacation dates written on them."

  @doc """
  Generate images of nodepads with vacation dates written on them.

  To generate the images, run:

      mix generate_notepads
  """

  def run(_args) do
    start_date = ~D[2020-01-01]
    end_date = ~D[2029-12-31]

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
          all_ferientermine =
            Enum.filter(entries, fn x ->
              x.location_name == federal_state.name && x.starts_on.year == year &&
                x.colloquial == vacation
            end)
            |> Feriendaten.Calendars.all_ferientermine_to_string()

          unless all_ferientermine == "" do
            IO.puts("Generating notepad for #{vacation} #{federal_state.name} #{year}.")

            write_latex_file(dir, vacation, federal_state.name, year, all_ferientermine)

            file_name = Path.join([dir, "#{vacation}-#{federal_state.name}-#{year}"])
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

            target_dir =
              "#{Application.app_dir(:feriendaten)}/priv/static/images/notepad/#{String.downcase(vacation)}"

            target_file_name =
              "#{target_dir}/#{"#{String.downcase(vacation)}-#{String.downcase(federal_state.name)}-#{year}"}.jpeg"

            case File.mkdir(target_dir) do
              :ok ->
                File.cp(
                  "#{file_name}.jpeg",
                  target_file_name
                )

              {:error, :eexist} ->
                File.cp(
                  "#{file_name}.jpeg",
                  target_file_name
                )

              _ ->
                IO.puts("Could not create target directory #{target_dir}")
            end
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

  def write_latex_file(dir, vacation, federal_state, year, all_ferientermine) do
    file_name = Path.join([dir, "#{vacation}-#{federal_state}-#{year}.tex"])

    {:ok, file} = :file.open(file_name, [:write])
    :file.write(file, tex_file_content(vacation, federal_state, year, all_ferientermine))
  end

  def tex_file_content(vacation, federal_state, year, all_ferientermine) do
    ~S"""
    % -- Preamble:
    \documentclass{notepadnotes} % custom document class
    \textsize{34}                % text size (notepad block)
    \angle{3.55}                 % text rotation (angle in °)


    % -- Begining of the document:
    \begin{document}


    \begin{notes}
    headline\\

    all_ferientermine
    \end{notes}


    \end{document}
    """
    |> String.replace("headline", "#{vacation}\\\\#{federal_state}\\\\#{year}")
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
       \begin{minipage}[l]{9.75cm}
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
