open Printf
open Compiler_util
open Arm
(*OBJECT BEGIN*)
	let global_func_free_dic = ref []
	(*lisf of (func_name,List of	(free_var ids))*)
	let sc=ref 1;; (*USED FOR VARIABLE GENERATION *)
	let gc1=ref 1;;(* FRESH VAR GEN *)
	let lc1=ref 1;; (* FRESH Label Gen *)
	let global_func_body_dict =ref [] ;;
	(*List of (func_name,actual function(ane after reg alloc and clo comvert ) )*)
	let func_var_to_reg_dict = ref [] ;;(*List ["func_name",[<varname,Reg>] *)

(*OBJECTS END*)

(*CORE_UTILITIES BEGIN*)
(*USED IN NEW VAR. GEN. FOR ANF CONVERSION *)
let getfreshstring ():(string)=
	gc1:=!gc1 +1 ;
	("F"^(string_of_int !gc1 ));;
	(*	USED IN IF BLOCKS 	*)
let getfreshlabel ():(string)=
			lc1:=!lc1 +1 ;
			("Label"^(string_of_int !lc1 ));;
			(*REWRITE where this is used *)
let forceexptoid (a:exp):aexp=
		match a with
			| Id(id) -> AId(id)
			| _ -> failwith "aid conversion invalid" ;;
			(*Populate global dict of (fname,[Freevars list])*)
let add_to_global_dict (i:id)(j:id list):unit=
			global_func_free_dic	:= (i,j)::(!global_func_free_dic);;
(* get index of free var used for closure conversion *)
let get_index_in_list (i:id list)(iden:id):int=
		let rec inner (x:int)(y:id list)=
				match y with
					|[]->x
					|hd::tl -> if not(hd<>iden) then x else (inner (x+1) tl)
				in
		inner 0 i ;;
(* DRAG OUT AND ADD TO GLOBAL SCOPE *)
let add_to_func_body_dict (i:id)(bfun:bexp):unit=
			global_func_body_dict:=(i,bfun)::!global_func_body_dict;;
(** FUNC ,<VAR name , REG dictionary> ***)
let add_to_func_var_to_reg_dict (scope:id)(var:id)(reg:id):unit=
		(if List.mem_assoc scope !func_var_to_reg_dict then
			( 	let t=List.assoc scope !func_var_to_reg_dict in
					let nt=List.remove_assoc var t in
					let t=(var,reg)::nt  in
					let nls=List.remove_assoc scope !func_var_to_reg_dict in
					func_var_to_reg_dict:= (scope,t)::nls )
		else
		(	func_var_to_reg_dict:=(scope,[(var,reg)])::!func_var_to_reg_dict ) )
					;;
let get_from_func_var_to_reg_dict (scope:id)(var:id):id=
	let ls=List.assoc scope !func_var_to_reg_dict  in
	List.assoc var ls ;;
    

let rglst:IdSet.t =IdSet.of_list ["R0";"R1";"R2";"R3";"R4";"R5";"R6";"R7";"R8";"R9";"R10"] ;;

let getRgStr (fv:IdSet.t):string=
		let diff = IdSet.diff rglst fv in
		List.hd (IdSet.elements diff) ;; (* Process errors **)


(*CORE_UTILITIES END*)
(*DEBUG Utilities *)
(*Prints dictionary of func id and list of free vars *)
let print_global_func_free_dic ls=
	let outeritemiter oitem=
		 (let listprint litem=
			 	printf "%s ," litem in
		 let fid= (fst oitem) in
		 let lsfv= (snd oitem) in
		 printf "func_name:%s	" fid;
		 printf "List of free_vars (" ;
		 List.iter listprint lsfv ;
		 print_endline ")";
		 ()) in
 	 List.iter outeritemiter ls  ;;
let print_func_var_to_reg_dict args =
		let printstrpair a=
				printf "(%s,%s) " (fst a) (snd a)  in
		let iterfunc a=
				printf "scope:%s [" (fst a);
				List.iter printstrpair (snd a);
				print_endline "]" in
		List.iter iterfunc args ;;
let printliststr (a:string list):unit =
		List.iter (printf "%s ") a ;;
let foldstr (a:string list):string =
		let fold_left_func 	el ellistelem=
				el^","^ellistelem in
		List.fold_left fold_left_func " " a ;;
let getscopeid	(a:string):string =
		sc:=!sc+1 ;	(*Use this to rename all variables EASY CAN BE DONE LATER*)
		a^(string_of_int !sc)
let print_exp (e:exp)=
		pp_exp Format.std_formatter  e;;
let consttoint(e:const):string=
		match e with
			|Int(i) -> string_of_int i
			|Bool(true)->"True"
			|Bool(false)->"False"
			;;
let aexptostring(e:aexp):string =
		match e with
		  | AId(id) -> "AId("^id^")"
		  | AConst(const)-> "AConst("^(consttoint const)^")"
		  ;;
let rec bexptostring(e:bexp):string =
			(match e with
				| BAtom(aex) -> "BAtom("^(aexptostring aex)^")"
				| BOp2(op2,aex1,aex2) -> "BOp2(op2,"^(aexptostring aex1)^","^(aexptostring aex2)^")"
				| BMkArray(ae1,ae2) -> "BMkArray("^(aexptostring ae1)^","^(aexptostring ae2)^")"
				| BGetArray(ae1,ae2) ->  "BGetArray("^(aexptostring ae1)^","^(aexptostring ae2)^")"
				| BSetArray(ae1,ae2,ae3)-> "BSetArray("^(aexptostring ae1)^","^(aexptostring ae2)^","^(aexptostring ae3)^")"
				| BFun(id,idls,anfe) -> "BFun(id:"^id^","^(foldstr idls)^")->("^(anfexptostring anfe)^")"
				| BApp(ae,aels) ->  "BApp("^(aexptostring ae)^",["^(foldstr (List.map aexptostring aels))^"])"
			)
and anfexptostring(e:anfexp):string=
		match e with
			| ELet(id,bex,anfex)-> ("ELet("^id^","^(bexptostring bex)^",\n"^(anfexptostring anfex)^")");
			| ERet(aex) -> ("ERet("^(aexptostring aex)^")") ;
			| EIf(ae,ane1,ane2) -> "EIf("^(aexptostring ae)^","
												^(anfexptostring ane1)^","
												^(anfexptostring ane2)^")"
			| _ -> failwith "anfexptostring not implemented" ;;


(*DEBUG Utilities END *)
(********** ACTUAL ALGORITHM *)
(****STEP 0 scope enable*****)
let rec rename_vars (e:exp)(ol:id)(nw:id):exp=
	match e with
	| Id(cid)-> if not (cid<>ol) then
							(Id(nw))
							else
							(Id(cid))
	| Const(c)->(Const(c))
	| Op2(op2,e1,e2)->Op2(op2,(rename_vars e1 ol nw),(rename_vars e2 ol nw))
	| If(e1,e2,e3)->let e11=rename_vars e1 ol nw in
									let e22=rename_vars e2 ol nw in
									let e33=rename_vars e3 ol nw in
									If(e11,e22,e33)
	| Let(cid,e1,e2)->let e11=rename_vars e1 ol nw in
										if not (cid<>ol) then
										Let(cid,e11,e2)
										else
										Let(cid,e11,(rename_vars e2 ol nw))
	| Fun (id,idls,e)-> if List.mem  ol (id::idls) then
													Fun(id,idls,e)
											else
													Fun(id,idls,(rename_vars e ol nw))
	| App (e,els) -> let map_fun a=
												(rename_vars a ol nw) in
										App((rename_vars e ol nw),(List.map map_fun els))
	| MkArray(e1,e2)->let e11=rename_vars e1 ol nw in
										let e22=rename_vars e2 ol nw in
										MkArray(e11,e22)
	| GetArray(e1,e2)->let e11=rename_vars e1 ol nw in
										let e22=rename_vars e2 ol nw in
										GetArray(e11,e22)
	| SetArray(e1,e2,e3)->let e11=rename_vars e1 ol nw in
											let e22=rename_vars e2 ol nw in
											let e33=rename_vars e3 ol nw in
		 								SetArray(e11,e22,e33)
	| Seq(e1,e2)->let e11=rename_vars e1 ol nw in
								let e22=rename_vars e2 ol nw in
								Seq(e11,e22)
						;;
let rec gen_scope_vars (e:exp):exp=
	match e with
	| Id(i)->Id(i)
	| Const(c)->Const(c)
	| Op2(op2,e1,e2) ->Op2(op2,(gen_scope_vars e1),(gen_scope_vars e2))
	| If(e1,e2,e3) -> If((gen_scope_vars e1),(gen_scope_vars e2),(gen_scope_vars e3))
	| Let(i,e1,e2)->let nv=(getscopeid i) in
									Let(nv,(gen_scope_vars e1),(gen_scope_vars (rename_vars e2 i nv)))
	| Fun(id,idls,e)-> let fold_right_fun  idl (a,b)=
													let nv=(getscopeid idl) in
													(nv::a,rename_vars b idl nv) in
										 let (nidls,ne)=List.fold_right fold_right_fun idls ([],e) in
										 let nid=(getscopeid id) in
										 Fun(nid,nidls,(gen_scope_vars (rename_vars ne id nid)))
	| App(e,els)-> App((gen_scope_vars e),(List.map gen_scope_vars els))
	| MkArray(e1,e2)-> MkArray(gen_scope_vars e1,gen_scope_vars e2)
	| GetArray(e1,e2)->GetArray(gen_scope_vars e1,gen_scope_vars e2)
	| SetArray(e1,e2,e3)->SetArray(gen_scope_vars e1,gen_scope_vars e2,gen_scope_vars e3)
	| Seq(e1,e2) -> Seq((gen_scope_vars e1,gen_scope_vars e2))
;;
(*Step 0*)

(*STEP 1 Populate dictionary with free vars *)
let rec find_free_vars_in_exp (e:exp):IdSet.t=
		match e with
		  | Id(i) -> IdSet.singleton i
		  | Const(c) -> IdSet.empty
			| MkArray(e1,e2)
			| GetArray(e1,e2)
		  | Seq(e1,e2)
		  | Op2(_,e1,e2) -> (IdSet.union (find_free_vars_in_exp e1) (find_free_vars_in_exp e2))
			| SetArray(e1,e2,e3)
		  | If (e1,e2,e3) -> let u1=(IdSet.union (find_free_vars_in_exp e2) (find_free_vars_in_exp e3)) in
												 (IdSet.union (u1) (find_free_vars_in_exp e1))
		  | Let(id1,e1,e2)-> let u1=(find_free_vars_in_exp e1) in
			 									 let u2=IdSet.remove id1 (find_free_vars_in_exp e2) in
												 (IdSet.union u1 u2)
		  | Fun (id,idls,e) ->  let u1 = (find_free_vars_in_exp e) in
														let u2=IdSet.diff u1 (IdSet.of_list (id::idls)) in
														add_to_global_dict id (IdSet.elements u2) ; u2
		  | App (e1,els) -> 	let fold_f (a:exp)(b:IdSet.t):IdSet.t=
															(IdSet.union (find_free_vars_in_exp a) b)  in
													let a=List.fold_right fold_f els (find_free_vars_in_exp e1) in
													a;
													;;
(****** STEP 1 END *******)
(****** STEP 2 BEGIN******)
let rec closureconvert (e:exp)(idls:id list):exp =
			match e with
			| Id(identity) -> if (List.mem identity idls) then
														(* Index+1 to account for function address *)
											GetArray(Id("env"),Const(Int((get_index_in_list idls identity)+1)))
												else
											Id(identity)
			| Const(c) -> Const(c)
			| Op2(op2,e1,e2) -> Op2(op2,(closureconvert e1 idls),(closureconvert e2 idls))
			| If(e1,e2,e3)->	If((closureconvert e1 idls),(closureconvert e2 idls),(closureconvert e3 idls))
				(*| Let(id1,Fun(iname,idls,e1),e2)->(*	DELETE AT 5 ish 	*)
										(let cl_list=(List.assoc iname !global_func_free_dic) in
										let cl_length =List.length cl_list in
										let c= ref cl_length in
										let fold_right_ff a b=
												c:=!c - 1 ;
												Let("D1",SetArray(Id(id1),Const(Int(!c+1)),Id(a)),b) in
										let init_st=Let(id1,(closureconvert (Fun(iname,idls,e1)) idls),(closureconvert e2 idls))  in
										let cl_add=List.fold_right fold_right_ff cl_list init_st in
										Let(id1,MkArray(Const(Int(cl_length+1)),Const(Int(0))), cl_add)) *)
			| Let(id1,e1,e2)-> Let(id1,(closureconvert e1 idls),(closureconvert e2 idls))
			| Fun(iname,idls1,e1)->
										(let cl_list=(List.assoc iname !global_func_free_dic) in
										let nvar=getfreshstring () in
										let cl_length =List.length cl_list in
										let c= ref cl_length in
										let fold_right_ff a b=
												c:=!c - 1 ;
												Let("D1",SetArray(Id(nvar),Const(Int(!c+1)),(closureconvert (Id(a)) idls)),b) in
												let init_st=Let(nvar, (Fun(iname,"env"::idls1,(closureconvert e1 cl_list))),Id(nvar))  in
											let cl_add=List.fold_right fold_right_ff cl_list init_st in
											Let(nvar,MkArray(Const(Int(cl_length+1)),Const(Int(0))), cl_add))

															(* DELETE AT 5 ISH
															let ni=List.assoc iname !global_func_free_dic in
															Fun(iname,"env"::idls1,(closureconvert e1 ni)) *)
		(*	| App(Fun(iname,idls1,e1),elist)->(*HACK*) let var=getfreshstring () in
							(closureconvert (Let(var,Fun(iname,idls1,e1),App(Id(var),elist))) idls) *)
			| App (e1,elist)->  let fold_r (e:exp)(b:exp list):(exp list)=
																(closureconvert e idls)::b
													in
													App((closureconvert e1 idls),(List.fold_right	fold_r elist []))
			| MkArray(e1,e2)-> MkArray((closureconvert e1 idls),(closureconvert e2 idls))
			| GetArray(e1,e2) -> GetArray((closureconvert e1 idls),(closureconvert e2 idls))
			| SetArray(e1,e2,e3)->SetArray((closureconvert e1 idls),(closureconvert e2 idls),(closureconvert e3 idls))
			| Seq(e1,e2) -> Seq((closureconvert e1 idls),(closureconvert e2 idls))
			;;
(***** STEP 2 END*****)
(***** STEP 3 BEGIN **)
let deffunction (a:aexp):anfexp=ERet(a) ;;
let rec exptoanf (e:exp)(hf:aexp->anfexp):(anfexp)=
	match e with
	|Const(id) -> (hf (AConst(id)))
	|Id(id) -> (hf (AId(id)))
	|Op2(op2,e1,e2) ->
				(exptoanf e1 (fun (limm:aexp)->
						(exptoanf e2 (fun (rimm:aexp) ->
							(let var = getfreshstring() in
			(ELet(var,(BOp2(op2,limm,rimm)),(hf (AId(var)))))
										)	) )	)	)
	|Let(x,Fun(id,idls,e1),e2)->(****** HANDLE DIFF DEBUG  ****)
										ELet(x,BFun(id,idls,(exptoanf e1 deffunction)),(exptoanf e2 hf))
	|Let(x,e1,e2) -> (exptoanf e1 (fun (lbind:aexp)->
										(ELet(x,(BAtom(lbind)),(exptoanf e2 hf)))	)	)
	|If (e1,e2,e3) -> (exptoanf e1 (fun(ifbind:aexp)->
							EIf(ifbind,(exptoanf e2 hf),(exptoanf e3 hf))	))
	|MkArray(e1,e2) -> (exptoanf e1 (fun(lt:aexp)->
												exptoanf e2 (fun(rt:aexp)->
													(let var=getfreshstring() in
															ELet(var,(BMkArray(lt,rt)),(hf (AId(var))))
																	))))
	|GetArray(e1,e2) ->  (exptoanf e1 (fun(lt:aexp)->
													exptoanf e2 (fun(rt:aexp)->
													(let var=getfreshstring() in
															ELet(var,(BGetArray(lt,rt)),(hf (AId(var))))
																	))))
	|SetArray(e1,e2,e3) -> (exptoanf e1 (fun(lt:aexp)->
													exptoanf e2 (fun(rt:aexp)->
														exptoanf e3 (fun(rt3:aexp)->
															(let var=getfreshstring() in
															ELet(var,(BSetArray(lt,rt,rt3)),(hf (AId(var))))
																	)))))
	|Fun(id,idlist,exp) ->	failwith "ANF function call should  be unreachable "
													(*let var =getfreshstring() in
	 												ELet(var,BFun(id,idlist,(exptoanf exp deffunction)),(hf (AId(var)))) *)
	|App(e,els) -> (	exptoanf e (fun(ae1:aexp)->(
										match els with
							|[] -> 	(let var=getfreshstring() in
														ELet(var,BApp(ae1,[]),(hf (AId(var)))	))
							|[e1] ->(exptoanf e1 (fun(ael1:aexp)->
												let var=getfreshstring() in
													ELet(var,BApp(ae1,[ael1]),(hf (AId(var)))	)))
							|[e1;e2] ->(exptoanf e2 (fun(ael2:aexp)->
													(exptoanf e1 (fun(ael1:aexp)->
													let var=getfreshstring() in
													ELet(var,BApp(ae1,[ael1;ael2]),(hf (AId(var))))	)))	)
							|[e1;e2;e3]->(exptoanf e3 (fun(ael3:aexp)->
														(exptoanf e2 (fun(ael2:aexp)->
															(exptoanf e1 (fun(ael1:aexp)->
																		let var=getfreshstring() in
																			ELet(var,BApp(ae1,[ael1;ael2;ael3]),(hf (AId(var))))	)))	)))
							| _ -> failwith "rewrite code to use 3 paramters or less" )
									) )
	| _ -> failwith "exp_to_inf not implemented"
		;;
(***** STEP 3 END ****)
(***** STEP 4 BEGIN******)
let rec rgalloc_bexp (be:bexp):bexp =
	(match be with
		| BFun(sc,[ar1;ar2;ar3;ar4],anfe) ->((add_to_func_var_to_reg_dict sc ar1 "R0");
																 (add_to_func_var_to_reg_dict sc ar2 "R1");
																 (add_to_func_var_to_reg_dict sc ar3 "R2");
																 (add_to_func_var_to_reg_dict sc ar4 "R3");
																 let anfe=rename sc "R0" anfe in
																 let anfe=rename ar1 "R0" anfe in
																 let anfe=rename ar2 "R1" anfe in
																 let anfe=rename ar3 "R2" anfe in
																 let anfe=rename ar4 "R3" anfe in
																BFun(sc,[ar1;ar2;ar3;ar4],(rgalloc anfe sc)) )

		| BFun(sc,[ar1;ar2;ar3],anfe) ->((add_to_func_var_to_reg_dict sc ar1 "R0");
																 (add_to_func_var_to_reg_dict sc ar2 "R1");
																 (add_to_func_var_to_reg_dict sc ar3 "R2");
																 let anfe=rename sc "R0" anfe in
																 let anfe=rename ar1 "R0" anfe in
																 let anfe=rename ar2 "R1" anfe in
																 let anfe=rename ar3 "R2" anfe in
																BFun(sc,[ar1;ar2;ar3],(rgalloc anfe sc)) )

		| BFun(sc,[ar1;ar2],anfe) ->((add_to_func_var_to_reg_dict sc ar1 "R0");
																 (add_to_func_var_to_reg_dict sc ar2 "R1");
																 let anfe=rename sc "R0" anfe in
																 let anfe=rename ar1 "R0" anfe in
																 let anfe=rename ar2 "R1" anfe in
																BFun(sc,[ar1;ar2],(rgalloc anfe sc)) )

		| BFun(sc,[ar1],anfe) ->((add_to_func_var_to_reg_dict sc ar1 "R0");
																 let anfe=rename sc "R0" anfe in
																 let anfe=rename ar1 "R0" anfe in
																BFun(sc,[ar1],(rgalloc anfe sc)) )

		| BFun(a,b,c) -> 	printf "%d" (List.length b) ;
											failwith "Function with unexpected no. of arguments"
		| _ -> be )
and rgalloc (ane:anfexp)(scope:id):anfexp=
		match ane with
			|ELet(id,BFun(bfid,bfargs,ane1),ane2)->
						let rg=get_from_func_var_to_reg_dict scope id in
						(** ATTEND TO WHILE DEBUGGING ***)
						ELet(rg ,(rgalloc_bexp (BFun(bfid,bfargs,ane1))),(rgalloc (rename	id rg ane2) scope) )
			|ELet(id,be,ane1) ->let fv = free_vars ane1 in
													let nv = getRgStr fv in
													(** ATTEND TO WHILE DEBUGGING ***)
													(add_to_func_var_to_reg_dict scope id nv) ;
													ELet(nv,(rgalloc_bexp be),(rgalloc (rename id nv ane1) scope))
			|EIf(ae1,ane2,ane3) -> ( match ae1 with
				| AId(i) 		-> EIf(ae1,(rgalloc ane2 scope),(rgalloc ane3 scope))
				| anyae ->	(*let fv= (IdSet.union (free_vars ane2) (free_vars ane3)) in
												let rg= getRgStr fv in *)
												(EIf(anyae,(rgalloc ane2 scope),(rgalloc ane3 scope)))	)
			|ERet(a) -> ERet(a)
			|EApp(ae,aels) -> EApp(ae,aels)
				;;
(***** STEP 4 END *******)
(***** STEP 5 BEGIN MOVING TO UNIVERSAL SCOPE *****)
let rec move_func_to_global_scope (ane:anfexp):unit=
	match ane with
		|ELet(i,BFun(i1,ils,ane1),ane2)->((add_to_func_body_dict i1 (BFun(i1,ils,ane1)));
																			(move_func_to_global_scope ane1);
																			(move_func_to_global_scope ane2))
		|ELet(i,be,ane1)->(move_func_to_global_scope ane1)
		|EIf(ae,ane1,ane2)->((move_func_to_global_scope ane1);(move_func_to_global_scope ane2))
		|EApp(ae,aels)->()
		|ERet(_)->() ;;
(***** STEP 5 END MOVING TO UNIVERSAL SCOPE *****)


(**************** NOT CLEANED UP YET *************)
let aexptoindex (ae:aexp):operand =
	match ae with
		| AId(id) ->Reg(string_to_reg id)
		| AConst(Int(i))-> Imm(i)
		| AConst(Bool(true))->Imm(1)
		| AConst(Bool(false))->Imm(0)
			;;

let getregfromaexp (ae:aexp):reg=
	let op = aexptoindex ae in
	match op with
		| Reg(r) -> r
		| _ -> failwith "not a register" ;;
(*
let current_function = ref "global" ;;
*)
let callersave_id_is_r0:Arm.assembly=Arm.concat(
	[(push (Reg(R1)));(push (Reg(R2)));(push (Reg(R3)));(push (Reg(LR)))]);;
let callerload_id_is_r0:Arm.assembly=Arm.concat(
		[(pop ((LR)));(pop ((R3)));(pop ((R2)));(pop ((R1)));]);;


let callee_save=Arm.concat([(push (Reg(R4)));(push (Reg(R5)));(push (Reg(R6)));
(push (Reg(R7)));(push (Reg(R8)));(push (Reg(R9)));(push (Reg(R10)))]);;

let callee_restore=Arm.concat([(pop (R10));(pop (R9));(pop (R8));(pop (R7));
(pop (R6));(pop (R5));(pop (R4))]);;

let prefunc:Arm.assembly=Arm.concat(
	[(push (Reg(R1)));(push (Reg(R2)));(push (Reg(R3)));(push (Reg(LR)))]);;
let postfunc:Arm.assembly=Arm.concat(
		[(pop ((LR)));(pop ((R3)));(pop ((R2)));(pop ((R1)));]);;


let rec bexptoasm (id:string)(be:bexp):Arm.assembly=
		match be with
			|BOp2(GT,ae1,ae2) ->	(let i0=mov (R11) (aexptoindex ae1) and
															i1=cmp (Reg(R11))  (aexptoindex ae2) and
															i2=mov (string_to_reg id) (Imm(0)) and
														i3=mov ~cond:GT (string_to_reg id) (Imm(1)) in
														 Arm.concat [i0;i1;i2;i3])
		  |BOp2(LT,ae1,ae2) ->	(let i0=mov (R11) (aexptoindex ae1) and
															i1=cmp (Reg(R11))  (aexptoindex ae2) and
															i2=mov (string_to_reg id) (Imm(0)) and
															i3=mov ~cond:LT (string_to_reg id) (Imm(1)) in
														 	Arm.concat [i0;i1;i2;i3])
			|BOp2(Eq,ae1,ae2) ->	(let i0=mov (R11) (aexptoindex ae1) and
															i1=cmp (Reg(R11))  (aexptoindex ae2) and
															i2=mov (string_to_reg id) (Imm(0)) and
															i3=mov ~cond:EQ (string_to_reg id) (Imm(1)) in
														 	Arm.concat [i0;i1;i2;i3])

			|BOp2(Add,ae1,ae2)-> (add (string_to_reg id) (aexptoindex ae1) (aexptoindex ae2))
			|BOp2(Sub,ae1,ae2)-> (sub (string_to_reg id) (aexptoindex ae1) (aexptoindex ae2))
			|BOp2(Mul,ae1,ae2)-> (mul (string_to_reg id) (aexptoindex ae1) (aexptoindex ae2))
			|BOp2(Div,ae1,ae2)-> (let i1=mov R11 (aexptoindex ae1) in
										let i2=push (Reg(R11)) in
										let i3=mov R11 (aexptoindex ae2) in
										let i4=push (Reg(R11)) in
										let i5=pop R1 in
										let i6=pop R0 in
										let i7=(bl "div") in
										let i8=mov (string_to_reg id) (Reg(R0)) in
										let t=Arm.concat	([prefunc;i1;i2;i3;i4;i5;i6;i7;postfunc]) in
														(if not (id<>"R0") then
																	((Arm.concat [t]))
		 												else (Arm.concat [(push (Reg(R0)));t;i8;(pop R0)])	)	)

			|BOp2(Mod,ae1,ae2)-> (let i1=mov R11 (aexptoindex ae1) in
										let i2=push (Reg(R11)) in
										let i3=mov R11 (aexptoindex ae2) in
										let i4=push (Reg(R11)) in
										let i5=pop R1 in
										let i6=pop R0 in
										let i7=(bl "mod") in
										let i8=mov (string_to_reg id) (Reg(R0)) in
										let t=Arm.concat	([prefunc;i1;i2;i3;i4;i5;i6;i7;postfunc]) in
														(if not (id<>"R0") then
																	((Arm.concat [t]))
														else (Arm.concat [(push (Reg(R0)));t;i8;(pop R0)])	)	)


			|BAtom(ae) ->(mov (string_to_reg id) (aexptoindex ae) )
			|BMkArray(ae1,ae2) ->( let i1=mov R11 (aexptoindex ae1) in
														let i2=push (Reg(R11)) in
														let i3=mov R11 (aexptoindex ae2) in
														let i4=push (Reg(R11)) in
														let i5=pop R1 in
														let i6=pop R0 in
														let i7= (bl "make_array") in
													 	let i8=mov (string_to_reg id) (Reg(R0)) in
														let t=Arm.concat ([prefunc;i1;i2;i3;i4;i5;i6;i7;postfunc]) in
											(if not (id<>"R0") then
														((Arm.concat [t]))
											else (Arm.concat [(push (Reg(R0)));t;i8;(pop R0)])	)	)
	    |BGetArray(ae1,ae2) -> (let i1=mov R11 (aexptoindex ae1) in
														let i2=push (Reg(R11)) in
														let i3=mov R11 (aexptoindex ae2) in
														let i4=push (Reg(R11)) in
														let i5=pop R1 in
														let i6=pop R0 in
														let i7= (bl "get_array") in
														let i8=mov (string_to_reg id) (Reg(R0)) in
														let t=Arm.concat [prefunc;i1;i2;i3;i4;i5;i6;i7;postfunc] in
											(if not (id<>"R0") then
														((Arm.concat [t]))
											else (Arm.concat [(push (Reg(R0)));t;i8;(pop R0)])))
			|BSetArray(ae1,ae2,ae3) ->(*let i1 = mov R0 (aexptoindex ae1) in
													 let i2 = mov R1 (aexptoindex ae2) in
													 let i21 = mov R2 (aexptoindex ae3) in*)
													 (let i1=push (aexptoindex ae1) in
													 let i2=mov R11 (aexptoindex ae2) in
													 let i3=push (Reg(R11)) in
													 let i4=mov R11 (aexptoindex ae3) in
													 let i5=push (Reg(R11)) in
													 let i6=Arm.concat [pop R2;pop R1;pop R0] in
													 let i7= (bl "set_array") in
													 (*let i8=mov (string_to_reg id) (Reg(R0)) in *)
													 let t=Arm.concat [prefunc;i1;i2;i3;i4;i5;i6;i7;postfunc] in
													 (Arm.concat [(push (Reg(R0)));prefunc;t;postfunc;(pop R0)]))
							(*		CLEANUP				 (if not (id<>"R0") then
		 		 (*							 					(Arm.concat [t]) *)
				 (Arm.concat [(push (Reg(R0)));prefunc;t;postfunc;(pop R0)])
													 else
				 (Arm.concat [(push (Reg(R0)));prefunc;t;postfunc;(pop R0)])))  *)
		 	|BFun(fid,args,ae1)->
												(if not (id<>"R0") then
							 	(	let i1=push (Reg(R1)) in
									let i2=adr R1 fid in
									let i3=str ~index:(ix (Imm(4))) (Reg(R1)) (string_to_reg id)  in
									let i4=pop R1 in
									(Arm.concat [i1;i2;i3;i4]	)	)
								else
									(	let i1=push (Reg(R0)) in
									let i2=adr R0 fid in
									let i3=str ~index:(ix (Imm(4))) (Reg(R0)) (string_to_reg id)  in
									let i4=pop R0 in
									(Arm.concat [i1;i2;i3;i4]	)	)	)

			|BApp(ae,arags)-> 		(let rc_local=ref 0 in
											let fold_fun arg asmls=
												let i0=mov R11 (aexptoindex arg) in
												let i1=push (Reg(R11)) in
												List.append  [i0;i1] asmls in (*arg2,arg1*)
											let asmpushargs=List.fold_right fold_fun (ae::arags) [] in
											let asmpushargs=Arm.concat asmpushargs in
											let fold_fun arg asmls=
													rc_local:=!rc_local+1 ;
													List.append [(pop (string_to_reg
														("R"^(string_of_int (!rc_local-1)))))] asmls in
											let asmpopargs=List.fold_right fold_fun (ae::arags) [] in
											let asmpopargs=Arm.concat asmpopargs in
											let a0=add R11 (Reg(PC)) (Imm(8)) in
											let a1=mov LR (Reg(R11)) in
											let b1=ldr  ~index:(ix (Imm(4))) R11 (R0) in
											let b2=bx R11 in
											let i8=mov (string_to_reg id) (Reg(R0)) in
											let t=Arm.concat [callersave_id_is_r0;
												asmpushargs;asmpopargs;a0;a1;b1;b2;callerload_id_is_r0] in
											if not (id<>"R0") then
														t
	 									 	else
											 (Arm.concat [(push (Reg(R0)));t;i8;(pop R0)])	)
					;;

