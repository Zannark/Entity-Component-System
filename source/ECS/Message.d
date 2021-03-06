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

module ECS.Message;

import std.typecons;
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

alias SendInformation = Tuple!(SendStatus, ComponentMessage!Object);

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
