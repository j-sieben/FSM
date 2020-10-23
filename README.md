# FSM Finite State Machine

Light weight Finite-State machine implementation to dynamically control Business Flows

Despite of other implementations of this pattern this implementation is aimed to be used as a simple utility to include the functionality in your applications without the need for big and cumbersome frameworks.

## What it is and what it is not

Basically, a Finite State Machine is a design pattern to implement an abstract machine that can only be in a finite number of states, allowing only one state at a time. If it changes its state, an event has occurred that has triggered the state change. So a finite state machine may be defined as a list of states it is allowed to be in and a number of events that trigger a state change. Along with this, conditional logic can be implemented to decide when and which event shall occur. For a better explanation see [this](https://en.wikipedia.org/wiki/Finite-state_machine) article on Wikipedia.

This implementation tries to make the design pattern available within Oracle databases by implementing it in PL/SQL. Plus, some normally existing addons are left out in order to make the pattern small and easy to use. One of the left out addons is the possibility to externally define the flow of states and the transitions between them with a graphical tool and some kind of (mostly XML based) expression language. To keep things simple, the states, the events and the allowed transitions are stored in simple database tables whereas the conditional logic is implemented by »event listeners« (quoted because there really is no such thing as an event in PL/SQL) within a PL/SQL package which fire if an event is raised. So please don't mix a FSM up with something like Flow Control Charts rendered in BPMN. Although there are similarities, BPMN focusses on visualization of business processes whereas `FSM` implmenents work flows within the database.

Any event may be raised automatically, fi as a consequence of a new state the machine has entered, or manually, fi by pushing a button in an APEX application or by manually requesting the event using a call to the `FSM`.

Finite state machines are commonly used in parsers to control machines like printers or any other machine with a user interface and buttons and many other things. In this implementation, the `FSM` is geared towards storing and maintaining work flows that may occur in any application. One example would be an application that needs to maintain orders passed in from the end user. Imagine a system that needs to track the order, check it for correctness, process and archive it. Throughout the whole lifecycle exceptions may occur that influence the flow the order undergoes. Normally, in the design phase of such an application many changes occur which need to be implemented.
This is where `FSM` comes in. It abstracts the complexity away by separating the status change from the implementation logic of the different steps. As it generically logs all status changes, events and exceptions, a full documentation of the work flow is persisted in the database. The application can concentrate on implementing the functionality required to fulfill the needs of a concrete status the machine is in. So fi `FSM` controls that an order is passed to a check after having received. It will log that it sent the order to the check but it won't deal with how to check an order. This is left to the »event handlers« which in turn don't deal with logging or status changes.

»Event handlers« are highlighted here as PL/SQL does not allow for events. In the context of `FSM` they are simply a name for PL/SQL methods that are called based on a parameter name that selects the respective method. This parameter is called an »event« to stick to the commonly accepted understanding of what is happening here.

## Use case

As an example, I needed to implement a system that processes letters for patients in a hospital. A letter might have more than one addresse and, based on the addresse, may be sent by email information, per fax or per postal mail. The letter is in `.docx` format and contains the addresses as a data island within the document. Each letter is automatically opened in Word and creates a PDF for each addressee. The address and the filename of the respeecitve PDFs are written to a local file that is read into the database by using an external table.

This example was implemented using two `FSM` instances: `FSM_DOC` and `FSM_PDF`. An instance of `FSM_DOC` was created per letter that had to be processed whereas an instance of `FSM_PDF` was created per copy of the letter, including a reference to the `FSM_DOC` instance it belongs to.

If a `FSM_DOC` instance is created, it starts with a status `CREATED`. This status automatically triggers an event named `PROCESS` that instantiates `FSM_PDF` instances for each copy of the letter, based on the meta data of the external table. After having done that, the `FSM_DOC` instance transits to status `IN_PROCESS` and remains in that status until an event named `FINALIZE` is raised to transit to the last status, `PROCESSED`. This event is raised by each `FSM_PDF` instance once it is completly processed. Whether the `FSM_DOC` instance transits to `PROCESSED` depends on whether there are still open `FSM_PDF` instances (meaning instances that are not in status `PROCESSED`) left. Based on the outcome of the processing of the `FSM_PDF`instances (they may be processed normally or exit with a waring or an error), the final status of the `FSM_DOC` instance may be `PROCESSED_WARNING` or even `PROCESSED_ERROR`, indicating that one or more instances of `FSM_PDF` received a warning or an error. 

Each `FSM_PDF` instance may undergo a list of status like 
- `CREATED` (a `FSM_PDF` instance was successfully created)
- `PLAN_PRINT` (the instance determines on how to send the PDF to the addressee)
- `PRINTED` (the instance was successfully sent to an external printing partner and was reported as printed)
- `PROCESSED` (the instance was successfully delivered)

to name just some very common status. Obviously, there are more possible status like `IN_PROCESS`, `ERROR` or other options, but you get the picture.

The single most important advantage of having a flow engine in place is that the decision logic is separated from the code. An external table, holding the list of status, events and transitions, replaces all the conditional logic otherwise necessary to control the flow. Changes to this logic are easy to implement. In addition, the events that trigger the execution of a transition, may require some logic to decide upon whether a transition takes place or which status is chosen as the next status for the instance. This is realized by event handler procedures, wrapped into a package per FSM type. So if there is an FSM object type called `FSM_DOC` there is also a package called `FSM_DOC_PKG` that implements all necessary logic to handle the concrete `FSM`. It's main duty is to act as an interface between abstract `FSM_TYPE` class and application logic, fi to send a letter to an external service provider.

Implementing event handlers in a package and include logic there is sort of a breach with the normal approach of finite state machine theory, where the decision logic is part of the meta data. I decided against this approach as the decision often requires more complex logic such as database calls to be able to decide whether a transition can be successfully perfomed. Instead of putting this logic into a meta data repository (incurring al the disadvantages of dynamic PL/SQL), I decided to implement them in a package. The disadvantage of separating this logic from the meta data is superseeded by the advantage of directly implementing code. At least you keep another benefit: One event handler only takes care of what to do in this specific status and it only takes care about what it takes to get to the next status. Therefore, the even handler procedures are quite simple most of the times.

The flow can be easily extended an reorganized by creating and maintaing meta data within tables instead of controling complex case expressions. Changes to the flow have only minimal impact on the code itself. Most of the time, only an event handler for a newly inserted event has to be created.

The second most important advantage is that boring programming tasks like logging all changes etc. is reduced to a minimum by delegating this to the generic `FSM` mechanism. As a consequence of this, there is no need to even think about logging a state change, as this happens automatically anyway. Plus, based on meta data information about the status, the log entries can be attached to a severity, allowing to filter the log later on or to implement housekeeping services which elminate less important detail information while keeping the milestones for a longer time period. `FSM` provides a generic log table to store all status changes etc.

The responsibility of the `FSM` related database objects in this example are:
- `FSM` tables: Store metadata such as allowed status and events, transitions, log entries
- abstract `FSM_TYPE`: implement the generic functionality such as changing status, handling events and errors, logging
- concrete `FSM_DOC` (`FSM_PDF`) object: Store the attributes which are specific to a given letter, such as a technical name, a document path etc.
- package `FSM_DOC_PKG` (`FSM_PDF_PKG`): provide a method per event to be called when the event is thrown, act as an interface between the occurance of the event and the logic that has to be executed.

## Implementation

`FSM` is implemented in a specifically adopted version for databases. Databases are exceptionally well catered to store the list of status, events and transitions as well as any history of changes a `FSM` has undergone. As the database offers a robust persistence engine, an implementation of a `FSM` in a database is also very robust and may span long times as well as very short time periods. Logging of status changes or any errors that may occur is simple and straightforward.

Some basic database tables store the metadata for the `FSM`, whereas an abstract object type `FSM_TYPE` implements all necessary logic to receive events, change status and log all movements. `FSM` supports arbitrary concrete `FSM` types to allow to store application specific attributes with the machine. This concreate machines are implemented as objects which inherit from `FSM_TYPE`, such as `FSM_DOC` which works as a concrete FSM to organize a document oriented workflow.

All logic is implemented in PL/SQL using a simple design pattern to allow for easy extension and adoption to your own requirements. 

As for logging `FSM` relies on [PIT](https://github.com/j-sieben/PIT) to be present. If you don't want to use PIT as the logging mechanism, a severe change to the code is required which may not be feasible.
`FSM_ADMIN_PKG` utilizes [UTL_TEXT](https://github.com/j-sieben/UTL_TEXT) as a code generator. This dependency does make sense but is easy to remove.

## Disclaimer

This code is YOYO software. It's free in any respect, you may redistribute it, change it, adopt it or do whatever you like. If extensions should seem to make sense, let me know, I will do my best to incorporate it. Please accept that it's impossible for me to offer support of any kind. Should an error occur, please let me know, I will gladly correct it.
