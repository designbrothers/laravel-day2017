
@title[Splash]
# Playmoove 

#### Shared mobility within everyone's reach
##### (developers included)
www.playmoove.com

---
@title[Who and What]
### about the project
<p class="text-left text-05">Build a framework for sharing mobility businesses that can allow any sharing strategy of any (connected) vehicle without imposing business decisions.</p>
<p class="text-left text-05">Current solutions are very bulky, with complex api, not white-label and with limited functionality.</p>
 
### about me
```php
$speaker = new Nerd();
$speaker->fullName = 'Riccardo Scasseddu';
$speaker->twitterHandle = '@ennetech';
$speaker->education = 'Writing thesis entitled `hacking ca(n|r)s`';
$speaker->occupation = 'Technical lead @ designbrothers';
$speaker->roles = ['Full Stack Developer', 'DevOps'];
$speaker->wannaBe = 'System architect';
$speaker->talkSpeed = 1.2;
$speaker->start();
```
+++
# why laravel
<p class="fragment text-left text-07">PHP</p>
<p class="fragment text-left text-07">Vibrant community</p>
<p class="fragment text-left text-07">Wonderfull documentation</p>
<p class="fragment text-left text-07">Great foundation for building REST api</p>

---
@title[Before we start]
### Developing software in 2017
<p class="fragment text-left text-07">Built software with colleagues, not against them</p>
<p class="fragment text-left text-07">Balance technical debt and rapid development</p>
<p class="fragment text-left text-07">Do not overthink, use prototypes to explore</p>
<p class="fragment text-left text-07">Document REST api with proper tools (Word is not a proper tool)</p>
<p class="fragment text-left text-07">Use base classes (inheritance)</p>
<p class="fragment text-left text-07">Use static analysis tools (eg.: sonarlint, phpspec, phpcs)</p>
<p class="fragment text-left text-07">Set up a pipeline</p>
<p class="fragment text-left text-07">Automate all the things</p>

<span style="font-size:0.6em; color:gray">SIMPLE</span> |
<span style="font-size:0.6em; color:gray">EXTENSIBLE</span> |
<span style="font-size:0.6em; color:gray">REVISABLE</span>

