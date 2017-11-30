@title[Write better code]
# Starve for better code

![Happy developer](assets/img/5.png)
+++

##### Rules of thumb for better code quality and developing experience
<p class="fragment text-left text-07">Every function encapsulate a SPECIFIC part of the logic</p>
<p class="fragment text-left text-07">Hides implementation details</p>
<p class="fragment text-left text-07">Respect the standards</p>
<p class="fragment text-left text-07">When something goes wrong you can know why and what quickly</p>

+++
@title[morph paradigm]
## morph paradigm
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
## morph paradigm
#### Trait (Apply to model)
```php
trait Loggable
{
    public function log($action, $payload = null)
    {
        $log = new Log();
        $log->action = $action;
        $log->payload = $payload;
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