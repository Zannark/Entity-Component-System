module ECS.Entity;

import ECS.Message;

/*
	This is the base Entity, from which all other entity components
	will have to inherit from. Others would probably want to make 
	their own base entity which inherits from this on. 

	I.e
	GameObject : BaseEntity
	{
		SomeTransformObject Transform;
		///... Other black magic stuff
	}
*/
abstract class BaseEntity
{
	public this(string ID)
	{
		this.EntityID = ID;
	}

	///-----Functions used for sending messages across entities-----
	///An event which is triggered everytime a message is sent.
	protected void OnSend();
	///The function which is used to send messages across entities. Triggers OnSend.
	public SendStatus Send(ComponentMessage!Object Message);
	
	///The event which is triggered when ever a message is recieved.
	protected void OnRecieve();
	///The function which is called when ever a message is recieved.
	public void Recieve(ComponentMessage!Object Message);

	///-----Utility functions-----
	public string GetID()
	{
		return this.EntityID;
	}
	 
	///The ID which this entity is known for.
	///Possibly make faster by using an automatically assigned int?
	protected string EntityID;
}
unittest
{
	import std.stdio;

	class TestEntity : BaseEntity
	{
		public this(string ID)
		{
			super(ID);
			this.EntityID = ID;
		}

		protected override void OnSend()
		{
			writeln("Sent Message");
		}

		public override SendStatus Send(ComponentMessage!Object Message)
		{
			this.OnSend();
			return SendStatus.Success;
		}

		protected override void OnRecieve()
		{
			writeln("Recieved message");
		}

		public override void Recieve(ComponentMessage!Object Message)
		{
			this.OnRecieve();
		}
	}

	TestEntity Test1 = new TestEntity("T1");
	TestEntity Test2 = new TestEntity("T2");

	ComponentMessage!Object Message = ComponentMessage!Object("T1", "T2", Test1);

	TestEntity[2] T;

	T[0] = Test1;
	T[1] = Test2;

	T[0].Send(Message);
	T[1].Recieve(Message);
}

/*
	When system is implemented I want it to work like:
	
	System.Send(ComponentMessage!Object Message)
	{
		///Find the object linked to Message.Destination
		Entities[i].Send(Message);
	}
*/