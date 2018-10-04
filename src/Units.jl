abstract type AbstractLeft end
abstract type AbstractRight end
abstract type AbstractUnit <: AbstractRight; end

struct Px <:   AbstractUnit;   val::Real; end
struct Em <:   AbstractUnit;   val::Real; end
struct Cm <:   AbstractUnit;   val::Real; end
struct In <:   AbstractUnit;   val::Real; end
struct Deg <:  AbstractUnit;   val::Real; end
struct Mm <:   AbstractUnit;   val::Real; end
struct Pt <:   AbstractUnit;   val::Real; end
struct Pc <:   AbstractUnit;   val::Real; end
struct Ex <:   AbstractUnit;   val::Real; end
struct Ch <:   AbstractUnit;   val::Real; end
struct Rem <:  AbstractUnit;   val::Real; end
struct Vw <:   AbstractUnit;   val::Real; end
struct Vh <:   AbstractUnit;   val::Real; end
struct Vmin <: AbstractUnit;   val::Real; end
struct Vmax <: AbstractUnit;   val::Real; end
struct Pcnt <: AbstractUnit;   val::Real; end

struct Hex <:   AbstractRight; val::Array{Int64}; end
struct Int_  <: AbstractRight; val::Int64;       end # These do seem redundant but actually help.
struct Float <: AbstractRight; val::Float64;     end
# ==============================================================================
struct Class <: AbstractLeft;     val::String; end
struct Tag <: AbstractLeft;       val::String; end
struct Ident <: AbstractLeft;       val::String; end
struct Attr <: AbstractLeft;      val::String; end

#"digit", "float", "value", "reference", "hex", "string", "unit"
struct Digit <: AbstractRight;     val::String; end
struct Value <: AbstractRight;     val::String; end
struct Reference <: AbstractRight; val::String; end
struct Str <: AbstractRight;       val::String; end
struct Unit <: AbstractRight;       val::String; end

struct Alpha <: AbstractRight;     val::String; end

struct Open;      val::String; end
struct Close;     val::String; end
struct End;       val::String; end

struct Hash;      val::String; end
struct Dot;       val::String; end
struct Dotdot;    val::String; end
struct Dollar;    val::String; end
struct At;        val::String; end
struct Space;     val::String; end


# ==============================================================================
units = [ "px", "em", "cm", "in", "deg", "mm", "pt", "pc",
               "ex", "ch", "rem", "vw", "vh", "vmin", "vmax"] # % & #
