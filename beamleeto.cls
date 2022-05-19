\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{beamleeto}[2022/05/16 Not Ugly Simple Presentations]

\DeclareOption{twocolumn}{\OptionNotUsed}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

\RequirePackage{graphicx}
\RequirePackage{geometry}
\RequirePackage{fontsize}
\RequirePackage{varwidth}
\RequirePackage{etoolbox}
\RequirePackage{catchfile}

% Size of the slide
\geometry{
    paperwidth=6.4 in,
    paperheight=4.4 in,
    total={6in, 4in},
    left=.2 in,
    right=.2 in,
    top=0 in,
    bottom=0 in,
}

% Generic page settings
\changefontsize{14pt}
\pagenumbering{gobble}
\setlength{\parindent}{0pt}
\topskip=0pt
\raggedright

% Redefinition of \maketitle and related commands

%  \author{author name}
\makeatletter
\let\@authors\@empty
\renewcommand{\author}[1]{%
    \ifx\@empty\@authors%
        % Author list empty
        \global\def\@authors{#1}%
    \else%
        % Other authors already present
        \global\protected@edef\@authors{\@authors, #1}%
        %\global\edef\@authors{\@authors}%
    \fi}
\makeatother

%  \affiliation{affiliation name}
\makeatletter
\newcounter{@affilcounter}
\newwrite\@bufaffils
\DeclareRobustCommand{\affiliation}[1]{%
    \def\affilarg{#1\relax}%
    \protected@edef\affilarg{%
        \expandafter\expandafter\expandafter\detokenize%
            \expandafter{\affilarg}}%
    % Calculate the footnotemark:
    \setcounter{@affilcounter}{0}%
    % See on which line this affiliation is
    \immediate\openin\@bufaffils=affils.aux\relax%
    % Trying to match \affilarg
    \IfFileExists{affils.aux}{%
        \newif\ifmatched%
        \matchedfalse%
        \loop\unless\ifeof\@bufaffils%
            \immediate\read\@bufaffils to\affilline%
            \ifeof\@bufaffils\relax\else%
                % Read an empty line
                {\immediate\read\@bufaffils to\relax}%
            \fi%
            \stepcounter{@affilcounter}%
            % Comparing \affilline with \affilarg
            \ifdefstrequal{\affilline}{\affilarg}{%
                % Matched, at position \the@affilcounter!
                \global\matchedtrue%
            }{% else
                % Found no match
                \ifeof\@bufaffils%
                    % Also, exhausted the possible matches.
                    \global\setcounter{@affilcounter}{0}%
                \fi%
            }%
            \ifmatched\let\iterate\relax\fi%
        \repeat}{}%
    % Finished matching.
    \immediate\closein\@bufaffils%
    %
    \ifnum\value{@affilcounter}=0%
        % The affiliation was not in there
        \IfFileExists{affils.aux}{%
            \CatchFileDef%
                {\@affilswrite}%
                {affils.aux}%
                {\endlinechar=`^^J}% Preserve EOL
            }{\let\@affilswrite\@empty}%
        \immediate\openout\@bufaffils=affils.aux\relax%
        \ifx\@empty\@affilswrite\relax\else%
            \protected@edef\@affilswrite{%
                \expandafter\expandafter\expandafter\detokenize%
                    \expandafter{\@affilswrite}}%
            \immediate\write\@bufaffils{\@affilswrite}%
        \fi%
        \immediate\write\@bufaffils{\affilarg}%
        \immediate\closeout\@bufaffils%
        %
    \else%
        \def\affilsymb{\fnsymbol{@affilcounter}}%
        \global\protected@edef\@authors{\@authors${}^\affilsymb$}%
    \fi}
\makeatother

%  \title{title}
\makeatletter
\let\@title\@empty
\renewcommand{\title}[1]{%
    \ifx\@empty\@title%
        \global\def\@title{#1}%
    \else%
        \GenericError{}%
            {More than one title definition.}%
            {Make sure you are only calling \noexpand\title once. (Before this it said '\@title'.)}%
    \fi}
\makeatother

%  \date{date}
\makeatletter
\let\@date\@empty
\renewcommand{\date}[1]{%
    \ifx\@empty\@date%
        \global\def\@date{#1}%
    \else%
        \GenericError{}%
            {More than one date definition.}%
            {Make sure you are only calling \noexpand\date once. (Before this it said '\@date'.)}%
    \fi}
\makeatother

%  \logo[graphicx options]{path to image}
\makeatletter
\let\@logoalign\@empty
\let\@logoentries\@empty
\newcommand{\logo}[2][]{%
    \ifx\@empty\@logoentries%
        \global\def\@logoalign{c}%
        \global\def\@logoentries{\includegraphics[#1]{#2}}%
    \else%
        \global\protected@edef\@logoalign{\@logoalign c}%
        \global\protected@edef\@logoentries{\@logoentries & \includegraphics[#1]{#2}}%
    \fi}
\makeatother

% \maketitle{}
\makeatletter
\renewcommand{\maketitle}{%
    \let\@affils\@empty%
    % All the affiliations are already in the file.
    % Read the affiliations from file:
    \IfFileExists{affils.aux}{%
        \setcounter{@affilcounter}{0}%
        \immediate\openin\@bufaffils=affils.aux\relax%
        \loop\unless\ifeof\@bufaffils%
            \immediate\read\@bufaffils to\lineaffil%
            {\unless\ifeof\@bufaffils\immediate\read\@bufaffils to\relax\fi}%
            \stepcounter{@affilcounter}%
            \global\def\affilsymb{\fnsymbol{@affilcounter}}%
            \ifx\@empty\@affils%
                \global\protected@edef\@affils{${}^\affilsymb$\lineaffil}%
            \else%
                \global\protected@edef\@affils{%
                    \@affils, ${}^\affilsymb$\lineaffil}%
            \fi%
        \repeat%
        \immediate\closein\@bufaffils%
    }{}% else nothing
    \vspace*{0pt plus 1fil}%
    \begin{center}%
    {\Large\textsc{\baselineskip=.8em\@title}\par}\vskip .3em%
    \textsc{\@authors}\par%
    \ifx\@empty\@affils%
        \relax% No affiliations
    \else%
        {\vspace{.5em}\baselineskip=1pt{\tiny%
            \vspace*{-.5em}%
            \textsc{\@affils}}\par}
    \fi%
    {\footnotesize\textsc{\@date}}\par%
    \end{center}%
    \ifx\@empty\@logoentries%
        \relax% No logos defined
    \else%
        \par%
        \begin{center}%
        \begin{tabular}{\@logoalign}%
            \@logoentries%
        \end{tabular}%
        \end{center}%
    \fi%
    \newpage}
\makeatother

% \maketopics{}
%
% Typesets an itemize environment with the slide titles (below \maketopics)
\makeatletter
\newif\if@aftertopics
\@aftertopicsfalse
\newcommand{\maketopics}[1][]{%
    \global\@aftertopicstrue%
    \IfFileExists{topics.aux}{%
        \CatchFileDef{\@slidetopics}{topics.aux}{}}%
        {\global\def\@slidetopics{}}%
    \global\let\@slidetopics\@slidetopics%
    \global\newwrite\@buftopics%
    \immediate\openout\@buftopics=topics.aux%
    \AtEndDocument{\immediate\closeout\@buftopics}%
    \setbox0=\hbox{\def\item{}\@slidetopics\unskip}\ifdim\wd0=0pt\relax\else%
        \begin{itemize}%
            \@slidetopics%
        \end{itemize}%
    \fi}
\makeatother

% \slide[Slide title]
%
% Creates a new slide with a title.
% Omit slide title argument to continue previous slide.
% To create a new slide but suppress the title completely, provide an empty arg.
\makeatletter
\newcommand{\@slidetitle}{}
\newcommand{\@slide}[1][]{%
    \clearpage%
    \vspace*{10pt minus 10pt}%
    \newif\if@suppresstitle%
    \global\@suppresstitlefalse%
    \ifx\@titlearg[%
        \if&#1&%
            \global\@suppresstitletrue%
        \fi%
    \fi%
    \if@suppresstitle\relax\else%
        \setbox0=\hbox{#1\unskip}\ifdim\wd0=0pt%
            % Empty title
            {\scriptsize\textsc{\@slidetitle}}%
        \else%
            % New title
            \textsc{#1}%
            \renewcommand{\@slidetitle}{#1}%
            \if@aftertopics%
                \immediate\write\@buftopics{\noexpand\item #1}%
            \fi%
        \fi%
    \fi\par}
\newcommand{\slide}{%
    \futurelet\@titlearg\@slide}
\makeatother

% \subtitle[Slide subtitle]
%
% Very similar to \slide, but typesets a subtitle.
\makeatletter
\newcommand{\@subtitle}{}
\newcommand{\@makesubtitle}[1]{%
    \hspace*{5pt}{$\hookrightarrow$\quad\small\textsc{#1}}}
\newcommand{\subtitle}[1][]{%
    \ifx&#1&\relax\else%
        \renewcommand{\@subtitle}{#1}%
    \fi%
    \@makesubtitle{\@subtitle}%
    \par}
\makeatother
