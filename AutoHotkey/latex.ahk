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

!x:: Send '>{{}\centering\arraybackslash{}}X'
!m:: Send '\renewcommand\tabularxcolumn[1]{{}m{{}{#}1{}}{}}'
!i:: Send '\begin{{}ibox{}}{{}{}}{Enter}{Enter}\end{{}ibox{}}'
!b:: Send '\begin{{}tbox{}}{{}{}}{Enter}{Enter}\end{{}tbox{}}'
!+b:: Send '\begin{{}tbox{}}{{}TERMINOLOGY{}}{Enter}{Enter}\end{{}tbox{}}'
!t:: Send '\begin{{}tabularx{}}{{}\textwidth{}}{{}{}}{Enter}{Enter}\end{{}tabularx{}}'
!r:: Send '\rule[1pt]{{}0pt{}}{{}\baselineskip{}}'
!+r:: Send '\raisebox{{}1pt{}}{{}'
!v:: Send '\vspace{{}20pt{}}'
!n:: Send '\newpage{Enter}\fancyhead[C]{{}{}}{ENTER}\begin{{}multicols{}}{{}2{}}{Enter}{Enter}\columnbreak{Enter}.{Enter}\end{{}multicols{}}'
!f:: Send '\textbf{{}{}}'
!h:: Send '\hline'
!d:: Send '\displaystyle'
!l:: Send '\left'
!;:: Send '\right'
!c:: Send '\frac{{}{}}{{}{}}'
!p:: Send '\partial'
!+e:: Send '\begin{{}itemize{}}{Enter}{Enter}\end{{}itemize{}}'
!e:: Send '\item '
!=:: Send '\item[${-}$] '
!+=:: Send '\item[${+}$] '