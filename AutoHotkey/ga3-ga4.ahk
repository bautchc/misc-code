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

; Used to slightly speed up conversion from Universal Analytics to Google Analytics 4.

!e::  Send 'event_label'
!m::  Send 'MobileCall_Click_'
!g::  Send 'General'
!c::  Send 'ContactForm_Submission_'
!+c:: Send '_Click_'
!l::  Send 'Landing Pages'
!+m:: Send 'Map_Click_'
!+e:: Send 'Email_Click_'
!o::  Send 'Mobile'

!1:: Send 'Entrances'
!2:: Send 'Conversions'
!3:: Send 'Views'
!4:: Send 'Sessions'
!5:: Send 'Total users'
!6:: Send 'Engagement'
!7:: Send 'Total Revenue'
