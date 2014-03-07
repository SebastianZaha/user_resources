UserResources
=============

Many Rails applications are built as REST apis that manipulate resources. The app logic generally
revolves around __users__ manipulating these resources. Hence the operations on a
resource, spread over the controller and model would go through the following steps:

* fetch the resource object (controller)
* check permissions of current_user to edit it (model)
* sanitize input data for this resource (model / controller)
* save the resource (controller)
* process possible side effects (model)
* respond to client (render / redirect) or handle exceptions raised in previous steps (controller)

This gem attempts to provide helpers and best practices for this kind of user & resource-management
centric apps. That way you do not have to worry about much of the boilerplate, and the
resulting code will have a sane architecture with readable and maintainable conventions.

Example
-------

To present the workflow, we will use a hypothetical chat application. It has users that can create
channels and post messages to them. The db structure would look something like:

```ruby
create_table :channels do |t|
  t.string  :name
end
create_table :channel_rights do |t|
  t.integer :user_id
  t.integer :channel_id
end
create_table :chat_messages do |t|
  t.integer :channel_id
  t.integer :author_id
  t.string  :text
end
```

The Model
---------

Let's assume we can already create channels and invite other users to join them, and now we want
to handle the input of messages. So we create first a model:

```ruby
class ChatMessage < ActiveRecord::Base

  include UserResources::Model

  belongs_to :author, class_name: User
  belongs_to :channel

  validates_presence_of :author, :channel, :text

  attr_immutable :channel_id, :author_id


  def editable_by?(user)
    channel ? channel.members.include?(user) : true
  end
end
```

### Permissions

Including `UserResources::Model` provides ChatMessage with 2 methods: `user_update` and
`user_destroy`. They both require the model to define `editable_by?(user)`.

These 2 methods check that the user is allowed to edit the model, raise a `UserResources::Forbidden`
exception otherwise, and a `UserResources::Invalid` if any kind of validations fail.

The `editable_by?` method is called twice when using `user_update`. The first time is before the
new attributes are set on it. This checks that __the user is allowed to see and change this
resources in any way__.

Let us examine the possible ways this model could be restricted with regard to its channel
association.

1. A user is not allowed to change the channel of a message after he set it.

   For this type of attributes, UserResources::Model provides the class method `attr_immutable`,
   which can seen in the snippet above. All attributes declared like that will be ignored on
   subsequent updates after the object is first persisted.

2. A user can move a message to another channel, as long as he has access to the
   destination channel.

   This case is already covered by `user_update` because editable_by? is called a second time after
   the attributes have been set. This ensures that even after the object changed, it is still
   accessible to the person who changed it.

You can see more details in [the model file](lib/user_resources/model.rb).

__Please note:__ These checks are done only when you modify your models through our `user_update`
and `user_destroy` methods. All other direct manipulation of these models is unchecked. You might
want to do those thigs of course, from administration consoles / interfaces, but know that when you
do, all bets are off.

### Sanitization

One type of sanitization (immutable attributes) is covered in the previous section.

Other types of sanitization are:
* initializing fields with default values (like timestamps, default colors etc).
* generating random tokens when initializing, salt values, etc
* truncating strings to a max length (new versions of mysql throw exceptions by default if you send
  too long strings)

This gem does not provide any helpers for this, but we suggest having a convention for all models,
like the following which uses the `before_validation` rails callback:

```ruby
before_validation :sanitize_attributes

protected

def sanitize_attributes
  self.name    = self.name[0..254]
  self.token ||= Security.generate_token
end
```

### Side-Effects

Somtimes the business logic of your model defines side effects of some type of resource changing.
Let's say in our chat example, whenever someone posts a message, the other channel memebers should
be notified. I'd do this with another model filter in our message model:

```ruby
after_create :notify_members

protected

def notify_members
  channel.members.each do |m|
    if m != author
      Mailer.notify_message(m, self, author).deliver
    end
  end
end
```

The message would be something like `Hello #{m.name}, #{author.name} posted #{msg.text}`.

Now let us assume we wish to send the same notfications whenever a message is _modified_, not only
created. However, in our notification email we have to refer to the person who is modifying the
message. How would we do that with a callback, since the message model does not know who is
 modifying it, it only has a reference to `author`, which is the original author of the message.

UserResources has an answer to that. As long as your resource is modified with `user_update` or
`user_destroy`, the mixin provides access to the following 2 attributes, for the entire callback
stack during an update to the resource:
  * `user_performing_update`
  * `attributes_from_client`

This means that we could solve our little problem with the following callback:

```ruby
after_update :notify_members, if: :user_performing_update

protected

def notify_members
  channel.members.each do |m|
     if m != user_performing_update
       Mailer.notify_message(m, self, user_performing_update).deliver
     end
  end
end
```

The Controller
--------------

Since we handled many of the points of our introduction already (in the model), the controller does
not have to do much anymore. This is what it would look like:

```ruby
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController

  # We need users to be logged in. This filter is provided by your authentication mechanism.
  before_filter :login_required

  include UserResources::ControllerActions
  enable_user_resource_actions(Message, [:create, :update, :destroy])
end
```

The `enable_user_resource_actions` call sets up the 3 methods in this controller. The methods
are [very simple](lib/user_resources/controller_actions.rb) and only initialize the object and
call `user_update` on it, then calling `respond_with` for the result.

Exceptions
----------

One last thing on our list, handling exceptions. Add the following to `ApplicationController`:

```ruby
rescue_from UserResources::Forbidden, with: :render_forbidden
rescue_from UserResources::Invalid, with: :render_invalid
```


License (MIT)
-------------

Copyright 2014 Sebastian Zaha

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