Note:
doing is the best way of thinking
---
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
    $user = User::find(Request::route('user'));
    // Do something with the user
});
```
### Good
```php
Route::get('api/users/{user}', function (User $user) {
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
---
@title[Response time]
# Enhance response time

![Response time](assets/img/4.png)
+++

##### Rules of thumb for better response time
<p class="fragment text-left text-07">Load the full dataset as needed</p>
<p class="fragment text-left text-07">Demand heavy and asyncronous task to workers</p>
<p class="fragment text-left text-07">Process data with collections and not with eloquent</p>

+++
@title[Queues]
### Queues
### Bad
```php
ExampleManager::updateStatusOnExternalService($itemId);
```
### Good
```php
dispatch(new UpdateStatusOnExternalService($item));
```
+++
@title[Eloquent eager loading]
### Eloquent eager loading
### Bad (N+1 queries)
```php
$books = App\Book::get();
foreach($books as $book){
    // Just to trigger eloquent relationship loader
    $book->author;
}
```
### Good (2 queries)
```php
$books = App\Book::with('author')->get();
foreach($books as $book){
    // Just to trigger eloquent relationship loader
    $book->author;
}
```
---
@title[Write better code]
# Starve for better code

![Happy developer](assets/img/5.png)
+++
##### Rules of thumb metrics of 'good' code
<p class="fragment text-left text-07">When something goes wrong you can know why and what quickly</p>
<p class="fragment text-left text-07">You can extend the behaviour of a component without breaking anything</p>
<p class="fragment text-left text-07">You can swap 'services' implementations without touching the references (eg.: Dependency injection)</p>
<p class="fragment text-left text-07">Every function (should) encapsulate a SPECIFIC part of the logic and hides underlying implementation details</p>
<p class="fragment text-left text-07">Respect the standards (eg.: editorconfig)</p>

+++
@title[morph paradigm]
## morph relations
#### Morphable model (Actual 'base' implementation)
```php
class Log extends Model
{
    public function loggable()
    {
        return $this->morphTo();
    }

    public function user()
    {
        return $this->morphTo();
    }
}
```
+++
@title[morph paradigm]
## morph relations
#### Trait (Apply to model)
```php
trait Loggable
{
    public function log($action, $payload = null)
    {
        $log = new Log();
        $log->action = $action;
        // Additional data that doesn't fit the action
        $log->payload = $payload;
        // Snapshot the model to have a backtrace if needed
        $log->snapshot = $this->toArray();
        $log->ip_address = request()->ip();
        $log->loggable()->associate($this);
        $user = \Auth::user();
        if ($user) {
            $log->user()->associate($user);
        }
        $log->saveOrFail();
    }
}
```
+++
## morph relations
#### example usage
```php
// $reservation is an istance of a class that has the 'Loggable' trait
$reservation->log('UPDATED');
```
+++

## Isolate request specific code with middlewares
```php
class LangMiddleware
{
    public function handle($request, Closure $next, $guard = null)
    {
        if ($request->header("lang")) {
            $requestedLang = $request->header("lang");
            if (in_array($requestedLang, config('app.locales'))) {
                \App::setLocale($requestedLang);
            } else {
                throw new LocaleNotFoundException();
            }
        }
        return $next($request);
    }
}
```
+++
@title[Log exceptions]
## Log exceptions
```php
    public function report(Exception $exception)
    {
        $exception = [];
        $request = [];

        // Add relevant data to the arrays

        try {
            $system_exception = new SystemException();
            $system_exception->exception = $exception;
            $system_exception->request = $request;
            $system_exception->save();
        } catch (Exception $new) {
            // Empty catch, needed to avoid exception loop
        }

        parent::report($exception);
    }
```
+++
## Give user coherent messages
```php
    public function render($request, Exception $exception)
    {
        if ($request->wantsJson()) {
            $parsedException = // Format the response as you wish
            return $parsedException;
        }
        return parent::render($request, $exception);
    }
``` 
+++
@title[Exception rendering]
## Exception rendering
### not all errors are the same
```
/*
 * @see 403 AuthorizationException (Forbidden)
 *     The request was valid, but the server is refusing action.
 *     The user might not have the necessary permissions for a resource.
 * @see 404 NotFoundException (Not Found)
 *     The requested resource could not be found but may be available in the future.
 *     Subsequent requests by the client are permissible
 * @see 409 RequirementException (Conflict)
 *     Indicates that the request could not be processed because of conflict in the request,
 *     such as an edit conflict between multiple simultaneous updates.
 * @see 422 UnprocessableException (Unprocessable Entity)
 *     The request was well-formed but was unable to be followed due to semantic errors.
 */
 ```

+++
@title[One problem = One exception]
## One problem = One exception
### Bad
```php
throw new ErrorException();
```
### Good
```php
throw new PaymentFailedException($reason);
```
---
@title[Questions]
## Developers are humans
+++
```php
$now = time();
if (date('U', strtotime($this->start)) > $now || date('U', strtotime($this->end)) < $now || $parameters["end"] < $now) {
    return false;
}
```
+++
```php
\DB::startTransaction();
try {
    // Dangerous action
} catch (ValidationException $e) {
    \DB::rollBack();
    return JsonResponseAdapter::generateResponse(trans('request.validation-failed'), 400, $e->validator->getMessageBag()->all());
} catch (ModelNotFoundException $e) {
    \DB::rollBack();
    return JsonResponseAdapter::generateResponse(trans('request.invalid-type'), 400, []);
} catch (\Exception $e) {
    \DB::rollBack();
    return JsonResponseAdapter::generateResponse(trans('request.failed'), 400, [$e->getMessage()]);
}
```
+++
![deleted-fetcher](assets/img/deleted-fetcher.png)
+++
```php
if ($reservation->buildCurrentBooking()) {
    if ($reservation->change()) {
        \DB::commit();
        return $this->sendReservation($reservation);
        } else {
            \DB::rollBack();
            return false;
            throw new ReservationException("change failed");
        }
    } else {
        \DB::rollBack();
        return false;
        throw new ReservationException("buildCurrentBooking failed");
    }
}    
```
---
@title[Questions]
# Questions?
---
@title[Resources]
#### pipeline resources
https://bjurr.com/continuous-integration-with-bitbucket-server-and-jenkins/
#### better controllers resources
https://laravel.com/docs/5.5/routing#route-model-binding
https://laravel.com/docs/5.5/eloquent-resources
https://laravel.com/docs/5.5/validation#creating-form-requests
#### response time resources
https://laravel.com/docs/5.5/queues
https://laravel.com/docs/5.5/eloquent-relationships#eager-loading
https://blog.frankdejonge.nl/parallelise-synchronous-business-processes/
#### better code resources
https://laravel.com/docs/5.5/errors#report-method
https://laravel.com/docs/5.5/errors#render-method
https://laravel.com/docs/5.5/errors#renderable-exceptions
https://github.com/lucid-architecture/laravel
http://laravel-italia.it/articoli/principi-solid-in-php/introduzione
https://medium.com/@enne/exception-handling-for-json-endpoints-in-a-laravel-5-application-95971c548f15
https://customlaravel.com/

---
