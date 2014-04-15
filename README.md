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

  belongs_to :author, class_name: User
  belongs_to :channel

  validates_presence_of :author, :channel, :text
end
```

### Representing a user action on this model

```ruby
class ChatMessage::UserAction < UserResources::UserAction

  def allowed?
    @resource.channel.members.include?(@user)
  end
  
  # :channel_id and :author_id are immutable, we do not allow them to be updated after being set.
  def before_update(attrs)
    attrs.select { |k, v| k != :channel_id && k != :author_id }
  end
end
```

### Permissions

`UserResources::UserAction` provides us with 3 methods: `create`, `update` and `destroy`.

These methods check that the user is allowed to edit the model, raise a `UserResources::Forbidden`
exception otherwise, or an `ActiveRecord::RecordInvalid` if any kind of validations fail.

All we need to do in our inherited action class is provide a method `allowed?`. This method 
checks if `@user` has permissions to edit the resource `@resource`.

Let us examine the possible ways this model could be restricted with regard to its channel
association.

1. A user is not allowed to change the channel of a message after he set it.

   For this type of attributes, we need to filter them out when updating an existing resource. 
   We can do this by providing the method `before_update`. This method can process the attributes 
   and return a new hash that excludes them.
   
2. A user can move a message to another channel, as long as he has access to the
   destination channel.

   This case is already covered by `update` because `allowed?` will return false. This ensures that 
   even after the object changed, it is still accessible to the person who changed it.

You can see more details in [the model file](lib/user_resources/user_action.rb).

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

### Attribute pre-processing

Clients sometimes send data that is not exactly in the format we save it on our models. Normally
we would process this data in the controller, but since we're moving everything to the Action layer,
we can use a `before_save` method on the action.

The method takes the client attributes as a hash and should return another hash of
processed attributes in return.

```ruby

class ChatMessage::UserAction < UserResources::UserAction

  def before_save(attrs)
    preprocess_money(attrs)
  end
  
  private
   
  def preprocess_money(attrs)
    cleaned = attrs.clone
    # Convert client-sent dollar values('$1.25') into cents(125)
    cleaned[:money] = TextUtils.parse_money(attrs[:money])
    cleaned
  end
end
```

### Side-Effects

Somtimes the business logic of your model defines side effects of some type of resource changing.
Let's say in our chat example, whenever someone posts a message, the other channel memebers should
be notified. We can use the after_create method in the action for this:

```ruby
class ChatMessage::UserAction < UserResources::UserAction

  def after_create
    notify_members
  end
  
  private
  def notify_members
    @resource.channel.members.each do |m|
      if m != @resource.author
        Mailer.notify_message(m, @resource, @user).deliver
      end
    end
  end
end
```

The message would be something like `Hello #{m.name}, #{user.name} posted #{msg.text}`.

Note that we are using `@user` here for the notification. `@user` in an action represents the 
author of that action. 

The Controller Actions
----------------------

Since all our logic has moved to the actions, controller methods are very thin now:

```ruby
class ChatMessagesController < ApplicationController
  
  def create
    model = ChatMessage.new
    action = ChatMessage::UserAction.new(model, current_user)
    respond_with(action.create(params))
  end
```

Since all controllers for your models will end up looking identical, this gem provides you with
a helper that exposes these methods.

Fist, include the helpers by putting `include UserResources::Controller::Actions` in 
your `ApplicationController`. Then:

```ruby
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController

  # We need users to be logged in. This filter is provided by your authentication mechanism.
  before_filter :login_required

  enable_user_resource_actions(Message, [:create, :update, :destroy])
end
```

### Exception handling

The gem also provides a module that automatically handles forbidden and invalid exceptions 
with the methods `render_forbidden` and `render_invalid`. See
[the exception_hadling module](user_resources/controller_exception_handling.rb) for details.

You can override them in your controllers for special handling.

For example, in a HTML based controller for editing a user's attributes, you'd override it like:

```ruby
protected

def render_invalid(exception)
  @user = exception.record
  render(action: :edit)
end
```

This way, if an invalid exception is raised in either the create or update action, the edit page
is rerendered, which can display @user.errors for example to let the user fix the data and resubmit.

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

