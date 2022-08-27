@preprocessor typescript
@builtin "number.ne"

start -> cmd:* M02 {% d => [...d[0].flatMap(v => v), d[1]] %}

cmd -> _ (G04
  | MO
  | FS
  | AD
  | AM
  | Dnn        
  | D01
  | D02
  | D03
  | G01
  | G02
  | G03
  | G75
  | LP
  | LM
  | LR
  | LS
  | region_statement
  | AB_statement
  | SR_statement
  | TF         
  | TA
  | TO
  | TD
) _ {% d => d[1] %}

_ -> [\n ]:* {% d => null %}

str -> [^*]:+ {% ([d]) => d.join("") %}

G04 -> "G04" str "*" {% ([command_code, comment]) => ({ command_code, comment }) %}
M02 -> "M02" "*" {% ([command_code]) => ({ command_code }) %}

MO -> "%" "MO" ("MM"|"IN") "*%" {% ([,command_code, [unit]]) => ({ command_code, unit }) %}

FS -> "%" "FS" "LA" "X" [1-6] [56] "Y" [1-6] [56] "*%" {%
([,command_code, m, , xid, xfd, , yid, yfd]) =>
  ({
      command_code,
      x_integer_digits: parseInt(xid), x_fractional_digits: parseInt(yid),
      y_integer_digits: parseInt(yid), y_fractional_digits: parseInt(yfd) })
%}

user_name ->  [_a-zA-Z$] [._a-zA-Z0-9]:* {% ([f, rest]) => f + rest.join("") %}

file_attribute_name ->
      ".Part"
    | ".FileFunction"
    | ".FilePolarity"
    | ".SameCoordinates"
    | ".CreationDate"
    | ".GenerationSoftware"
    | ".ProjectId"
    | ".MD5"
    | user_name

field -> [^%*,]:* {% ([d]) => d.join("") %}

TF -> "%" "TF" file_attribute_name ("," field):* "*%"
{% ([,command_code, [name], values]) => ({ command_code, name, values: values.map(v => v[1]) }) %}

G01 -> "G01" "*" {% ([command_code]) => ({ command_code }) %}
G02 -> "G02" "*" {% ([command_code]) => ({ command_code }) %}
G03 -> "G03" "*" {% ([command_code]) => ({ command_code }) %}
G75 -> "G75" "*" {% ([command_code]) => ({ command_code }) %}

LP -> "%" "LP" ("C"|"D") "*%" {% ([,command_code, [setting]]) => ({ command_code, setting: setting === "C" ? "clear" : "dark"}) %}
LM -> "%" "LM" ("N"|"XY"|"Y"|"X") "*%"
LR -> "%" "LR" decimal "*%"
LS -> "%" "LS" decimal "*%"

region_statement -> G36 (contour):+ G37
contour -> D02 (D01|G01|G02|G03):*
G36 -> "G36*"
G37 -> "G37*"

AD -> "%" "AD" aperture_identifier (
        ("C" "," decimal ("X" decimal):?)
      | ("R" "," decimal "X" decimal ("X" decimal):?)
      | ("O" "," decimal "X" decimal ("X" decimal):?)
      | ("P" "," decimal "X" decimal ("X" decimal):? ("X" decimal):?)
      | (name ("," decimal ("X" decimal):*):?)
  ) "*%" {%
  ([,command_code, name, [[ty, ,...dargs]]]) => {
    const type = ty === "C" ? "circle" : ty === "R" ? "rectangle" : ty === "O" ? "obround" : ty === "P" ? "polygon" : "named"
    let params = null
    switch(type) {
      case "circle": 
        params = {
          diameter: dargs[0],
          hole_diameter: dargs[1]?.[1]
        }
        break
      case "rectangle":
      case "obround": 
        params = {
          width: dargs[0],
          height: dargs[1],
          hole_diameter: dargs[2]?.[1]
        }
        break
      case "polygon": 
        params = {
          outer_diameter: dargs[0],
          num_vertices: dargs[1],
          rotation: dargs[2]?.[1],
          hole_diameter: dargs[3]?.[1]
        }
        break
    }

    return {
      command_code,
      name,
      type,
      ...params
    }
  } %}

