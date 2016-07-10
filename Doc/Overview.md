
# Overview: FCT
## Abstract base class
FCT is implemented around an object type called FCT_TYPE. It has the following specification:

```
create or replace type FCT_type 
authid definer
as object(
  FCT_id number,
  FCT_fcl_id varchar2(50 char),
  FCT_fst_id varchar2(50 char),
  FCT_fev_list varchar2(4000),
  FCT_validity number,
  FCT_auto_raise char(1 byte),
  member function get_actual_status
    return varchar2,
  member function get_next_event_list
    return varchar2,
  member function get_validity
    return varchar2,
  member function raise_event(
    p_fev_id in varchar2)
    return number,
  member procedure retry(
    p_fev_id in varchar2),
  member function set_status(
    p_fst_id in varchar2)
    return number,
  member procedure notify(
    p_msg in varchar2,
    p_msg_args in msg_args default null),
  member function to_string
    return varchar2,
  member procedure finalize
) not instantiable not final;
```

Its attributes have the following meaning:
- `FCT_ID`: Technical ID, created by a sequence upon first instantiation of this type.
- `FCT_FCL_ID`: Type of the concrete FCT instance, fi `DOC` if a concrete class `FCT_DOC` was instantiated
- `FCT_FST_ID`: Actual status the machine is in
- `FCT_VALIDITY`: Flag to indicate whether the machine is actually valid (`0`), retries to enter a new status (`> 1`) or invalid (`1`)
- `FCT_FEV_LIST`: Colon-separated list of all events that are allowed in the actual status according to the metadata (for convenience and to enhance speed)
- `FCT_AUTO_RAISE`: Flag to indicate whether the next allowed event (which in this case is limited to one) shall automatically be raised

Despite the getter methods to provide access to the attributes there are the following member methods:
- `RAISE_EVENT`: Is called to transit the instance of a class to a new state
- `RETRY`: is called when a transition was not succesful and more retries are allowed. This could be the case if you fi send a file via fax and the connection cannot be established on first try. You then may have parameterized that it retries this three times every five minute before raising an exception
- `SET_STATUS`: Is called if a new status has been reached. Logs this and potentially raises a new event if this event is parameterized to be raised automatically
- `NOTIFY`: Method that allows to log entries in a defined way. If you call this method from within your code, the passed in message will go the central logging
- `TO_STRING`: Method to print an instance of `FCT_TYPE`. Basically, it returns a formatted string of the instance attributes.
- `FINALIZE`: Method to clean up after an instance has been destroyed

Clause `NOT_INSTANTIABLE NOT FINAL` controls that no direct instance of `FCT_TYPE` is allowed to be created but it's allowed to inherit from that class to create concrete FCT machine implementations.

## Concrete FCT implementation
Say you want to have a concrete implementation of this concept in your code. For this example, I assume that you want to have a FCT that controls requests for database privileges. An application is designed to allow users to request database privileges from the DBA department. The implementation might look like this (attributes for the concrete rights etc. are ignored for simplicity):
```
create or replace type fct_req_type under fct_type(
  req_rtp_id varchar2(50 char), -- Reference ot a privilege type (say OBJECT_PRIV|SYSTEM_PRIV)
  req_rre_id varchar2(50 char), -- Reference to a requestor (the user that requests the privilege)
  req_text varchar2(1000 char),
  constructor function fct_req_type(
    self in out nocopy fct_req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result,
  constructor function fct_req_type(
    self in out nocopy fct_req_type,
    p_fct_id in number)
    return self as result,
  overriding member function raise_event(
    p_fev_id in varchar2)
    return number,
  overriding member function set_status(
    p_fst_id in varchar2)
    return number
);
```
You define additional attributes you require for this concrete implementation as attributes of the subtype. As this is a concrete class, you need a constructor function to enable you to create a concrete instance of this type. Plus, you need a constructor function with only a single parameter named `P_FCT_ID` to recreate a previously created (and persisted) instance. Any instance you create gets immediately persisted to a set of tables: `FCT_OBJECT` for the abstract attributes and `FCT_REQ_OBJECT` for the concrete attributes. Object oriented experts may have noticed that I chose the approach *table-per-class* to store the object instances. Plus, I recommend a view that combines both tables into one view called `FCT_REQ_OBJECT_VW`. Overriding the member functions `RAISE_EVENT` and `SET_STATUS` is required to implement the »event handlers« and to include basic status change logic for this concrete class.

