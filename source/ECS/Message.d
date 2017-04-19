module ECS.Message;

import ECS.Entity;

/*
	Tells the system if a message has been sent properly,
	or if it failed to be recieved.
*/
enum SendStatus
{
	Success,
	Failure,
	Unknown
}

/*
	This allows for inter-entity communication across a single system.
	Entities outside of the system have no knowledge of other entities 
	in other systems.
*/
struct ComponentMessage(T)
{ 
	public this(string Source, string Destination, T Message)
	{
		this.Source = Source;
		this.Destination = Destination;
		this.Message = Message;
	}

	string Source;
	string Destination;
	T Message;
}
