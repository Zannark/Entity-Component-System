/*
MIT License

Copyright (c) 2017 Daniel Crutchley-Bentham

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
	///Params:
	///		Message - The message to send.
	public SendInformation Send(ComponentMessage!Object Message);
	
	///The event which is triggered when ever a message is recieved.
	protected void OnRecieve();

	///The function which is called when ever a message is recieved.
	///Params:
	///		Message - The message to recieve.
	public void Recieve(ComponentMessage!Object Message);

	///-----Interaction functions------
	public abstract void Do();

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

		public override SendInformation Send(ComponentMessage!Object Message)
		{
			this.OnSend();
			return SendInformation(SendStatus.Success, Message);
		}

		public override void Do()
		{
			int Total = 0;
			for(int i = 1; i < 11; i++)
			{
				Total += i;
			}

			writeln(Total);
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