Set Warnings "-notation-overridden".

Require Import Category.Lib.
Require Export Category.Structure.Cartesian.
Require Export Category.Instance.Sets.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Unset Transparent Obligations.

Section Closed.

Context {C : Category}.
Context `{@Cartesian C}.

Class Closed := {
  Exp : ob -> ob -> ob    (* internal homs *)
    where "Y ^ X" := (Exp X Y);

  exp_iso {X Y Z} : X × Y ~{C}~> Z ≊ X ~> Z^Y;

  curry'   {X Y Z} := to (@exp_iso X Y Z);
  uncurry' {X Y Z} := from (@exp_iso X Y Z);

  eval' {X Y} : Y^X × X ~> Y := uncurry' _ _ _ id;

  ump_exponents' {X Y Z} (f : X × Y ~> Z) :
    eval' ∘ first (curry' _ _ _ f) ≈ f
}.

Notation "Y ^ X" := (Exp X Y) : category_scope.

Context `{@Closed}.

Definition curry   {X Y Z} := @curry' _ X Y Z.
Definition uncurry {X Y Z} := @uncurry' _ X Y Z.
Arguments curry' {_ _ _ _} /.
Arguments uncurry' {_ _ _ _} /.

Definition eval {X Y} : Y^X × X ~> Y := uncurry id.
Arguments eval' {_ _ _} /.

Definition ump_exponents {X Y Z} (f : X × Y ~> Z) :
  eval ∘ first (curry f) ≈ f := @ump_exponents' _ X Y Z f.

Global Program Instance parametric_morphism_curry (a b c : C) :
  Proper (equiv ==> equiv) (@curry a b c).
Next Obligation.
  proper.
  unfold curry; simpl in *.
  destruct exp_iso; simpl in *.
  destruct to; simpl in *.
  rewrites; reflexivity.
Qed.

Global Program Instance parametric_morphism_uncurry (a b c : C) :
  Proper (equiv ==> equiv) (@uncurry a b c).
Next Obligation.
  proper.
  unfold uncurry; simpl in *.
  destruct exp_iso; simpl in *.
  destruct from; simpl in *.
  rewrites; reflexivity.
Qed.

Corollary curry_uncurry {X Y Z} (f : X ~> Z^Y) :
  curry (uncurry f) ≈ f.
Proof.
  replace (curry (uncurry f)) with ((curry ∘ uncurry) f) by auto.
  unfold curry, uncurry; simpl.
  pose proof (iso_to_from (@exp_iso _ X Y Z)) as HA.
  unfold equiv in HA; simpl in HA.
  autounfold in HA.
  unfold equiv in HA; simpl in HA.
  apply HA.
Qed.

Corollary uncurry_curry {X Y Z} (f : X × Y ~> Z) :
  uncurry (curry f) ≈ f.
Proof.
  replace (uncurry (curry f)) with ((uncurry ∘ curry) f) by auto.
  unfold curry, uncurry; simpl.
  pose proof (iso_from_to (@exp_iso _ X Y Z)) as HA.
  simpl in HA.
  unfold equiv in HA; simpl in HA.
  autounfold in HA.
  unfold equiv in HA; simpl in HA.
  apply HA.
Qed.

Hint Rewrite @curry_uncurry : categories.
Hint Rewrite @uncurry_curry : categories.
Hint Rewrite @ump_exponents : categories.

