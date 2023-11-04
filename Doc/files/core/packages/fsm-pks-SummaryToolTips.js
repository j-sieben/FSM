﻿NDSummary.OnToolTipsLoaded("File:core/packages/fsm.pks",{91:"<div class=\"NDToolTip TClass LSQL\"><div class=\"TTSummary\">Implements core functionality of the Finite State Machine.&nbsp; The package contains the implementation of the abstract class FSM_TYPE and provides generic functions for logging and administration of events and status changes.</div></div>",100:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype100\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> drop_object(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_objects_v.fsm_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method to remove an existing FSM object</div></div>",102:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype102\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> raise_event(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return integer</span></div></div><div class=\"TTSummary\">On an abstract level this methods only task is to take care of logging.&nbsp; Is called by the corresponding function of type FSM_TYPE.</div></div>",103:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype103\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> persist(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method persists FSM_TYPE attributes of a concrete derived class in FSM_OBJECT.&nbsp; Called by the constructors of the derived classes to to create an entry in FSM_OBJECT.&nbsp; If available, attributes are updated, otherwise the class is created again.</div></div>",104:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype104\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> retry(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method called when an event produces an error.&nbsp; It checks if the event can be executed again (possibly based on a schedule) If positive, it throws the event again. If not, the FSM is set to status ERROR.</div></div>",105:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype105\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> allows_event(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\">fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return boolean</span></div></div><div class=\"TTSummary\">Method checks if an fsm allows an event to be searched for.&nbsp; Called by APEX application to check whether a control should be displayed or executed</div></div>",106:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype106\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> set_status(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return number</span></div></div><div class=\"TTSummary\">Method sets the status of an FSM instance. Overloaded as procedure.&nbsp; A new status is determined by the logic of the event handler or by calling GET_NEXT_STATUS.&nbsp; Based on the new status, allowed events are determined.&nbsp; If the following event is automatic, it will be triggered immediately, otherwise FSM waits for the event to be triggered externally.&nbsp; The procedure overload sets validity at the FSM instance attribute only.</div></div>",107:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype107\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> set_status(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Procedure overload See FSM.set_status</div></div>",108:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype108\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> get_next_status(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return varchar2</span></div></div><div class=\"TTSummary\">Method to determine the next possible status. Is called to determine the next state based on the transitions given.&nbsp; If there is no next state, an error is thrown, because this is caused by a wrong parameterization.&nbsp; A call is only possible if there is at most one transition to one next state.&nbsp; If more than one status can be reached, the status must be determined by logic and set directly.</div></div>",109:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype109\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> notify(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_msg&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> pit_util.ora_name_type,</td></tr><tr><td class=\"PName first\">p_msg_args&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> msg_args</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method saves a note to an fsm instance. The procedure is called during processing to add annotations.</div></div>",110:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype110\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> to_string(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return varchar2</span></div></div><div class=\"TTSummary\">Method to convert the object into a string. Is used to get an overview of the class attributes.</div></div>",111:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype111\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> finalize(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">&quot;Destructor&quot;, cleans up the object</div></div>"});