import LeanBio

open Base

-- Convert a character from the terminal into our strict DNA Base type
def parseChar (c : Char) : Option Base :=
  match c with
  | 'A' | 'a' => some A
  | 'T' | 't' => some T
  | 'C' | 'c' => some C
  | 'G' | 'g' => some G
  | _         => none

-- Parse a whole string; returns `none` if ANY character isn't A/T/C/G
def parseDNA (s : String) : Option (List Base) :=
  List.mapM parseChar s.toList

def baseToString (b : Base) : String :=
  match b with
  | A => "A"
  | T => "T"
  | C => "C"
  | G => "G"

def strandToString (strand : List Base) : String :=
  String.join (strand.map baseToString)

-- Entry point for the compiled command-line executable
def main (args : List String) : IO Unit := do
  match args with
  | [seq] =>
    match parseDNA seq with
    | some strand =>
      let comp := complementStrand strand
      IO.println s!"Input:      {strandToString strand}"
      IO.println s!"Complement: {strandToString comp}"
    | none =>
      IO.eprintln s!"Error: '{seq}' contains invalid DNA bases (only A, T, C, G allowed)."
  | _ =>
    IO.println "Usage: lean-bio <DNA_SEQUENCE>"
    IO.println "Example: lean-bio ATGCCG"