Each concrete FCT type requires a type body to implement the methods. Basically all these methods do is pass the parameters to a package called `FCT_REQ_PKG` that really implements the functionality. 


## Metadata
To define the status, event and transitions, three tables are populated: `FCT_STATUS`, `FCT_EVENT`, `FCT_TRANSITION`. The type of the concrete class is secured by storing it in table `FCT_CLASS`. For convenience, FCT provides an admin package calle `FCT_ADMIN_PKG` with helper methods to create events, status and transitions. To create a complete set of status, events and transitions, you may want to review the following code, creating a status of `CREATED` and `IN_PROCESS`, an event called `INITIALIZE` that is allowed to be raised if the FCT is in status `CREATED` and transits the FCT to status `IN_PROCESS`. The last call creates this transition:
`````
begin
  fct_admin_pkg.merge_class(
    p_fcl_id => 'REQ',
    p_fcl_name => 'Privilege Request',
    p_fcl_description => 'Request to get a database privilege');
    
  fct_admin_pkg.merge_status(
    p_fst_id => 'CREATED',
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FCT_STATUS_CHANGED',
    p_fst_name => 'Request created',
    p_fst_description => 'Request has been created');
    
  fct_admin_pkg.merge_status(
    p_fst_id => 'IN_PROCESS',
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FCT_STATUS_CHANGED',
    p_fst_name => 'Request in process',
    p_fst_description => 'Request is in process');
    
  fct_admin_pkg.merge_event(
    p_fev_id => 'INITIALIZE',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FCT_EVENT_RAISED',
    p_fev_name => 'Initialize',
    p_fev_description => 'Initialize Request',
    p_fev_command => 'Initialize',
    p_fev_raised_by_user => false);
    
  fct_admin_pkg.merge_transition(
    p_ftr_fst_id => 'CREATED',
    p_ftr_fev_id => 'INITIALIZE',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'IN_PROCESS',
    p_ftr_raise_automatically => true);
    
  commit;
 
end;
/
```

To combine status and event, they are linked to each other in table `FCT_TRANSITION`. This table not only defines which events are allowed for a FCT in a given state but also if certain user roles are required for this event to be allowed. Additionally, it is possible that a certain event is raised only if the machine is in invalid state. This way it is possible to create fallback solutions and the like. Transitions may fire automatically or manually, either job-based or manually by calling `raise_evnet` on the respective class instance.

