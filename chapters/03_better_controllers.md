@title[Better controllers]

# Write better controllers

![Happy developer](assets/img/3.png)
+++

##### Rules of thumb for better controllers
<p class="fragment text-left text-07">No exception throwing inside</p>
<p class="fragment text-left text-07">No validation logic</p>
<p class="fragment text-left text-07">No formatting logic</p>
<p class="fragment text-left text-07">No model fetching if directly deducible from the request</p>
+++

@title[Eloquent model binding]
### Routing: Eloquent model binding
#### Encapsulate path parameter fetch
### Bad
```php
Route::get('api/users/{user}', function () {
    $user = Request::route('user');
    // Do something with the user
});
```
### Good
```php
Route::get('api/users/{user}', function (App\Models\User $user) {
    // Do something with the user
});
```
+++
@title[Form request]
### Validation: Form requests
#### Encapsulate validation and authorization logic
```php
class UserRequest extends FormRequest
{
    public function authorize()
    {
        return logicThatDecidesIfTheRequestIsAuthorized();
    }

    public function rules()
    {
        return [
           'id' => 'required|numeric',
           'name' => 'required|string',
           ...
        ];
    }
}
```
+++
@title[Eloquent resources]
### Eloquent: API Resources
#### Encapsulate formatting logic
```php
class UserResource extends Resource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            ...
        ];
    }
}
```
+++
### Example
```php
Route::get('api/users/{user}', function (UserRequest $request, App\Models\User $user) {
    $request->convenienceMethod();
    return new UserResource($user);
});
```