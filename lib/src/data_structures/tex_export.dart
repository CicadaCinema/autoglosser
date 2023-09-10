import 'data_structures.dart';

const _texBegin = r'''\documentclass[a4paper,12pt]{book}
\usepackage[utf8]{inputenc}
\usepackage{xeCJK}
\usepackage{amsmath}

\begin{document}

\newcommand{\glossedword}[3]{
\begin{smallmatrix}
	\text{#1} \\
	\text{#2} \\
	\text{#3}
\end{smallmatrix}
}

\newcommand{\chunktranslation}[1]{\vspace{1em} #1 \vspace{1em}}

\author{Author}
\title{Title}
\date{Date}

%\frontmatter
%\maketitle
%\tableofcontents

\mainmatter
%\chapter{The First Chapter}
%\chapter{The Second Chapter}

''';

const _texEnd = r'''
%\backmatter
% bibliography, glossary and index would go here.

\end{document}''';

extension TexExport on FullText {
  String toTex() {
    var result = '';
    for (final word in allWords) {
      // For every word in the full text, write out the appropriate word ...
      result +=
          '\\(\\glossedword{${word.source}}{${word.pronounciation}}{${word.gloss}}\\)\n';
      // ... and the corresponding break.
      result += switch (word.breakKind) {
        PageBreak(chunkTranslation: final translation) =>
          '\n\\chunktranslation{$translation}\n\\newpage\n\n',
        ChunkBreak(chunkTranslation: final translation) =>
          '\n\\chunktranslation{$translation}\n\n',
        LineBreak() => '\n',
        NoBreak() => '',
      };
    }
    return '$_texBegin$result$_texEnd';
  }
}