## Concrete package
To implement the functionality, a helper package is provided. Most methods are fairly simple once you get the basic idea. Here's a sample code of a package body that is called by `FCT_REQ_TYPE`:
```
create or replace package body fct_req_pkg
as

  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;
  c_fcl_id constant varchar2(3 byte) := 'REQ';
  c_ok constant number := 0;
  c_error constant number := 1;
  c_initial_status constant varchar2(50 char) := fct_fst.req_created;

  g_result integer;
  g_new_status fct_status.fst_id%type;

  /* HELPER */
  /* procedure to persist an instance or changes for an instance*/
  procedure persist(
    p_req in fct_req_type)
  as
  begin
    pit.enter_optional('persist', c_pkg);

    -- propagation to abstract super class
    fct_pkg.persist(p_req);

    -- merge concreate instance attributes in table FCT_REQ_OBJECT
    merge into fct_req_object d
    using (select p_req.fct_id req_id,
                  p_req.req_rtp_id req_rtp_id,
                  p_req.req_rre_id req_rre_id,
                  p_req.req_text req_text
             from dual) v
       on (d.req_id = v.req_id)
     when matched then update set
          req_text = v.req_text
     when not matched then insert (req_id, req_rtp_id, req_rre_id, req_text)
          values(v.req_id, v.req_rtp_id, v.req_rre_id, v.req_text);

    commit;

    pit.leave_optional;
  end persist;


  /* EVENT HANDLER */
  function raise_initialize(
    p_req in out nocopy fct_req_type)
    return number
  as
  begin
    pit.enter_optional('raise_initialize', c_pkg);
    g_result := c_ok;
    -- Logic goes here
    p_req.fct_validity := g_result;
    pit.leave_optional;
    return p_req.set_status(fct_fst.req_in_process);
  end raise_initialize;


  /* OTHER EVENT HANDLERS */


  /* INTERFACE */
  procedure create_fct_req(
    p_req in out nocopy fct_req_type,
    p_req_id in number default null,
    p_req_fst_id in varchar2 default fct_fst.req_created,
    p_req_fev_list in varchar2 default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
  as
    l_req_id fct_req_object.req_id%type;
  begin
    pit.enter_optional('create_FCT_req', c_pkg);
    l_req_id := coalesce(p_req_id, fct_seq.nextval);

    p_req.fct_id := l_req_id;
    p_req.fct_fst_id := p_req_fst_id;
    p_req.fct_fev_list := p_req_fev_list;
    p_req.fct_fcl_id := c_fcl_id;
    p_req.req_rtp_id := p_req_rtp_id;
    p_req.req_rre_id := p_req_rre_id;
    p_req.req_text := p_req_text;

    if p_req_id is null then
      pit.verbose(msg.fct_created, msg_args(c_fcl_id, to_char(l_req_id)), l_req_id);
      g_result := p_req.set_status(fct_fst.req_created);
    else
      persist(p_req);
    end if;

    pit.leave_optional;
  end create_fct_req;


  procedure create_fct_req(
    p_req in out nocopy fct_req_type,
    p_req_id in number)
  as
    l_req fct_req_object_vw%rowtype;
  begin
    pit.enter_mandatory('create_fct_req', c_pkg);
    select *
      into l_req
      from fct_req_object_vw
     where fct_id = p_req_id;
    create_fct_req(
      p_req => p_req,
      p_req_id => l_req.fct_id,
      p_req_fst_id => l_req.fct_fst_id,
      p_req_fev_list => l_req.fct_fev_list,
      p_req_rtp_id => l_req.req_rtp_id,
      p_req_rre_id => l_req.req_rre_id,
      p_req_text => l_req.req_text);
    pit.leave_mandatory;
  end create_fct_req;


  function raise_event(
    p_req in out nocopy fct_req_type,
    p_fev_id in fct_event.fev_id%type)
    return integer
  as
  begin
    pit.enter_mandatory('raise_event', c_pkg);
    -- propagate event to super class
    g_result := fct_pkg.raise_event(p_req, p_fev_id);

    -- process event
    if instr(':' || p_req.fct_fev_list || ':', ':' || p_fev_id || ':') > 0 then
      -- Eventweiche
      case p_fev_id
      when fct_fev.req_initialize then
        g_result := raise_initialize(p_req);
      when fct_fev.req_check then
        g_result := raise_check(p_req);
      -- other events
      else
        pit.warn(msg.fct_invalid_event, msg_args(p_fev_id), p_req.fct_id);
      end case;
    else
      pit.warn(msg.fct_event_not_allowed, msg_args(p_fev_id, p_req.fct_fst_id), p_req.fct_id);
      g_result := c_ok;
    end if;
    pit.leave_mandatory;
    return g_result;
  end raise_event;


  function set_status(
    p_req in out nocopy fct_req_type)
    return integer
  as
  begin
    pit.enter_mandatory('set_status', c_pkg);
    persist(p_req);
    pit.leave_mandatory;
    return fct_pkg.c_ok;
  exception
    when others then
      return fct_pkg.c_error;
  end set_status;

end fct_req_pkg;
```

