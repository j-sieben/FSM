﻿NDSummary.OnToolTipsLoaded("File:core/packages/fsm.pkb",{126:"<div class=\"NDToolTip TClass LSQL\"><div class=\"TTSummary\">Implementation of the FSM package</div></div>",128:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype128\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> persist_retry(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_retry_schedule&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_objects.fsm_retry_schedule<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method persists retry of a FSM instance to achieve a new status.&nbsp; Is called when a FSM instance could not achieve a new status and retries to reach it.</div></div>",129:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype129\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> proceed_with_error_event(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method stops retriggering an event and sets the instance to error status.&nbsp; As no retry is allowed, the method examines the metadata to find transitions that have to be executed in case of error.&nbsp; If no transition is found, it will use a generic FSM_ERROR event.</div></div>",130:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype130\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> log_change(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td><td></td><td class=\"last\"></td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td><td class=\"PDefaultValueSeparator\">&nbsp;<span class=\"SHKeyword\">default</span>&nbsp;</td><td class=\"PDefaultValue last\"><span class=\"SHKeyword\">null</span>,</td></tr><tr><td class=\"PName first\">p_fst_id&nbsp;</td><td class=\"PType\"><span class=\"SHKeyword\">in</span> fsm_status.fst_id<span class=\"SHKeyword\">%type</span></td><td class=\"PDefaultValueSeparator\">&nbsp;<span class=\"SHKeyword\">default</span>&nbsp;</td><td class=\"PDefaultValue last\"><span class=\"SHKeyword\">null</span>,</td></tr><tr><td class=\"PName first\">p_msg&nbsp;</td><td class=\"PType\"><span class=\"SHKeyword\">in varchar2</span></td><td class=\"PDefaultValueSeparator\">&nbsp;<span class=\"SHKeyword\">default</span>&nbsp;</td><td class=\"PDefaultValue last\"><span class=\"SHKeyword\">null</span>,</td></tr><tr><td class=\"PName first\">p_msg_args&nbsp;</td><td class=\"PType\"><span class=\"SHKeyword\">in</span> msg_args</td><td class=\"PDefaultValueSeparator\">&nbsp;<span class=\"SHKeyword\">default</span>&nbsp;</td><td class=\"PDefaultValue last\"><span class=\"SHKeyword\">null</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">Method to maintain FSM_LOG. Called to log status changes, events and notifications from FSM</div></div>",132:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype132\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> drop_object(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_objects_v.fsm_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">See&nbsp; FSM.drop_object</div></div>",133:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype133\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> persist(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">See&nbsp; FSM.persist</div></div>",134:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype134\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> raise_event(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return integer</span></div></div><div class=\"TTSummary\">See&nbsp; FSM.raise_event</div></div>",135:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype135\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> retry(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">See&nbsp; FSM.retry</div></div>",136:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype136\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> allows_event(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\">fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return boolean</span></div></div><div class=\"TTSummary\">See&nbsp; FSM.allows_event</div></div>",137:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype137\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> set_status(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return number</span></div></div><div class=\"TTSummary\">See&nbsp; FSM.set_status</div></div>",138:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype138\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> set_status(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">See&nbsp; FSM.set_status</div></div>",139:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype139\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> get_next_status(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_fev_id&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_events_v.fev_id<span class=\"SHKeyword\">%type</span></td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return varchar2</span></div></div><div class=\"TTSummary\">See&nbsp; FSM.get_next_status</div></div>",140:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype140\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> notify(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in out nocopy</span> fsm_type,</td></tr><tr><td class=\"PName first\">p_msg&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> pit_util.ora_name_type,</td></tr><tr><td class=\"PName first\">p_msg_args&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> msg_args</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">See&nbsp; FSM.notify</div></div>",141:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype141\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function</span> to_string(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\"><span class=\"SHKeyword\">in</span> fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div><div class=\"PSection PPlainSection\"><span class=\"SHKeyword\">return varchar2</span></div></div><div class=\"TTSummary\">See&nbsp; FSM.to_string</div></div>",142:"<div class=\"NDToolTip TFunction LSQL\"><div id=\"NDPrototype142\" class=\"NDPrototype WideForm\"><div class=\"PSection PParameterSection PascalStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">procedure</span> finalize(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PName first\">p_fsm&nbsp;</td><td class=\"PType last\">fsm_type</td></tr></table></td><td class=\"PAfterParameters\">)</td></tr></table></div></div><div class=\"TTSummary\">See&nbsp; FSM.finalize</div></div>"});