Require Import Category.Lib.
Require Export Category.Structure.Bicartesian.
Require Export Category.Structure.Closed.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Set Shrink Obligations.
Unset Transparent Obligations.

Section BiCCC.

Context `{C : Category}.
Context `{A : @Cartesian C}.
Context `{@Closed C A}.
Context `{@Cocartesian C}.

Global Program Instance prod_coprod_l {X Y Z : C} :
  (* Products distribute over coproducts in every bicartesian closed
     category. *)
  (Y + Z) × X ≅ Y × X + Z × X := {
  to   := uncurry (curry inl ▽ curry inr);
  from := first inl ▽ first inr
}.
Next Obligation.
  rewrite <- !merge_comp.
  rewrite <- eval_first.
  rewrite <- !comp_assoc.
  rewrite <- !first_comp; cat.
Qed.
Next Obligation.
  rewrite uncurry_comp_r.
  apply curry_inj.
  rewrite curry_uncurry.
  rewrite <- merge_comp.
  rewrite <- !curry_comp; cat.
  rewrite <- !curry_id.
  rewrite merge_comp; cat.
Qed.

Hint Rewrite @prod_coprod_l : isos.

Corollary uncurry_merge {X Y Z W : C} (f : X ~> Y^Z) (g : W ~> Y^Z) :
  uncurry (f ▽ g) ≈ uncurry f ▽ uncurry g ∘ to prod_coprod_l.
Proof.
  simpl.
  apply curry_inj; cat.
  rewrite curry_comp; cat.
  rewrite <- merge_comp.
  apply merge_inv; split;
  rewrite <- curry_comp; cat.
Qed.

Global Program Instance prod_coprod_r {X Y Z : C} :
  (* Products distribute over coproducts in every bicartesian closed
     category. *)
  X × (Y + Z) ≅ X × Y + X × Z := {
  to   := uncurry (curry (inl ∘ swap) ▽ curry (inr ∘ swap)) ∘ swap;
  from := second inl ▽ second inr
}.
Next Obligation.
  rewrite <- !comp_assoc.
  rewrite <- !merge_comp.
  rewrite <- eval_first.
  rewrite <- !comp_assoc.
  rewrite !swap_second.
  rewrite !(comp_assoc (first _)).
  rewrite <- !first_comp; cat.
  rewrite !(comp_assoc eval).
  rewrite !eval_first; cat.
  rewrite <- !comp_assoc; cat.
Qed.
Next Obligation.
  rewrite uncurry_merge. simpl.
  rewrite !comp_assoc; cat.
  rewrite <- merge_comp.
  rewrite !comp_assoc; cat.
  rewrite <- !swap_first.
  rewrite merge_comp.
  rewrite <- !comp_assoc.
  apply swap_inj_l, swap_inj_r.
  rewrite comp_assoc.
  rewrite swap_invol, id_left, id_right.
  rewrite <- !comp_assoc.
  rewrite swap_invol, id_right.
  rewrite uncurry_comp_r.
  rewrite <- merge_comp.
  apply curry_inj.
  rewrite curry_uncurry.
  rewrite <- !curry_comp; cat.
  rewrite <- !curry_id.
  rewrite merge_comp; cat.
Qed.

Hint Rewrite @prod_coprod_r : isos.

Global Program Instance exp_coprod {X Y Z : C} :
  X^(Y + Z) ≅ X^Y × X^Z := {
  to   := curry (eval ∘ second inl) △ curry (eval ∘ second inr);
  from := curry (uncurry exl ▽ uncurry exr ∘ to prod_coprod_r)
}.
Next Obligation.
  rewrite <- fork_comp.
  rewrite <- fork_exl_exr.
  apply fork_inv; split;
  rewrite curry_comp_l;
  rewrite <- comp_assoc;
  rewrite <- first_second;
  rewrite comp_assoc;
  rewrite eval_first;
  rewrite uncurry_curry;
  rewrite <- !comp_assoc;
  rewrite swap_second;
  rewrite curry_comp;
  rewrite <- !eval_first;
  rewrite <- comp_assoc;
  rewrite (comp_assoc (first _));
  rewrite <- first_comp; cat;
  rewrite !eval_first;
  rewrite (comp_assoc eval);
  rewrite !eval_first; cat;
  rewrite <- comp_assoc; cat;
  rewrite <- curry_comp; cat.
Qed.
Next Obligation.
Admitted.

Hint Rewrite @exp_coprod : isos.

Context `{@Initial C}.

Notation "0 × X" := (Prod Zero X) (at level 40).
Notation "X × 0" := (Prod X Zero) (at level 40).

Global Program Instance prod_zero_l {X : C} :
  0 × X ≅ Zero := {
  to   := uncurry zero;
  from := zero
}.
Next Obligation. cat. Qed.
Next Obligation. apply curry_inj; simpl; cat. Qed.

Hint Rewrite @prod_zero_l : isos.

Global Program Instance prod_zero_r {X : C} :
  X × 0 ≅ Zero := {
  to   := uncurry zero ∘ swap;
  from := zero
}.
Next Obligation. cat. Qed.
Next Obligation. apply swap_inj_r, curry_inj; simpl; cat. Qed.

Hint Rewrite @prod_zero_r : isos.

Context `{@Terminal C}.

Notation "X ^ 0" := (Exp Zero X) (at level 30).
Notation "0 ^ X" := (Exp X Zero) (at level 30).

Global Program Instance exp_zero {X : C} :
  X^0 ≅ One := {
  to   := one;
  from := curry (zero ∘ to prod_zero_r)
}.
Next Obligation. cat. Qed.
Next Obligation.
  apply uncurry_inj.
  apply swap_inj_r.
  apply curry_inj; simpl; cat.
Qed.

End BiCCC.