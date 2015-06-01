> {-# LANGUAGE ScopedTypeVariables #-}
> {-# LANGUAGE FlexibleInstances #-}
> {-# LANGUAGE MultiParamTypeClasses #-}
> {-# LANGUAGE KindSignatures #-}
> {-# LANGUAGE FlexibleContexts #-}
> {-# LANGUAGE GADTs #-}

> {-# LANGUAGE DeriveGeneric #-}

> module Transformation.Syntax where

Standard imports 

> import Data.Char
> import Data.List
> import Control.Monad.State.Lazy
> import qualified Data.Map as Data.Map

Data-type generics imports

> import Data.Data
> import Data.Generics.Uniplate.Data
> import Data.Generics.Uniplate.Operations
> import Data.Generics.Zipper
> import Data.Typeable

CamFort specific functionality

> import Analysis.Annotations
> import Analysis.IntermediateReps
> import Traverse
> import Language.Fortran


TODO: Needs fixing with the spans - need to pull apart and put back together

> reassociate :: Fortran Annotation -> Fortran Annotation
> reassociate (FSeq a1 sp1 (FSeq a2 sp2 a b) c) = FSeq a1 sp1 (reassociate a) (FSeq a2 sp2  (reassociate b) (reassociate c))
> reassociate t = t

 reassociate :: Fortran Annotation -> Fortran Annotation
 reassociate (FSeq a1 sp1 (FSeq a2 sp2 a b) c) = FSeq a1 sp1 (reassociate a) (FSeq a2 sp2  (reassociate b) (reassociate c))
 reassociate t = t


Helpers to do with source locations and parsing

> refactorSpan :: SrcSpan -> SrcSpan
> refactorSpan (SrcLoc f ll cl, SrcLoc _ lu cu) = (SrcLoc f (lu+1) 0, SrcLoc f lu cu)

> refactorSpanN :: Int -> SrcSpan -> SrcSpan
> refactorSpanN n (SrcLoc f ll cl, SrcLoc _ lu cu) = (SrcLoc f (lu+1+n) 0, SrcLoc f (lu+n) cu)

> toCol0 (SrcLoc f l c) = SrcLoc f l 0

dropLine extends a span to the start of the next line
This is particularly useful if a whole line is being redacted from a source file

> linesCovered :: SrcLoc -> SrcLoc -> Int
> linesCovered (SrcLoc _ l1 _) (SrcLoc _ l2 _) = l2 - l1 + 1

> dropLine :: SrcSpan -> SrcSpan
> dropLine (s1, SrcLoc f l c) = (s1, SrcLoc f (l+1) 0)

> dropLine' :: SrcSpan -> SrcLoc
> dropLine' (SrcLoc f l c, _) = SrcLoc f l 0

> srcLineCol :: SrcLoc -> (Int, Int)
> srcLineCol (SrcLoc _ l c) = (l, c)

> minaa (SrcLoc f l c) = (SrcLoc f (l-1) c)

> nullLoc :: SrcLoc
> nullLoc = SrcLoc "" 0 0

> nullSpan :: SrcSpan
> nullSpan = (nullLoc, nullLoc)

> afterEnd :: SrcSpan -> SrcSpan
> afterEnd (_, SrcLoc f l c) = (SrcLoc f (l+1) 0, SrcLoc f (l+1) 0)

Variable renaming

> caml (x:xs) = (toUpper x) : xs

> type Renamer = Data.Map.Map Variable Variable

> type RenamerCoercer = Maybe (Data.Map.Map Variable (Maybe Variable, Maybe (Type A, Type A)))
>                        -- Nothing represents an overall identity renamer/coercer for efficiency
>                        -- a Nothing for a variable represent a variable-level (renamer) identity 
>                        -- a Nothing for a type represents a type-level (coercer) identity

> applyRenaming :: (Typeable (t A), Data (t A)) => Renamer -> (t A) -> (t A)
> applyRenaming r = transformBi ((\vn@(VarName p v) -> case Data.Map.lookup v r of
>                                                         Nothing -> vn
>                                                         Just v' -> VarName p v')::(VarName A -> VarName A))

> class Renaming r where
>     hasRenaming :: Variable -> r -> Bool

> instance Renaming RenamerCoercer where
>     hasRenaming _ Nothing   = False
>     hasRenaming v (Just rc) = Data.Map.member v rc

> -- sometimes we have a number of renamer coercers together
> instance Renaming [RenamerCoercer] where
>     hasRenaming v rcss = or (map (hasRenaming v) rcss)