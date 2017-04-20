module ECS.System;

import ECS.Entity;
import ECS.Message;

import std.exception;

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

	public void Register(BaseEntity Entity)
	{
		this.CheckEntityDoesNotExsist(Entity.GetID());
		this.Entities[Entity.GetID()] = Entity;
	}

	public void Unregister(string ID)
	{
		this.CheckEntityDoesExsist(ID);
		this.Entities.remove(ID);
	}

	public void EntityDo(string ID)
	{
		this.CheckEntityDoesExsist(ID);
		this.Entities[ID].Do();
	}

	public void AllDo()
	{
		foreach(Key; this.Entities.keys)
		{
			this.Entities[Key].Do();
		}
	}

	public bool Exsists(string ID)
	{
		return ((ID in Entities) !is null);
	}

	///I'm known for my short naming conventions
	private void CheckEntityDoesNotExsist(string ID)
	{
		auto Valid = (ID in Entities);
		
		if(Valid !is null)
			throw new SystemException("Entity " ~ ID ~ " does not exsist.");
	}

	private void CheckEntityDoesExsist(string ID)
	{
		auto Valid = (ID in Entities);

		if(Valid is null)
			throw new SystemException("Entity " ~ ID ~ " does not exsist.");
	}

	private BaseEntity[string] Entities;
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

		public override SendStatus Send(ComponentMessage!Object Message)
		{
			this.OnSend();
			return SendStatus.Success;
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

	writeln("Does an entity with ID 'Test' exsist? ", Sys.Exsists("Test1"));
	Sys.Unregister("Test1");
	writeln("Does an entity with ID 'Test' exsist (after System.Unregister)? ", Sys.Exsists("Test1"));
}