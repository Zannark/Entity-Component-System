module ECS.System;

import ECS.Entity;
import ECS.Message;

import std.exception;
import std.container;

alias Message = ComponentMessage!Object;

/*
	Exceptions for the system class.
*/
class SystemException : Exception
{
	mixin basicExceptionCtors;
}

/*
	This is where all the entities are stored.
*/
class System
{
	public this()
	{}

	///Registers an entity to the System.
	///Params:
	///		Entity - The entity which is to be registered.
	public void Register(BaseEntity Entity)
	{
		this.CheckEntityDoesNotExsist(Entity.GetID());
		this.Entities[Entity.GetID()] = Entity;
	}

	///Removes an entity from the system.
	///The ID then can be used again.
	///Params:
	///		ID - The ID of the entity to remove.
	public void Unregister(string ID)
	{
		this.CheckEntityDoesExsist(ID);
		this.Entities.remove(ID);
	}

	///Calls the entity 'Do' function when required.
	///Params:
	///		ID - The ID of the entity to call 'Do' on.
	public void EntityDo(string ID)
	{
		this.CheckEntityDoesExsist(ID);
		this.Entities[ID].Do();
	}
	
	///Invokes 'Do' on all entities.
	public void AllDo()
	{
		foreach(Key; this.Entities.keys)
		{
			this.Entities[Key].Do();
		}
	}
	
	///Checks the entity exsists.
	///Params:
	///		ID - The ID of the entity.
	///Returns:
	///		True if the entity exsists. False otherwise.
	public bool Exsists(string ID)
	{
		return ((ID in Entities) !is null);
	}

	///Sends a message to an entity.
	///Params:
	///		Source - The ID of the entity of which is sending the message.
	///		Destination - The ID of the of the target entity of the message.
	///		Message - The message to send.
	public void Send(string Source, string Destination, Object Message)
	{
		this.CheckEntityDoesExsist(Source);
		this.CheckEntityDoesExsist(Destination);

		this.PendingMessages ~= this.Entities[Source].Send(ComponentMessage!Object(Source, Destination, Message))[1];
	}

	///Flushes all pending messages.
	public void FlushMessages()
	{
		for(int i = 0; i < this.PendingMessages.length; i++)
		{
			auto Message = this.PendingMessages[i];
			this.Entities[Message.Destination].Recieve(Message);
			this.PendingMessages.linearRemove(this.PendingMessages[i..i + 1]);
		}
	}

	private void CheckEntityDoesNotExsist(string ID)
	{
		auto Valid = (ID in Entities);
		
		if(Valid !is null)
			throw new SystemException("Entity " ~ ID ~ " already exsists.");
	}

	private void CheckEntityDoesExsist(string ID)
	{
		auto Valid = (ID in Entities);

		if(Valid is null)
			throw new SystemException("Entity " ~ ID ~ " does not exsist.");
	}

	private BaseEntity[string] Entities;
	private Array!Message PendingMessages;
}
unittest
{
	import std.stdio;

	final class TestEntity : BaseEntity
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

		public override SendInformation Send(ComponentMessage!Object Message)
		{
			this.OnSend();
			writeln("Sending message to " ~ Message.Destination);

			return SendInformation(SendStatus.Success, Message);
		}

		public override void Do()
		{
			int Total = 0;
			for(int i = 1; i < 11; i++)
			{
				Total += i;
			}

			writeln(this.EntityID, " ", Total);
		}

		protected override void OnRecieve()
		{
			writeln("Recieved message");
		}

		public override void Recieve(ComponentMessage!Object Message)
		{
			this.OnRecieve();
			writeln("Recieved message from " ~ Message.Source);
		}
	}

	System Sys = new System();
	Sys.Register(new TestEntity("Test1"));
	Sys.Register(new TestEntity("Test2"));
	Sys.Register(new TestEntity("Test3"));
	Sys.Register(new TestEntity("Test4"));
	Sys.Register(new TestEntity("Test5"));
	Sys.Register(new TestEntity("Test6"));

	assertThrown!SystemException(Sys.Register(new TestEntity("Test1")), "No exception thrown. " ~ __FILE__ ~ " " ~__LINE__);

	Sys.EntityDo("Test1");
	Sys.AllDo();

	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.Send("Test1", "Test2", new TestEntity("Boob"));
	Sys.FlushMessages();

	writeln("Does an entity with ID 'Test' exsist? ", Sys.Exsists("Test1"));
	Sys.Unregister("Test1");
	writeln("Does an entity with ID 'Test' exsist (after System.Unregister)? ", Sys.Exsists("Test1"));
}