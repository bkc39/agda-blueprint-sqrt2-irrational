{-# OPTIONS --safe #-}

-- √2 is irrational.
--
-- This specializes Shinji Kono's general result (no rational squares to a
-- prime) to p = 2: we prove `Prime 2` and instantiate
-- `root2.root-prime-irrational1`. The upstream proof lives in
-- https://github.com/shinji-kono/automaton-in-agda (MIT); we depend on it as an
-- Agda library and add only the `p = 2` specialization here.

module Sqrt2 where

open import Data.Nat using (ℕ; zero; suc; _<_; _>_; z≤n; s≤s)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Relation.Nullary using (¬_)

open import gcd using (gcd)
open import prime using (Prime)
open import root2 using (Rational; Rational*; _r=_; root-prime-irrational1)

-- 2 is prime. The only `j` with `0 < j < 2` is `j = 1`, and `gcd 2 1` computes
-- to `1`, so the obligation is `refl`.
prime2 : Prime 2
prime2 = record { p>1 = s≤s (s≤s z≤n) ; isPrime = ip }
  where
    ip : (j : ℕ) → j < 2 → 0 < j → gcd 2 j ≡ 1
    ip (suc zero)    _              _  = refl
    ip zero          _              ()
    ip (suc (suc _)) (s≤s (s≤s ())) _

-- √2 is irrational: no rational `r` satisfies `r · r = 2`
-- (i.e. `2 · (denominator r)² ≡ (numerator r)²` has no solution).
sqrt2-irrational : (r : Rational) → ¬ (Rational* r r r= 2)
sqrt2-irrational = root-prime-irrational1 2 prime2
