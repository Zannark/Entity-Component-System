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
	{
    	this.Entities["Temp"] = null;
		this.Entities.remove("Temp");
	}

	public void Register(BaseEntity Entity)
	{
		CheckEntity(Entity.GetID());
		this.Entities[Entity.GetID()] = Entity;
	}

	private void CheckEntity(string Name)
	{
		auto Valid = (Name in Entities);
		
		if(Valid !is null)
			throw new SystemException("Entity " ~ Name ~ " does not exsist.");
	}

	private BaseEntity[string] Entities;
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

	System Sys = new System();
	Sys.Register(new TestEntity("Test"));
	assertThrown!SystemException(Sys.Register(new TestEntity("Test")));
}