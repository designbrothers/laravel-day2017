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
class Event extends Model
{
    public function eventable()
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
trait Eventable
{
    public function event($action, $payload = null)
    {
        $event = new Event();
        $event->action = $action;
        // Additional data that doesn't fit the action
        $event->payload = $payload;
        // Snapshot the model to have a backtrace if needed
        $event->snapshot = $this->toArray();
        $event->ip_address = request()->ip();
        $event->eventable()->associate($this);
        $user = \Auth::user();
        if ($user) {
            $event->user()->associate($user);
        }
        $event->saveOrFail();
    }
}
```
+++
## morph relations
#### example usage
```php
// $reservation is an istance of a class that has the 'Eventable' trait
$reservation->event('EXTENDED');
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