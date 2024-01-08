; MIT No Attribution
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of this
; software and associated documentation files (the "Software"), to deal in the Software
; without restriction, including without limitation the rights to use, copy, modify,
; merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
; PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

; Adds hotkeys to make LaTeX typesetting more efficient. Many of these are mostly useful for the specific ways that
; I personally typeset my LaTeX documents.

!-:: {
  KeyWait 'Alt'
  Send '—'
}

!a:: {
  KeyWait 'Alt'
  Send '\addcontentsline{{}toc{}}{{}chapter{}}{{}{}}'
}
!b:: {
  KeyWait 'Alt'
  Send '\begin{{}tbox{}}{{}\uppercase{{}{}}{}}{Enter}{Enter}\end{{}tbox{}}'
}
!+b:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\begin{{}tbox{}}{{}TERMINOLOGY{}}{Enter}{Enter}\end{{}tbox{}}'
}
!c:: {
  KeyWait 'Alt'
  Send '\frac{{}{}}{{}{}}'
}
!+c:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\columnbreak'
}
!d:: {
  KeyWait 'Alt'
  Send '\displaystyle'
}
!+e:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\begin{{}itemize{}}[leftmargin=1em]{Enter}{Enter}\end{{}itemize{}}'
}
!e:: {
  KeyWait 'Alt'
  Send '\item '
}
!f:: {
  KeyWait 'Alt'
  Send '\textbf{{}{}}'
}
!h:: {
  KeyWait 'Alt'
  Send '\hline'
}
!i:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\begin{{}ibox{}}{{}\uppercase{{}{}}{}}{Enter}{Enter}\end{{}ibox{}}'
}
!+i:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\index{{}{}}'
}
!l:: {
  KeyWait 'Alt'
  Send '\left'
}
!m:: {
  KeyWait 'Alt'
  Send '\renewcommand\tabularxcolumn[1]{{}m{{}{#}1{}}{}}'
}
!+m:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\begin{{}multicols{}}{{}2{}}{ENTER}{ENTER}\end{{}multicols{}}'
}
!n:: {
  KeyWait 'Alt'
  Send '\newpage{Enter}\addcontentsline{{}toc{}}{{}chapter{}}{{}{}}{enter}\fancyhead[C]{{}\uppercase{{}{}}{}}{ENTER}\begin{{}multicols{}}{{}2{}}{Enter}{Enter}\columnbreak{Enter}~{Enter}\end{{}multicols{}}'
}
!+n:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\begin{{}enumerate{}}[leftmargin=1em]{Enter}{Enter}\end{{}enumerate{}}'
}
!p:: {
  KeyWait 'Alt'
  Send '\setlength{{}\parskip{}}{{}0pt{}}'
}
!+p:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\partial'
}
!r:: {
  KeyWait 'Alt'
  Send '\rule[1pt]{{}0pt{}}{{}\baselineskip{}}'
}
!+r:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\raisebox{{}1pt{}}{{}'
}
!t:: {
  KeyWait 'Alt'
  Send '\begin{{}tabularx{}}{{}\textwidth{}}{{}{}}{Enter}{Enter}\end{{}tabularx{}}'
}
!+t:: {
  KeyWait 'Alt'
  KeyWait 'Shift'
  Send '\textit{{}{}}'
}
!v:: {
  KeyWait 'Alt'
  Send '\vspace{{}20pt{}}'
}
!x:: {
  KeyWait 'Alt'
  Send '>{{}\centering\arraybackslash{}}X'
}
!;:: {
  KeyWait 'Alt'
  Send '\right'
}
!=:: {
  KeyWait 'Alt'
  Send '\item[${-}$] '
}
!+=:: {
  KeyWait 'Alt'
  Send '\item[${+}$] '
}