Main points are:
- Method `RAISE_EVENT` implements its functionality by providing a simple case statement to distinguish between the events passed in and call respective event handler methods.
- Each event handler method sets the machine to a new status and returns `FCT_PKG.C_OK` if no error has occurred and `FCT_PKG.C_ERROR` otherwise.
- An instance is persisted automatically, creating a new row in the respective instance tables or updating the information.
- If an event requires logic outside the maintenance of the status itself, it calls helper methods from other packages, such as `CHECK_PRIVILEGE` or similar.
- Any status and event does have its own message to be logged. It may be a generic message but can be very specific as well. The whole package is instrumented with calls to [PIT](http://github.com/j-sieben/PIT). Certain status changes provide additional information to the log by calling `<FCT_INSTANCE>.notify()`

## Dependency between metadata and packages
As a downside to this design, there is a dependency between the code located in packages and metadata defined in database tables. If you define an event in table `FCT_EVENT` there needs to be an event handler in package `FCT_DOC_PKG`. As of now, there is no way to force PL/SQL to check for those dependencies in both directions: It is possible to check that an event that is raised must exist in the table but it's not easily possible to assure that for any event defined in the table there is an event handler in the package.

The first requirement is achieved by automatically creating a status- and an event package: `FCT_FST` and `FCT_FEV` respectively. Package `FCT_FST` consists of a package specification only and defines a constant per status, combined of class type and status. In our example, there exists a constant named `FCT_FST.DOC_INITIALIZED` and an event called `FCT_FEV.DOC_INITIALIZE` which shall be referenced in the package to assure that any event or status referenced really exists.

The second requirement can only be achieved by either creating a code generator that creates the event switch (the case expression in the sample code in method `RAISE_EVENT`) and stubs for the event handlers or by checking the metadata from `USER_PROCEDURES` against the metatdata tables. Other options may be possible but they have not been implemented yet.

Reason for choosing this implementation is that if you omit this completely and make the call to the logic data driven as well, tow negative consequences will occur:
- PL/SQL is compiled and executed dynamically
- No dependency maintenance exists, so if a code is invalid, this will only show upon execution of the code

This was deemed to be even more negative than the solution found now. To check whether all events are correctly implemented, you may want to utilize PL/Scope. If present, the following query will give you the actual status of your implementation:

```
-- alter session set plscope_settings='IDENTIFIERS:ALL';
-- recompile all FCT packages

  with fcl as (
       select '<CLASS_NAME>' fcl_id
         from dual),
       class as (
       select fcl.fcl_id, 'FCT_' || fcl.fcl_id || '_PKG' fcl_pkg, count(*) amount
         from user_identifiers
        cross join fcl 
        where object_name = 'FCT_' || fcl.fcl_id || '_PKG'),
       events as (
       select distinct 'RAISE_' || fev_id fev_id, c.amount has_identifiers
         from FCT_event e
        cross join class c
        where fev_fcl_id in (c.fcl_id, 'FCT')
          and fev_active = 'Y'),
       event_handlers as (
       select name event_handler
         from user_identifiers i
        cross join class c
        where object_name = c.fcl_pkg
          and object_type in ('PACKAGE BODY')
          and usage in ('DEFINITION')
          and name like 'RAISE%'
          and name != 'RAISE_EVENT'),
       event_calls as (
       select name event_call
         from user_identifiers i
        cross join class c
        where object_name = c.fcl_pkg
          and object_type in ('PACKAGE BODY')
          and usage in ('CALL')
          and name like 'RAISE%'
          and name != 'RAISE_EVENT')
select case
       when e.has_identifiers = 0 then 'No PL/Scope information, recompile'
       when e.fev_id is null and h.event_handler is not null then 'Additional event in package: ' || h.event_handler
       when c.event_call is null and h.event_handler is not null then 'Non-called event in package: ' || h.event_handler
       when e.fev_id is not null and h.event_handler is null then 'Missing event handler in package: ' || e.fev_id
       else e.fev_id || ': OK' end result
  from events e
  full join event_handlers h on e.fev_id = h.event_handler
  full join event_calls c on e.fev_id = c.event_call;
```
