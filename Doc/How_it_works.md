# How it works
Let's look at the moving parts in more detail. As an example, I'd like to show you a simple use case of an request for a grant.

## Create a concrete class
To create a new concrete FCT you inherit from `FCT_TYPE` and create a concrete class `FCT_ORDER`. I don't want to go into the details of attributes you want to store with this instance, say you store things like the kind of request `req_rtp_id`, the person who wants the grant `req_rre_id` and a text `req_text`. For the this example the attributes really don't matter.

Create a package called `FCT_REQ_PKG` to hold the FCT related logic and optionally a second package called `BL_REQ` to hold the business logic around the request process. Type `FCT_REQ_TYPE` will need to overwrite the abstract methods `RAISE_EVENT` and `SET_STATUS` and eventually `FINALIZE` if you need a specific destructor. As this method is a concrete method, it's mandatory to provide two constructor methods: One with all relevant attributes in place and a second that only takes the `FCT_ID` as a parameter to re-create the instance from the persistence layer. All type methods simply call methods in package `FCT_ORDER_PKG`.

As an example, review the following code from the samples folder (`fct` is assumed as the name for the finite state machine):

```
create or replace type fct_req_type under fct_type(
  req_rtp_id varchar2(50 char),
  req_rre_id varchar2(50 char),
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

It is important to create this class `under fct_type` as this is the inheritance mechanism supported by SQL. By overriding the `raise_event` and `set_status` methods you open a way into your own implementation within package `FCT_REQ_PKG`.

## Create the database objects
Besides the type and the package, you need a table or a combination of tables to store an instance of `FCT_REQUEST`. I don't advice to simply use an object oriented table and have a column of type `FCT_REQ_TYPE` as the downside of this approach is a significantly harder SQL access to data within the orders. I consider a »traditional« relational table to be the best option for storing data, even if it's used within an object.

The tables obviously need columns for all order attributes you want to store plus a reference to table `FCT_OBJECT` (if you don't want to use the primary key value for FCT as well) which stores the attributes of `FCT_REQ_TYPE` defined in the abstract type `FCT_TYPE`. To make it easy to work with those tables, I suggest a view that combines those two tables to one.

Add a line at table `FCT_CLASS` with the value `REQ` for the internal name of the new FCT machine.

## Define Status, Events and Transitions
No comes the core part. Our order has defined some status (`CREATED|GRANTED|IN_PRCESS`), each of which have to be inserted into table `FCT_STATUS`. Make sure to reference class `REQ` with each status and event. This later defines the constants that get created upon (re-)creation of the status and event packages. You may want to review the sample code, file `create_initial_data.sql` to review how this is done.

In table `FCT_TRANSITIONS` you define the transitions by combining the status and the events which are allowed to be raised within that specific status. For the sake of our example, say that status `CREATED` is the default status the FCT sets after creation. So in the constructor method you either set the latest status the FCT had (if you re-create it from the persistence layer) or you set the initial status by calling the newly created instance's `SET_STATUS` method.

To define that the request will go to a check process after creation automatically, you insert a line into `FCT_TRANSITIONS` stating that from status `CREATED` only event `INITIALIZED` is allowed and that is raised automatically (by setting column `FSE_RAISE_AUTOMATICALLY` to `Y`). Make sure that column `FSE_RAISE_ON_STATUS` is set to `0` to assure that this event is raised if status `CREATED` could be achieved without errors. Fill in the (list of) status that may possibly come out of the event. You don't need to cater for error events if you don't want anything special to happen. There is a standard `ERROR` event that gets raised should something happen.

Error events are used for defined call back strategies. So fi if your order gets to a state of manually checking it if the automatic check fails, you may define that an automatic event is raised when status is `1` by including a line for the status, the event, the outcome status and column `FSE_RAISE_ON_STATUS`set to `1`.

The same strategy may apply for the next step. You may also want to process the request automatically. This then leads to a second line in this table with respective values.

## Create the status and event packages
In order to avoid hard coded status and event names in the resulting code, package `FCT_ADMIN` provides two methods to create an event and a status package. These packages simply take the events and status entered so far and wrap them into two packages called `FCT_FEV` and `FCT_FST`. These packages define constants for all defined events and status, prefixed by their class type. So in our example, constants like `fct_fst.REQ_CHECKED` for a status or `fct_fev.REQ_IN_PROCESS` for an event get created. Make sure to create these packages whenever you change settings at `FCT_STATUS` or `FCT_EVENT` to make sure that these packages resemble the latest version.

## Add event handlers to package `FCT_REQ_PKG`
Main duty of method `RAISE_EVENT` of package `FCT_REQ_PKG` is to provide two things: 
-  A case switch that analyzes the event passed in and 
-  an internal helper method for any event that gets called by the event handler. 

An event handler has two duties:
- Call the business logic that needs to be executed if this event occurs. Normally these methods reside in package `BL_REQ` or any other package you see fit.
- Decide upon the next status the machine will reach. You may have only one choice here, in which case you can get the next status by calling a helper method called `fct_pkg.get_next_status` rather than hard coding it into your event handler. Alternatively you may also decide upon one of more possible next status based on the outcome of your business logic.

In any case, any event handler is expected to call method `set_status` on the active FCT and return the result of this to the calling environment. Should it turn out that the business logic does not allow for a new status, return `fct_pkg.C_FALSE` to indicate this.

## Done!
That's it, your FCT is now ready to work. If you ask yourself what the benefit of all this is, just imagine what you have to do if a new status has to be added to the scene or if more events come into play. Basically, all you need to do is add them to the respective tables and provide event handlers for it. As any event handler focusses on one clearly defined business case only, complexity is decreased. Why and when a certain status is reached, is now data driven and can be easily changed or adjusted over time.

I found it extremely valuable to be able to quickly change this. I recall that within a process, suddenly the requirement popped up to be able to cancel a process at a very specific state. That's not a problem with this approach: Simply add a `CANCEL` event at the respective point in the chain of transitions and provide an event handler for it. Concentrating on one problem at a time makes many work flow oriented systems easier to maintain.

## What's more?
One big advantage is that based on the separation of business logic and FCT logic, all logging is done consistently and completely. The data captured here is also a valuable source for other business logic: You may fi calculate which buttons or menu entries to show based on the actual status of a FCT or based on the history captured in the log so far.

To cater for this more easily, any event may have additional attributes to control the look and feel of a command on the UI. It also allows for a command name that might be used to call functionality on the UI. If you take APEX as an example, these attributes allow you to label a button, control it's visibility classes and have an action called if you click on it. As APEX supports creating UI elements based on metadata, information from FCT may control the list of buttons directly.