D01 -> ("X" integer):? ("Y" integer):? ("I" integer "J" integer):? "D01" "*" {%
([xd, yd, offset]) => ({ command_code: "D01", x: xd?.[1], y: yd?.[1], i: offset?.[1], j: offset?.[3] }) %}

D02 -> ("X" integer):? ("Y" integer):? "D02" "*" {%
([xt, yt]) => ({ command_code: "D02", x: xt?.[1], y: yt?.[1] }) %}
D03 -> ("X" integer):? ("Y" integer):? "D03" "*" {% ([xt, yt]) => ({ command_code: "D03", x: xt?.[1], y: yt?.[1] }) %}

TA -> "%" "TA" aperture_attribute_name ("," field):* "*%"
TO -> "%" "TO" object_attribute_name ("," field):* "*%"
TD -> "%" "TD"
    (
        file_attribute_name
        | aperture_attribute_name
        | object_attribute_name
        | user_name
    ):?
    "*%"

aperture_attribute_name ->
      ".AperFunction"
    | ".DrillTolerance"
    | ".FlashText"
    | user_name 
    
object_attribute_name ->
      ".N"
    | ".P"
    | ".C"
    | ".CRot"
    | ".CMfr"
    | ".CMPN"
    | ".CVal"
    | ".CMnt"
    | ".CFtp"
    | ".CPgN"
    | ".CPgD"
    | ".CHgt"
    | ".CLbN"
    | ".CLbD"
    | ".CSup"
    | user_name

AM -> "%" "AM" name "*" macro_body  "%"
macro_body -> ( primitive | variable_definition ):+
variable_definition -> macro_variable "=" expr "*"
primitive ->
      "0"  string "*"
    | "1"  "," expr "," expr "," expr "," expr ("," expr):? "*"
    | "20" "," expr "," expr "," expr "," expr "," expr "," expr "," expr "*"
    | "21" "," expr "," expr "," expr "," expr "," expr "," expr "*"
    | "4"  "," expr "," expr "," expr "," expr ("," expr "," expr):+ "," expr "*"
    | "5"  "," expr "," expr "," expr "," expr "," expr "," expr "*"
    | "7"  "," expr "," expr "," expr "," expr "," expr "," expr "*"
macro_variable   -> "$" [0-9]:* [1-9] [0-9]:*
expr -> 
      (["+" | "-"] | term):+
    | expr [+-] term
    | term 

term -> 
  term [x\/] factor
  | factor 
factor -> 
  "(" expr ")"
  | macro_variable 
  | unsigned_decimal

AB_statement -> AB_open  block  AB_close
AB_open  ->     "%" "AB" aperture_identifier "*%"
AB_close ->     "%" "AB" "*%"

SR_statement -> SR_open  block  SR_close
SR_open ->      "%" "SR" "X" positive_integer "Y" positive_integer "I" decimal "J" decimal "*%"
SR_close ->     "%" "SR" "*%"

block -> (
    G04
  | AD
  | AM
  | Dnn        
  | D01
  | D02
  | D03
  | G01
  | G02
  | G03
  | G75
  | LP
  | LM
  | LR
  | LS
  | region_statement
  | AB_statement
  | TF         
  | TA
  | TO
  | TD
):*

Dnn -> aperture_identifier "*" {% ([aperture_identifier]) => ({ command_code: "Dnn", aperture_identifier }) %}

aperture_identifier -> "D" [0]:? [1-9] [0-9]:* {% (d) => d.flatMap(a => a).filter(k => k!== null).join("") %}
name -> [._a-zA-Z$] [._a-zA-Z0-9]:* {% (d) => d.flatMap(a => a).filter(k => k!== null).join("") %}
integer -> int {% ([d]) => d %}
string -> [^%*]:* {% (d) => d.flatMap(a => a).filter(k => k!== null).join("") %} # All characters except * %
positive_integer -> [0-9]:* [1-9] [0-9]:* {% (d) => parseInt(d.flatMap(a => a).filter(k => k!== null).join("")) %}