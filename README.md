# FSM Finite State Machine

Light weight Finite-State machine implementation to dynamically control Business Flows

Despite of other implementations of this pattern this implementation is aimed to be used as a simple utility to include the functionality in your applications without the need for big and cumbersome frameworks.

## What it is and what it is not

Basically, a Finite State Machine is a design pattern to implement an abstract machine that can only be in a finite number of states, allowing only one state at a time. If it changes its state, an event has occurred that has triggered the state change. So a finite state machine may be defined as a list of states it is allowed to be in and a number of events that trigger a state change. Along with this, conditional logic can be implemented to decide when and which event shall occur. For a better explanation see [this](https://en.wikipedia.org/wiki/Finite-state_machine) article on Wikipedia.

This implementation tries to make the design pattern available within Oracle databases by implementing it in PL/SQL. Plus, some normally existing addons are left out in order to make the pattern small and easy to use. One of the left out addons is the possibility to externally define the flow of states and the transitions between them with a graphical tool and some kind of (mostly XML based) expression language. To keep things simple, the states, the events and the allowed transitions are stored in simple database tables whereas the conditional logic is implemented by »event listeners« (quoted because there really is no such thing as an event in PL/SQL) within a PL/SQL package which fire if an event is raised. So please don't mix a FSM up with something like Flow Control Charts rendered in BPMN. Although there are similarities, BPMN focusses on visualization of business processes whereas `FSM` implmenents work flows within the database. If you are more interested in this type of implementations, you may want to explore [Flows for APEX](https://github.com/flowsforapex/apex-flowsforapex).

Implementing a Finite State Machine only makes sense in complex environments where you want to separate control of the workflow from the business objects you are working with. Abstracting a Finite State Machine from your existing code into a generic utility schema only makes sense if you can foresee that you will be dealing with more than one business object going through a workflow. If you have only a single business object, the complexity of abstracting the functionality may not be worth the effort.

In a complex environments, other important points have to be obeyed:

- Security concerns mandates that the application may not be the owner of the tables and business logic
- Internationalization mandates that all meta data, such as the names of the states and events, as well as the log entries has to be translatable
- Seperating out a Finite State Machine is advisable only if it can be reused in different business environments. It is therefore best suited in a generich utility schema

These points result in a more complex data model, a separation into several schemas with the respective burdon of maintaining access grants and the like. Therefore, FSM ist not a simple "click and run" installation but requires some more in depth understanding of how it is coded and how to use it.

That said, implementing a Finite State Machine in PL/SQL has some additional challenges to offer, mainly, because PL/SQL is not an object oriented programming language. The challenge is to add some kind of programming paradigma that allows to stabilize the coding and not base it on convention programming. The only option to achieve this in PL/SQL I am aware of is using objects and their ability to create something that is similar to an interface in OO languages.

## Implementation

`FSM` is implemented in a specifically adopted version for databases. Databases are exceptionally well at storing status, events and transitions as well as any history of changes a `FSM` object has undergone. As the database offers a robust persistence engine, an implementation of a `FSM` in a database is also very robust and may span long times as well as very short time periods. Logging of status changes or any errors that may occur is simple and straightforward.

As explained above, `FSM` uses objects to stabilize the code basis. What this means is that an abstract object type `FSM_TYPE` is provided that offers all necessary methods to receive events, change status and log any movement along the allowed path of transitions as well as errors. If you want to control your concrete business object, you create an object for it that inherits from that central `FSM_TYPE`. This way, your new business object "knows" how to move in a transition tree, it can react to events and calculate the next status. Also, all logging is done automatically. You only add the attributes you need for you business object. 

As for logging `FSM` relies on [PIT](https://github.com/j-sieben/PIT) to be present. If you don't want to use PIT as the logging mechanism, a severe change to the code is required which may not be feasible.
`FSM_ADMIN_PKG` utilizes [UTL_TEXT](https://github.com/j-sieben/UTL_TEXT) as a code generator. This dependency does make sense but is easy to remove.

## How to work with it

Basic idea is to provide a user defined type `FSM_TYPE` that encapsulates all `FSM` related functionality. As usual, I don't implement the logic within the type body but delegate this to a package to take advantage of the more powerful possibilities of packages over types. Package `fsm` implements the details. It's main focus is to

- control the status the `FSM` instance is at
- throw (or rethrow) events if they are to be raised automatically
- log any movement of the `FSM`

The type has the following implementation:

```
create or replace type fsm_type
authid definer
as object(
  fsm_id number,
  fsm_fcl_id varchar2(50 char),
  fsm_fst_id varchar2(50 char),
  fsm_validity number,
  fsm_fev_list varchar2(4000),
  fsm_auto_raise char(1 byte),
  member function get_actual_status
    return varchar2,
  member function get_next_event_list
    return varchar2,
  member function get_validity
    return varchar2,
  member function raise_event(
    self in out nocopy fsm_type,
    p_fev_id in varchar2)
    return number,
  member procedure retry(
    self in out nocopy fsm_type,
    p_fev_id in varchar2),
  member function set_status(
    self in out nocopy fsm_type,
    p_fst_id in varchar2)
    return number,
  member procedure notify(
    self in out nocopy fsm_type,
    p_msg in varchar2,
    p_msg_args in msg_args default null),
  member function to_string
    return varchar2,
  member procedure finalize(
    self in out nocopy fsm_type)
) not instantiable not final;
```

Some important details: The type references a class (attribute `FSM_FCL_ID`). This class distinguishes several use cases. You define a class for every type of object you want to control with `FSM`. An example would be `REQ` for a request object that is managed by `FSM`, as can be seen in the sample application. Some member functions are offered to work with the `FSM` instance, but is important to understand that you can't work with `FSM_TYPE` directly, as it is missing any attributes for your specific use case.

To work with `FSM`, you start by defining an object type that derives from `FSM_TYPE`. In our sample application I use the following type:

```
create or replace type fsm_req_type under fsm_type(
  req_rtp_id varchar2(50 char),
  req_rre_id varchar2(50 char),
  req_text varchar2(1000 char),
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result,
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_fsm_id in number)
    return self as result,
  overriding member function raise_event(
    self in out nocopy fsm_req_type,
    p_fev_id in varchar2)
    return number,
  overriding member function set_status(
    self in out nocopy fsm_req_type,
    p_fst_id in varchar2)
    return number
);
```

As you can see, this type adds all specific attributes you need. In total, the object type now supports all generic attributes from `FSM_TYPE` plus your additional attributes. These attributes can be stored in whichever table you like, there is no specific requirement and they may even span more than one table. Seen from this table, `FSM` is unvisible. There is no requirement to change your data model or the storage logic by any means.

Next step is to define the status the object can take. It is advisable to think in small steps here, like `CREATED`, `INITIALIZED` and so on. Being finely granulated here pays off as the code to move from one status to the other is becoming even simpler the smaller the steps are. All status are stored at table `FSM_STATUS`. After having defined all your status, call method `fsm.CREATE_STATUS_PACKAGE` to create a package specification with constants for all status. They will have the naming convention `<CLASS>_<STATUS>`, so a status for class `REQ` named `INITIALIZE` will lead to a constant `REQ_INITIALIZED` within packge `FSM_FST` that is generated by the above call. Using this package instead of the hardcoded status names will prevent typos and therefore stabilize your code.

To move from status to status, you need to define Events. When thinking about the status it's quite natural to think about the events that are required to move around. All events are stored at table `FSM_EVENT`. After having defined all events, call method `fsm.CREATE_EVENT_PACKAGE` analogous to the status to create a respective package `FSM_FEV` with constants for all events.

The last meta data you need to define is called a transition. A transition combines a start status with an event and one or more target statuses. Transitions define the possible pathes from a start status to an end status. As an example, imagine a status of CREATED that receives an event called INITIALIZE. If this happens, a method is called that does the initialization on the business object, and if this was successfull, the state moves to INITIALIZED. From that state, two events may be allowed: CHECK and CANCEL. Based on the event that is raised on the object, the next step is then CHECKED or CANCELLED.

To implement logic, I always create a separate package for this. Reason is that the objects serve the sole purpose of adding the inheritance and interface mechanism, whereas all business logic is implemented in plain PL/SQL package. I also benefit from the more powerful options a package has, such as private methods or global private variables. In our example, this package is called `FSM_REQ`. Main task is to 

- organize the persistence of the specific attributes
- provide event handlers that handle incoming events and set the object to the next status.

Here is a simple example of such an event handler:

```
  function raise_initialize(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_initialize');    
    -- Logic goes here:
    -- - Things that have to be done for this status change (fi send a mail etc.), normally implemented as calls to a business layer

    -- Start by setting the validity of the FSM instance to TRUE
    p_req.fsm_validity := fsm.C_OK;

    -- - Logic to decide on the next status to achieve
    g_result := p_req.set_status(fsm_fst.REQ_IN_PROCESS);
    
    pit.leave_optional;
    return g_result;
  end raise_initialize;
```

You will find that most of the time only trivial logic is required. This sounds funny at first thought, but the reason for this is that being in a specific status by itself is valuable information. Think about a SQL query that tries to find finalized requests. It's very easy to tell the finalized requests from the requests in work by simply looking at their status. No additional work is required for this. In normal programming style, this information needs to be stored separately or decided by additional logic. Plus, metadata adds important knowledge, such as which events are allowed next.

To start, you may even create a default event handler for all transitions that have only one status as the target status (only if you have a choice of target status, you are required to provide the respective decision logic). To allow for that, package `FSM` provides a method called `fsm.get_next_status(<FSM instance>, <event>)` that calculates the next status the `FSM` can go to. Here's an example of such a default event handler:

```
  function raise_default(
    p_req in out nocopy fsm_req_type,
    p_fev_id in fsm_event.fev_id%type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_default',
      p_params => msg_params(msg_param('p_fev_id', p_fev_id)));
      
    p_req.fsm_validity := fsm.C_OK;
    g_result := p_req.set_status(
                  fsm.get_next_status(
                    p_fsm => p_req, 
                    p_fev_id => p_fev_id);
    
    pit.leave_optional;
    return g_result;
  end raise_default;
```

Should the logic become more complex, it is advisable to extract this logic into a business logic package and call the respective methods from here. The goal of the separation is to keep any logic that you would need even without the use of the `FSM` away from the `FSM` packages. This way, the business logic remains separated from the state control. To handle the events raised, method `fsm_req.raise_event` contains a simple `CASE` switch that points the incoming event to the right helper method:

```
    ...
    -- process event
    if is_allowed_event(p_req, p_fev_id) then
      -- Event switch
      case p_fev_id
      when fsm_fev.REQ_INITIALIZE then
        g_result := raise_initialize(p_req);
      < other events >
      else
        -- fallback to default handler
        raise_default(
          p_req => p_req,
          p_fev_id => p_fev_id);
      end case;
    else
      pit.warn(msg.fsm_EVENT_NOT_ALLOWED, msg_args(p_fev_id, p_req.fsm_fst_id), p_req.fsm_id);
      g_result := fsm.C_ERROR;
    end if;
```

If you examine the code, you will understand that the `FSM` »knows« which events are allowed to be raised. This information is taken from the meta data you provide (It's a list of all events referenced at the transition entries for the actual status) and it is updated with every status change. Therefore it is easy to tell allowed events from the invalid events.

That's about it. You now can run your code and it will follow the guided tours you set up with your transitions. Happy coding!

## Disclaimer

This code is YOYO software. It's free in any respect, you may redistribute it, change it, adopt it or do whatever you like. If extensions should seem to make sense, let me know, I will do my best to incorporate it. Please accept that it's impossible for me to offer support of any kind. Should an error occur, please let me know, I will gladly correct it.