Definition flip {X Y Z : C} `(f : X ~> Z ^ Y) : Y ~> Z ^ X :=
  curry (uncurry f ∘ swap).

Corollary eval_curry {X Y Z W : C} (f : Y × Z ~> W) (g : X ~> Y) (h : X ~> Z) :
  eval ∘ ((curry f ∘ g) △ h) ≈ f ∘ g △ h.
Proof.
  intros.
  rewrite <- (ump_exponents f) at 2.
  rewrite <- comp_assoc.
  unfold first.
  rewrite <- fork_comp; cat.
  rewrite <- comp_assoc; cat.
Qed.

Hint Rewrite @eval_curry : categories.

Corollary curry_eval {X Y : C} :
  curry eval ≈ @id _ (Y^X).
Proof.
  intros; unfold eval; simpl; cat.
Qed.

Hint Rewrite @curry_eval : categories.

Corollary eval_first {X Y Z : C} (f : X ~> Z^Y) :
  eval ∘ first f ≈ uncurry f.
Proof.
  rewrite <- (curry_uncurry f); cat.
Qed.

Corollary curry_inj {X Y Z : C} (f g : X × Y ~> Z) :
  curry f ≈ curry g -> f ≈ g.
Proof.
  intros.
  rewrite <- (uncurry_curry f).
  rewrite <- (uncurry_curry g).
  rewrites; reflexivity.
Qed.

Corollary uncurry_inj {X Y Z : C} (f g : X ~> Z^Y) :
  uncurry f ≈ uncurry g -> f ≈ g.
Proof.
  intros.
  rewrite <- (curry_uncurry f).
  rewrite <- (curry_uncurry g).
  rewrites; reflexivity.
Qed.

Corollary curry_comp_l {X Y Z W : C} (f : Y × Z ~> W) (g : X ~> Y) :
  curry f ∘ g ≈ curry (f ∘ first g).
Proof.
  apply uncurry_inj; cat.
  rewrite <- (ump_exponents (uncurry (curry f ∘ g))).
  rewrite curry_uncurry.
  unfold first in *.
  rewrite <- comp_assoc.
  rewrite eval_curry.
  reflexivity.
Qed.

Corollary curry_comp {X Y Z W : C} (f : Z ~> W) (g : X × Y ~> Z) :
  curry (f ∘ g) ≈ curry (f ∘ eval) ∘ curry g.
Proof.
  rewrite curry_comp_l.
  rewrite <- comp_assoc.
  rewrite eval_first; cat.
Qed.

Corollary uncurry_comp_r {X Y Z W : C} (f : Z ~> W) (g : X ~> Z^Y) :
  f ∘ uncurry g ≈ uncurry (curry (f ∘ eval) ∘ g).
Proof.
  rewrite curry_comp_l; cat.
  rewrite <- comp_assoc.
  rewrite eval_first; reflexivity.
Qed.

Corollary uncurry_comp {X Y Z W : C} (f : Y ~> W^Z) (g : X ~> Y) :
  uncurry (f ∘ g) ≈ uncurry f ∘ first g.
Proof.
  intros.
  apply curry_inj; cat.
  rewrite <- curry_comp_l; cat.
Qed.

Theorem curry_id {X Y Z : C} (f : X ~> Y) :
  curry (@id _ (Y × Z)) ∘ f ≈ curry (first f).
Proof.
  intros.
  rewrite curry_comp_l.
  apply uncurry_inj; cat.
Qed.

Global Program Instance exp_prod_l {X Y Z : C} :
  Z^(X × Y) ≅ (Z^Y)^X := {
  to   := curry (curry (eval ∘ to prod_assoc));
  from := curry (uncurry eval ∘ from prod_assoc)
}.
Next Obligation.
  rewrite curry_comp_l.
  unfold first.
  rewrite curry_comp_l.
  unfold first.
  rewrite <- comp_assoc.
  rewrite <- fork_comp.
  rewrite <- comp_assoc; cat.
  rewrite comp_assoc; cat.
  rewrite <- fork_comp; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite comp_assoc; cat.
  rewrite comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- fork_comp.
  rewrite <- fork_comp; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite fork_comp; cat.
Qed.
Next Obligation.
  rewrite curry_comp_l.
  apply uncurry_inj; cat.
  rewrite <- comp_assoc.
  rewrite <- eval_first.
  rewrite <- comp_assoc.
  rewrite (comp_assoc (first eval)).
  unfold first at 1.
  rewrite <- fork_comp.
  rewrite <- comp_assoc; cat.
  unfold first.
  rewrite <- fork_comp.
  rewrite <- comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- fork_comp.
  rewrite <- comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- fork_comp; cat.
  rewrite <- fork_comp; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- comp_assoc; cat.
  rewrite fork_comp; cat.
Qed.

Hint Rewrite @exp_prod_l : isos.

Global Program Instance exp_prod_r {X Y Z : C} :
  (Y × Z)^X ≅ Y^X × Z^X := {
  to   := curry (exl ∘ eval) △ curry (exr ∘ eval);
  from := curry (uncurry exl △ uncurry exr)
}.
Next Obligation.
  rewrite <- fork_comp.
  rewrite <- fork_exl_exr.
  apply fork_inv; split;
  rewrite <- curry_comp; cat;
  pose proof (@eval_first) as HA;
  unfold first in HA;
  rewrites; cat.
Qed.
Next Obligation.
  apply uncurry_inj.
  rewrite uncurry_comp; cat.
  rewrite <- fork_comp.
  rewrite <- !eval_first.
  rewrite <- !comp_assoc.
  rewrite <- !first_comp; cat.
  rewrite fork_comp; cat.
  unfold first; cat.
Qed.

Hint Rewrite @exp_prod_r : isos.

Lemma curry_fork {X Y Z W : C} (f : X × Y ~> Z) (g : X × Y ~> W) :
  curry (f △ g) ≈ from exp_prod_r ∘ curry f △ curry g.
Proof.
  simpl.
  apply uncurry_inj; cat.
  rewrite uncurry_comp; cat.
  unfold first.
  rewrite <- fork_comp.
  apply fork_inv; split;
  rewrite <- eval_curry;
  rewrite curry_uncurry;
  rewrite comp_assoc; cat.
Qed.

Corollary curry_unfork {X Y Z W : C} (f : X × Y ~> Z) (g : X × Y ~> W) :
  curry f △ curry g ≈ to exp_prod_r ∘ curry (f △ g).
Proof.
  rewrite curry_fork.
  rewrite comp_assoc.
  rewrite iso_to_from; cat.
Qed.

Context `{@Terminal C}.

Global Program Instance exp_one {X : C} :
  X^One ≅ X := {
  to   := eval ∘ id △ one;
  from := curry exl
}.
Next Obligation.
  rewrite <- comp_assoc.
  rewrite <- fork_comp; cat.
  rewrite <- (id_right (curry exl)); cat.
Qed.
Next Obligation.
  rewrite comp_assoc.
  rewrite !curry_comp_l.
  apply uncurry_inj; cat.
  unfold first, eval; cat.
  rewrite <- comp_assoc; cat.
  rewrite <- fork_comp.
  rewrite id_left.
  cut (@one _ _ (X^One) ∘ exl ≈ exr).
    intros; rewrites; cat.
  cat.
Qed.

Hint Rewrite @exp_one : isos.

End Closed.

Notation "Y ^ X" := (Exp X Y) : category_scope.

Hint Rewrite @curry_uncurry : categories.
Hint Rewrite @uncurry_curry : categories.
Hint Rewrite @ump_exponents : categories.
Hint Rewrite @eval_curry : categories.
Hint Rewrite @curry_eval : categories.
Hint Rewrite @exp_prod_l : isos.
Hint Rewrite @exp_prod_r : isos.
Hint Rewrite @exp_one : isos.
