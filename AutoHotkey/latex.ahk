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

!-:: Send '—'

!a:: Send '\addcontentsline{{}toc{}}{{}chapter{}}{{}{}}'
!b:: {
  KeyWait 'Alt'
  Send '\begin{{}tbox{}}{{}\uppercase{{}{}}{}}{Enter}{Enter}\end{{}tbox{}}'
}
!+b:: Send '\begin{{}tbox{}}{{}TERMINOLOGY{}}{Enter}{Enter}\end{{}tbox{}}'
!c:: Send '\frac{{}{}}{{}{}}'
!+c:: Send '\columnbreak'
!d:: Send '\displaystyle'
!+e:: {
  KeyWait 'Alt'
  Send '\begin{{}itemize{}}[leftmargin=1em]{Enter}{Enter}\end{{}itemize{}}'
}
!e:: Send '\item '
!f:: {
  KeyWait 'Alt'
  Send '\textbf{{}{}}'
}
!h:: Send '\hline'
!i:: {
  KeyWait 'Alt'
  Send '\begin{{}ibox{}}{{}\uppercase{{}{}}{}}{Enter}{Enter}\end{{}ibox{}}'
}
!+i:: Send '\index{{}{}}'
!l:: Send '\left'
!m:: Send '\renewcommand\tabularxcolumn[1]{{}m{{}{#}1{}}{}}'
!+m:: {
  KeyWait 'Alt'
  Send '\begin{{}multicols{}}{{}2{}}{ENTER}{ENTER}\end{{}multicols{}}'
}
!n:: Send '\newpage{Enter}\addcontentsline{{}toc{}}{{}chapter{}}{{}{}}{enter}\fancyhead[C]{{}\uppercase{{}{}}{}}{ENTER}\begin{{}multicols{}}{{}2{}}{Enter}{Enter}\columnbreak{Enter}.{Enter}\end{{}multicols{}}'
!+n:: Send '\begin{{}enumerate{}}[leftmargin=1em]{Enter}{Enter}\end{{}enumerate{}}'
!p:: Send '\setlength{{}\parskip{}}{{}0pt{}}'
!+p:: Send '\partial'
!r:: Send '\rule[1pt]{{}0pt{}}{{}\baselineskip{}}'
!+r:: Send '\raisebox{{}1pt{}}{{}'
!t:: Send '\begin{{}tabularx{}}{{}\textwidth{}}{{}{}}{Enter}{Enter}\end{{}tabularx{}}'
!+t:: Send '\textit{{}{}}'
!v:: {
  KeyWait 'Alt'
  Send '\vspace{{}20pt{}}'
}
!x:: Send '>{{}\centering\arraybackslash{}}X'
!;:: Send '\right'
!=:: Send '\item[${-}$] '
!+=:: Send '\item[${+}$] '