let rec anftoasm (ane:anfexp):(Arm.assembly)=
	match ane with
		| ELet(id,be,ane1) ->(Arm.seq (bexptoasm id be) (anftoasm ane1))
		| ERet(ae) -> (Arm.seq callee_restore (Arm.seq (mov R0 (aexptoindex ae)) (bx LR)))
		| EIf(ae,ane1,ane2) -> (	let lbend=getfreshlabel () and
																lbeq=getfreshlabel () in
															let i0=mov (R11) (aexptoindex ae) in
															let i1=(cmp (Reg(R11))	 (Imm(0))	) in
															let i2=(b ~cond:EQ lbeq) and
															i3=(anftoasm ane1) and
															i4=(b lbend) and
															i5=(label lbeq) and
															i6=(anftoasm ane2) and
															i7=(label lbend) in
															Arm.concat [i0;i1;i2;i3;i4;i5;i6;i7]	)
		 | _ -> failwith "assembly conversion not complete"
	;;


(*let program:exp=from_string
	"   let a=fun f(x)->x+3 in a(1) " ;; *)
(*" MAIN PROBLEM
" let a=fun f(x)->x+3 in
	let b=fun g(y)->(a(y)+2) in b(10)

					"

";;*)

let compile (program:exp):(string)=
				let program=gen_scope_vars program in
				(*		 STEP 1	*)
				find_free_vars_in_exp program ;
				(*** DEBUG print_global_func_free_dic !global_func_free_dic ;;  **)
			 	(* 		STEP 2	*)
				let program=closureconvert program [] in
				(*** DEBUG print_exp program;; ***)
				(*** STEP 2 ****)
				(****STEP 3 ****)
				let anfe=exptoanf program deffunction in
				(* DEBUG printf "%s" (anfexptostring anfe) ;; *)
				(*** STEP 3 ****)
				(**** STEP 4 BEGIN*****)
				let gl=rgalloc anfe "global" in
				(*printf "%s" (anfexptostring gl);;*)
					(*****DEBUG printf "%s" (anfexptostring anfe) ;;
				 	printf "%s" (anfexptostring gl) ;;
					print_func_var_to_reg_dict !func_var_to_reg_dict;; ***)
				(**** STEP 4 END*****)

				(**** STEP 5 BEGIN*****)
				move_func_to_global_scope gl ;
				(add_to_func_body_dict "start" (BFun("start",[],gl)));
				(***** STEP 5 END ****)
				(****** BUILD AND DEPLOY ASSEMBLY STRING *****)

				let map_func_body_dict a=
						let i=(fst a) in
						let bfun=(snd a) in
						match bfun with
							|BFun(_,_,ane1)-> (i,anftoasm ane1)
							| _ -> failwith "Unexpected iteration" in

				let asm_map_of_functions =List.map  map_func_body_dict	!global_func_body_dict  in
				let finalstring= ref "" in
				let iterfunc a=
						finalstring:=!finalstring^(sprintf "\n%s:\n" (fst a)) ;
						finalstring:=!finalstring^(sprintf "%s\n%s\n" (Arm.string_of_assembly callee_save) (Arm.string_of_assembly (snd a))) in

				let global_header="\n.text
				\n.global ez_alloc
				\n.global ez_abort
				\n.global start
				\n.align 4
				"	in
				finalstring:=global_header;
				List.iter iterfunc asm_map_of_functions;
				!finalstring ;;

let _ =
  let filename : string = Sys.argv.(1) in
	let out_filename = Sys.argv.(2) in
  let program : exp = from_file filename in
	let asm:string=(compile program) in
	let out_chan = open_out out_filename in
  output_string out_chan asm;
  close_out out_chan
;;
