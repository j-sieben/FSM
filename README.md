# FCT Flow Control Toolkit
Light weight Finite-State machine implementation to dynamicall control Business Flows

Despite of other implementations of this pattern this implementation is aimed to be used as a simple utility to include the functionality in your applications without the need for big and cumbersome frameworks.

## What it is and what it is not
Basically, a Finite State Machine is a design pattern to implement an abstract machine that can only be in a finite number of states, allowing only one state at a time. If it changes its state, an event has occurred that has triggered the state change. So a finite state machine may be defined as a list of states it is allowed to be in and a number of events that trigger a state change. Along with this, conditional logic can be implemented to decide when and which event shall occur. For a better explanation see [this](https://en.wikipedia.org/wiki/Finite-state_machine) article on Wikipedia.

This implementation tries to make the design pattern available within Oracle databases by implementing it in PL/SQL. Plus, some normally existing addons are left out in order to make the pattern small and easy to use. One of the left out addons is the possibility to externally define the flow of states and the transitions between them with a graphical tool and some kind of (mostly XML based) expression language. To keep things simple, the states, the events and the allowed transitions are stored in simple database tables whereas the conditional logic is implemented by »event listeners« (quoted because there really is no such thing as an event in PL/SQL) within a PL/SQL package which fire if an event is raised.

Any event may be raised automatically, fi as a consequence of a new state the machine has entered, or manually, fi by pushing a button in an APEX application or by manually requesting the event using a call to the FCT.

FCT are commonly used in parsers, to control machines like printers or any other machine with a user interface and buttons and many other things more. In this implementation, the FCT is geared towards storing and maintaining work flows that may occur in any application. One example would be an application that needs to maintain orders passed in from the end user. Imagine a system that needs to track the order, check it for correctness, process and archive it. Throughout the whole lifecycle exceptions may occur that influence the flow the order undergoes. Normally, in the design phase of such an application many changes occur which need to be included into the application.
This is where FCT comes in. It abstracts the complexity away by separating the status change from the implementation logic of the different steps. As it generically logs all status changes, events and exceptions, a full documentation of the work flow is persisted in the database. The application can concentrate on implementing the functionality required to fulfill the needs of a concrete status the machine is in. So fi FCT controls that an order is passed to a check after having received. It will log that it sent the order to the check but it won't deal with how to check an order. This is left to the »event handlers« which in turn don't deal with logging or status changes.

## Use case
As an example, I needed to implement a system that reads a number of word letters from a file system, open them, create PDFs for any addressee within the letter and send those PDFs, choosing a way that is best suited for the respective addressee. This could then mean that a copy of the letter to one addressee had to be sent by mail using an external service provider whereas another copy of the letter might be sent using email or fax. Any letter that was processed by the system needed to be check for correctness upfront, split into different PDF instances, each instance had to be processed according their addressees, spanning a potentially long time from start to finish. All process steps needed to be logged in a format that allows for easy reporting or analysis.

This example was implemented using two FCT instances: `FCT_DOC` and `FCT_PDF`. An instance of `FCT_DOC` was created per letter that had to be processed whereas an instance of `FCT_PDF` with a reference to the `FCT_DOC` it derived from was created per copy of the letter. A letter might undergo a list of possible status: 
- `CREATED`
- `IN_PROCESS`
- `PROCESSED`
where `IN_PROCESS` is a state where the letter waits for all copies to be succesfully sent to the addressees. Each copy may undergo a list of status like 
- `CREATED`
- `PLAN_PRINT`
- `PRINTED`
- `PROCESSED`
to indicate the most common status. If the status has reached `PROCESSED` the instance raises an error at the respective `FCT_DOC` instance it derived from. Based on this event and other conditional logic the letter then transits to a new status like `PROCESSED` as well.

The respective status can be easily extended an reorganized with only minimal impact on the code itself. The boring programming like logging all changes etc. is reduced to a minimum by delegating this to the generic FCT mechanism. The instances of the respective word and PDF documents are stored in simple database tables, along with a generic log table to store all status changes etc. The event handler and conditional logic are implemented in a specifically created package. So if there is an object type called `FCT_DOC` there is also a package called `FCT_DOC_PKG` that implements all necessary logic to handle the concrete FCT. It's main duty is to act as an interface between abstract `FCT_TYPE` class and application logic, fi to send a letter to an external service provider.

The responsibility of the FCT related database objects in this case are:
- FCT tables: Store metadata such as allowed status and events, transitions, log entries
- abstract `FCT_TYPE`: implement the generic functionality such as changing status, handling events and errors, logging
- concrete `FCT_DOC` object: Store the attributes which are specific to a given letter, such as a technical name, a document path etc.
- package `FCT_DOC_PKG`: provide a method per event to be called when the event is thrown, act as an interface between the occurance of the event and the logic that has to be executed.

## Implementation
The FCT is implemented in a specifically adopted version for databases. Databases are exceptionally well catered to store the list of status, events and transitions as well as any history of changes a FCT has undergone. As the database offers a robust persistence engine, an implementation of a FCT in a database is also very robust and may span long times as well as very short time periods. Logging of status changes or any errors that may occur is simple and straightforward.

Some basic database tables store the metadata for the FCT, whereas an abstract object type `FCT_TYPE` implements all necessary logic to receive events, change status and log all movements. FCT supports arbitrary concrete FCT types to allow to store application specific attributes with the machine. This concreate machines are implemented as objects which inherit from `FCT_TYPE`, such as `FCT_DOC` which works as a concrete FCT to organize a document oriented workflow.

All logic is implemented in PL/SQL using a simple desing pattern to allow for easy extension and adoption to your own requirements. Ideally, the logging mechanism is based on the multi language features of [PIT](https://github.com/j-sieben/PIT) because the requirements for logging within FCT are identical to those PIT takes care for already. It may also be used standalone. If PIT is not present during installation, it will install itself standalone with limited logging functionality. If you decide to recompile `FCT_TYPE` and `FCT_PKG` later without PIT being present, make sure to the PL/SQL compile flag `PIT_PRESENT` to `false`. Should you decide to extend FCT with PIT, install PIT first and then recompile FCT in a new session or set the compile flag to `true`.

## Disclaimer
This code is YOYO software. It's free in any respect, you may redistribute it, change it, adopt it or do whatever you like. If extensions should seem to make sense, let me know, I will do my best to incorporate it. Please accept that it's impossible for me to offer support of any kind. Should an error occur, please let me know, I will gladly correct it.
