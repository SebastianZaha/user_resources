UserResources
=============

Many Rails applications are built as REST apis that manipulate resources. A cookbook store app would
have recipes, ingredients, orders, invoices, reviews, etc.

The app logic revolves around __users__ manipulating these resources. Hence the operations on a
resource, spread over the controller and model would go through the following steps:

* fetch the resource object
* check permissions of current_user to edit it
* sanitize input data for this resource, if needed 
* save the resource
* process possible side effects
* respond to client (render / redirect)

This gem attempts to streamline these steps.


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

