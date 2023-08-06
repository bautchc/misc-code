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

; Adds a numpad to the keyboard
;
; Alt+n toggles between default mode and numpad mode
;
; In numpad mode:
; 12  = 0,
; qwe = 123
; asd = 456
; zxc = 789

mode := 'default'

!n:: {
  global mode
  if (mode = 'default') {
    mode := 'numpad'
  } else {
    mode := 'default'
  }
}

q:: {
  if (mode = 'numpad') {
    Send '1'
  } else {
    Send 'q'
  }
}

w:: {
  if (mode = 'numpad') {
    Send '2'
  } else {
    Send 'w'
  }
}

e:: {
  if (mode = 'numpad') {
    Send '3'
  } else {
    Send 'e'
  }
}

a:: {
  if (mode = 'numpad') {
    Send '4'
  } else {
    Send 'a'
  }
}

s:: {
  if (mode = 'numpad') {
    Send '5'
  } else {
    Send 's'
  }
}

d:: {
  if (mode = 'numpad') {
    Send '6'
  } else {
    Send 'd'
  }
}

z:: {
  if (mode = 'numpad') {
    Send '7'
  } else {
    Send 'z'
  }
}

x:: {
  if (mode = 'numpad') {
    Send '8'
  } else {
    Send 'x'
  }
}

c:: {
  if (mode = 'numpad') {
    Send '9'
  } else {
    Send 'c'
  }
}

$1:: {
  if (mode = 'numpad') {
    Send '0'
  } else {
    Send '1'
  }
}

$2:: {
  if (mode = 'numpad') {
    Send ','
  } else {
    Send '2'
  }
}
