(** Copyright (c) 2020-2021 Sam Westrick
  *
  * See the file LICENSE for details.
  *)

structure PrettyFun:
sig
  val showFunDec: Ast.Fun.fundec -> TokenDoc.t
end =
struct

  open TokenDoc
  open PrettyUtil

  infix 2 ++ $$ //
  fun x ++ y = beside (x, y)
  fun x $$ y = aboveOrSpace (x, y)
  fun x // y = aboveOrBeside (x, y)

  fun showTy ty = PrettyTy.showTy ty
  fun showPat pat = PrettyPat.showPat pat
  fun showExp exp = PrettyExpAndDec.showExp exp
  fun showDec dec = PrettyExpAndDec.showDec dec
  fun showSpec spec = PrettySig.showSpec spec
  fun showSigExp sigexp = PrettySig.showSigExp sigexp
  fun showSigDec sigdec = PrettySig.showSigDec sigdec
  fun showStrExp strexp = PrettyStr.showStrExp strexp
  fun showStrDec strdec = PrettyStr.showStrDec strdec

  fun showFunArg fa =
    case fa of
      Ast.Fun.ArgSpec spec => showSpec spec
    | Ast.Fun.ArgIdent {strid, colon, sigexp} =>
        group (
          token strid
          ++ space ++ token colon ++ space ++
          showSigExp sigexp
        )

  fun showFunDec (Ast.Fun.DecFunctor {functorr, elems, delims}) =
    let
      fun showFunctor
        (starter, {funid, lparen, funarg, rparen, constraint, eq, strexp})
        =
        group (
          group (
            group (
              token starter
              ++ space ++
              token funid
              ++ space ++ token lparen ++ showFunArg funarg ++ token rparen
            )
            $$
            (case constraint of NONE => empty | SOME {colon, sigexp} =>
              indent (token colon ++ space ++ showSigExp sigexp))
            ++
            space ++ token eq
          )
          $$
          showStrExp strexp
        )
    in
      Seq.iterate op$$
        (showFunctor (functorr, Seq.nth elems 0))
        (Seq.map showFunctor (Seq.zip (delims, Seq.drop elems 1)))
    end

end
