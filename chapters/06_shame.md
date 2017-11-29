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